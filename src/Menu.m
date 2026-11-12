#import <Cocoa/Cocoa.h>
#import "MouseProfile.h"

@interface BatteryMenu : NSObject <NSApplicationDelegate>
@end

@implementation BatteryMenu {
    NSStatusItem *_item;
    NSMenuItem *_stateLine, *_lastLine, *_refresh, *_privacy;
    NSMenu *_intervalMenu;
    NSTimer *_timer;
    BOOL _reading;
    NSInteger _minutes;
}
- (void)applicationDidFinishLaunching:(NSNotification *)notification {
    NSUserDefaults *defaults = NSUserDefaults.standardUserDefaults;
    NSArray *choices = @[@5, @10, @15, @30];
    NSNumber *saved = [defaults objectForKey:@"SamplingMinutes"];
    _minutes = saved && [choices containsObject:saved] ? saved.integerValue : 5;

    _item = [NSStatusBar.systemStatusBar statusItemWithLength:NSVariableStatusItemLength];
    NSStatusBarButton *button = _item.button;
    button.image = [NSImage imageWithSystemSymbolName:@"computermouse" accessibilityDescription:MouseName()];
    button.imagePosition = NSImageLeading;
    button.title = @" —";
    NSMenu *menu = [NSMenu new];
    menu.autoenablesItems = NO;
    _stateLine = [menu addItemWithTitle:MouseName() action:nil keyEquivalent:@""];
    _stateLine.enabled = NO;
    _lastLine = [menu addItemWithTitle:@"" action:nil keyEquivalent:@""];
    _lastLine.enabled = NO;
    [self showLastReading];
    [menu addItem:NSMenuItem.separatorItem];
    _refresh = [menu addItemWithTitle:@"立即刷新" action:@selector(sample:) keyEquivalent:@""];
    _refresh.target = self;
    _privacy = [menu addItemWithTitle:@"打开输入监控设置…" action:@selector(openPrivacy:) keyEquivalent:@""];
    _privacy.target = self;
    _privacy.hidden = YES;
    NSMenuItem *interval = [menu addItemWithTitle:@"采样间隔" action:nil keyEquivalent:@""];
    _intervalMenu = [NSMenu new];
    interval.submenu = _intervalMenu;
    for (NSNumber *minutes in choices) {
        NSString *title = [NSString stringWithFormat:@"%@ 分钟", minutes];
        NSMenuItem *choice = [_intervalMenu addItemWithTitle:title action:@selector(selectInterval:) keyEquivalent:@""];
        choice.tag = minutes.integerValue;
        choice.target = self;
    }
    [menu addItem:NSMenuItem.separatorItem];
    NSMenuItem *quit = [menu addItemWithTitle:@"退出" action:@selector(terminate:) keyEquivalent:@"q"];
    quit.target = NSApp;
    _item.menu = menu;
    [self scheduleTimer];
    [NSWorkspace.sharedWorkspace.notificationCenter addObserver:self selector:@selector(sample:)
            name:NSWorkspaceDidWakeNotification object:nil];
    [self sample:nil];
}
- (void)showLastReading {
    NSDictionary *last = [NSUserDefaults.standardUserDefaults dictionaryForKey:@"LastReading"];
    NSDate *date = last[@"date"];
    if (![date isKindOfClass:NSDate.class] || ![last[@"percent"] isKindOfClass:NSNumber.class]) {
        _lastLine.title = @"尚无读数";
        return;
    }
    NSString *when = [NSDateFormatter localizedStringFromDate:date dateStyle:NSDateFormatterShortStyle
                                                    timeStyle:NSDateFormatterShortStyle];
    _lastLine.title = [NSString stringWithFormat:@"上次读数　%@%% · %@", last[@"percent"], when];
}
- (void)scheduleTimer {
    [_timer invalidate];
    _timer = [NSTimer scheduledTimerWithTimeInterval:60.0 * _minutes target:self
            selector:@selector(sample:) userInfo:nil repeats:YES];
    _timer.tolerance = 10;
    for (NSMenuItem *choice in _intervalMenu.itemArray)
        choice.state = choice.tag == _minutes ? NSControlStateValueOn : NSControlStateValueOff;
}
- (void)selectInterval:(NSMenuItem *)sender {
    _minutes = sender.tag;
    [NSUserDefaults.standardUserDefaults setInteger:_minutes forKey:@"SamplingMinutes"];
    [self scheduleTimer];
}
- (void)openPrivacy:(id)sender {
    [NSWorkspace.sharedWorkspace openURL:[NSURL URLWithString:@"x-apple.systempreferences:com.apple.preference.security?Privacy_ListenEvent"]];
}
- (void)sample:(id)sender {
    if (_reading) return;
    _reading = YES;
    _refresh.enabled = NO;
    _stateLine.title = [MouseName() stringByAppendingString:@" · 正在读取…"];
    dispatch_async(dispatch_get_global_queue(QOS_CLASS_UTILITY, 0), ^{
        int percent = -1;
        NSString *error = ReadBattery(&percent);
        dispatch_async(dispatch_get_main_queue(), ^{
            self->_reading = NO;
            self->_refresh.enabled = YES;
            self->_privacy.hidden = ![error containsString:@"输入监控"];
            NSString *title = error ? @" —" : [NSString stringWithFormat:@" %d%%", percent];
            self->_item.button.title = title;
            self->_stateLine.title = error ?: [NSString stringWithFormat:@"%@ · %d%%", MouseName(), percent];
            if (!error) {
                [NSUserDefaults.standardUserDefaults setObject:@{@"percent": @(percent), @"date": NSDate.date}
                                                       forKey:@"LastReading"];
            }
            [self showLastReading];
            self->_item.button.toolTip = [NSString stringWithFormat:@"%@\n%@", self->_stateLine.title, self->_lastLine.title];
        });
    });
}
@end

int main(int argc, const char *argv[]) {
    @autoreleasepool {
        if (argc == 2 && strcmp(argv[1], "--print") == 0) {
            int percent = -1;
            NSString *error = ReadBattery(&percent);
            if (error) { fprintf(stderr, "%s\n", error.UTF8String); return 1; }
            printf("%d%%\n", percent);
            return 0;
        }
        NSApplication *app = NSApplication.sharedApplication;
        [app setActivationPolicy:NSApplicationActivationPolicyAccessory];
        __attribute__((objc_precise_lifetime)) BatteryMenu *delegate = [BatteryMenu new];
        app.delegate = delegate;
        [app run];
    }
    return 0;
}
