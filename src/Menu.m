#import <Cocoa/Cocoa.h>
#import "MouseProfile.h"
#import <ServiceManagement/ServiceManagement.h>

#ifdef VT9PRO_UPDATES
#import <Sparkle/Sparkle.h>
#endif

@interface BatteryMenu : NSObject <NSApplicationDelegate, NSMenuDelegate>
@end

@implementation BatteryMenu {
    NSStatusItem *_item;
    NSMenuItem *_stateLine, *_lastLine, *_refresh, *_privacy, *_login, *_dpi;
    NSMenu *_intervalMenu;
    NSTimer *_timer;
    BOOL _reading, _screensAsleep;
    NSInteger _minutes;
#ifdef VT9PRO_UPDATES
    SPUStandardUpdaterController *_updates;
    NSMenuItem *_checkUpdate, *_autoCheck, *_autoDownload;
#endif
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
    menu.delegate = self;
    _stateLine = [menu addItemWithTitle:MouseName() action:nil keyEquivalent:@""];
    _stateLine.enabled = NO;
    _lastLine = [menu addItemWithTitle:@"" action:nil keyEquivalent:@""];
    _lastLine.enabled = NO;
    _dpi = [menu addItemWithTitle:@"" action:nil keyEquivalent:@""];
    _dpi.enabled = NO;
    _dpi.hidden = YES;
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
    _login = [menu addItemWithTitle:@"登录时启动" action:@selector(toggleLogin:) keyEquivalent:@""];
    _login.target = self;
#ifdef VT9PRO_UPDATES
    _updates = [[SPUStandardUpdaterController alloc] initWithStartingUpdater:YES updaterDelegate:nil userDriverDelegate:nil];
    _checkUpdate = [menu addItemWithTitle:@"检查更新…" action:@selector(checkForUpdates:) keyEquivalent:@""];
    _checkUpdate.target = _updates;
    _autoCheck = [menu addItemWithTitle:@"自动检查更新" action:@selector(toggleUpdates:) keyEquivalent:@""];
    _autoCheck.target = self;
    _autoDownload = [menu addItemWithTitle:@"自动下载更新" action:@selector(toggleDownloads:) keyEquivalent:@""];
    _autoDownload.target = self;
#endif
    [menu addItem:NSMenuItem.separatorItem];
    NSMenuItem *quit = [menu addItemWithTitle:@"退出" action:@selector(terminate:) keyEquivalent:@"q"];
    quit.target = NSApp;
    _item.menu = menu;
    [self scheduleTimer];
    NSNotificationCenter *workspace = NSWorkspace.sharedWorkspace.notificationCenter;
    [workspace addObserver:self selector:@selector(screensSleep:) name:NSWorkspaceScreensDidSleepNotification object:nil];
    [workspace addObserver:self selector:@selector(screensWake:) name:NSWorkspaceScreensDidWakeNotification object:nil];
    [self sample:nil];
}
- (void)screensSleep:(NSNotification *)note {
    _screensAsleep = YES;
    [_timer invalidate];
}
- (void)screensWake:(NSNotification *)note {
    _screensAsleep = NO;
    [self scheduleTimer];
    [self sample:nil];
}
#ifdef VT9PRO_UPDATES
- (void)toggleDownloads:(id)sender {
    _updates.updater.automaticallyDownloadsUpdates = !_updates.updater.automaticallyDownloadsUpdates;
}
- (void)toggleUpdates:(id)sender {
    _updates.updater.automaticallyChecksForUpdates = !_updates.updater.automaticallyChecksForUpdates;
}
#endif
- (void)menuWillOpen:(NSMenu *)menu {
#ifdef VT9PRO_UPDATES
    _checkUpdate.enabled = _updates.updater.canCheckForUpdates;
    _autoDownload.enabled = _updates.updater.allowsAutomaticUpdates;
    _autoDownload.state = _updates.updater.automaticallyDownloadsUpdates ? NSControlStateValueOn : NSControlStateValueOff;
    _autoCheck.state = _updates.updater.automaticallyChecksForUpdates ? NSControlStateValueOn : NSControlStateValueOff;
#endif
    SMAppServiceStatus status = SMAppService.mainAppService.status;
    BOOL pending = status == SMAppServiceStatusRequiresApproval;
    _login.title = pending ? @"登录时启动（去系统设置允许…）" : @"登录时启动";
    _login.state = pending ? NSControlStateValueMixed :
                   status == SMAppServiceStatusEnabled ? NSControlStateValueOn : NSControlStateValueOff;
}
- (void)toggleLogin:(id)sender {
    SMAppService *service = SMAppService.mainAppService;
    if (service.status == SMAppServiceStatusRequiresApproval) {
        [SMAppService openSystemSettingsLoginItems];
        return;
    }
    NSError *error = nil;
    BOOL ok = service.status == SMAppServiceStatusEnabled
            ? [service unregisterAndReturnError:&error]
            : [service registerAndReturnError:&error];
    if (!ok) {
        NSAlert *alert = [NSAlert new];
        alert.messageText = @"无法更改登录项";
        alert.informativeText = [NSString stringWithFormat:@"请先将应用放入「应用程序」并从那里打开。也可以在「系统设置 → 通用 → 登录项」中手动添加或移除。\n%@", error.localizedDescription ?: @""];
        [alert runModal];
    }
}
- (void)showLastReading {
    NSDictionary *last = [NSUserDefaults.standardUserDefaults dictionaryForKey:@"LastReading"];
    NSDate *date = last[@"date"];
    NSNumber *percent = last[@"percent"];
    if (![date isKindOfClass:NSDate.class] || ![percent isKindOfClass:NSNumber.class] ||
        percent.doubleValue < 0 || percent.doubleValue > 100 || percent.doubleValue != percent.integerValue) {
        _item.button.title = @" —";
        _lastLine.title = @"尚无读数";
        return;
    }
    _item.button.title = [NSString stringWithFormat:@" %@%%", percent];
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
    if (_reading || _screensAsleep) return;
    _reading = YES;
    _refresh.enabled = NO;
    _stateLine.title = [MouseName() stringByAppendingString:@" · 正在读取…"];
    dispatch_async(dispatch_get_global_queue(QOS_CLASS_UTILITY, 0), ^{
        MouseReading reading;
        NSString *error = ReadBattery(&reading);
        dispatch_async(dispatch_get_main_queue(), ^{
            self->_reading = NO;
            self->_refresh.enabled = YES;
            self->_privacy.hidden = ![error containsString:@"输入监控"];
            self->_stateLine.title = error ?: [NSString stringWithFormat:@"%@ · %d%%", MouseName(), reading.percent];
            self->_dpi.hidden = error || reading.dpi == 0;
            if (!self->_dpi.hidden)
                self->_dpi.title = [NSString stringWithFormat:@"当前 DPI　%d", reading.dpi];
            if (!error) {
                [NSUserDefaults.standardUserDefaults setObject:@{@"percent": @(reading.percent), @"date": NSDate.date}
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
        if (argc == 2 && (!strcmp(argv[1], "--print") || !strcmp(argv[1], "--status"))) {
            MouseReading reading;
            NSString *error = ReadBattery(&reading);
            if (error) { fprintf(stderr, "%s\n", error.UTF8String); return 1; }
            printf("%d%%\n", reading.percent);
            if (!strcmp(argv[1], "--status") && reading.dpi > 0) printf("DPI: %d\n", reading.dpi);
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
