#import "MouseProfile.h"
#import <Carbon/Carbon.h>
#import <IOKit/hid/IOHIDLib.h>
#import <IOKit/hidsystem/IOHIDLib.h>

NSString *MouseName(void) { return @"VT9PRO"; }


// HIToolbox documents this query as not thread safe. UI samples run on a worker.
static BOOL secureInputEnabled(void) {
    if (NSThread.isMainThread) return IsSecureEventInputEnabled();
    __block BOOL active;
    dispatch_sync(dispatch_get_main_queue(), ^{ active = IsSecureEventInputEnabled(); });
    return active;
}

static NSString *readFailure(IOReturn status) {
    IOHIDAccessType access = IOHIDCheckAccess(kIOHIDRequestTypeListenEvent);
    if (access == kIOHIDAccessTypeDenied)
        return @"请在「输入监控」允许已安装的 Mouse Battery Bar，然后退出并重新打开。";
    if (secureInputEnabled())
        return @"安全输入正在使用。请在密码输入结束后离开密码框，再点「立即刷新」。";
    if (status == kIOReturnNotPermitted || status == kIOReturnNotPrivileged)
        return @"macOS 拒绝访问。请检查「输入监控」中已安装应用的权限，然后重新打开。";
    if (status != kIOReturnSuccess)
        return [NSString stringWithFormat:@"无法打开接收器（0x%08x）。", (unsigned)status];
    return @"接收器没有发来新的电量。请移动鼠标唤醒，再点「立即刷新」。";
}

static void onReport(void *context, IOReturn result, void *sender,
                     IOHIDReportType type, uint32_t reportID, uint8_t *bytes, CFIndex count) {
    if (result != kIOReturnSuccess || reportID != 0xbb) return;
    if (count == 7 && bytes[0] == reportID) { bytes++; count--; }
    if (count != 6 || bytes[0] != 0xb0 || bytes[5] > 100) return;
    MouseReading *reading = context;
    reading->percent = bytes[5];
    reading->dpi = bytes[2] | (bytes[3] << 8);
    CFRunLoopStop(CFRunLoopGetCurrent());
}

NSString *ReadBattery(MouseReading *reading) {
    *reading = (MouseReading){.percent = -1};
    NSDictionary *match = @{@"VendorID": @0x24ae, @"ProductID": @0x185a, @"PrimaryUsage": @6};
    IOHIDManagerRef manager = IOHIDManagerCreate(NULL, 0);
    IOHIDManagerSetDeviceMatching(manager, (__bridge CFDictionaryRef)match);
    NSSet *devices = CFBridgingRelease(IOHIDManagerCopyDevices(manager));
    NSString *message = @"请插入雷柏 USB 接收器，然后点「立即刷新」。";
    for (id object in devices) {
        IOHIDDeviceRef device = (__bridge IOHIDDeviceRef)object;
        IOReturn status = IOHIDDeviceOpen(device, kIOHIDOptionsTypeNone);
        if (status != kIOReturnSuccess) {
            message = readFailure(status);
            continue;
        }
        uint8_t buffer[64] = {};
        IOHIDDeviceRegisterInputReportCallback(device, buffer, sizeof(buffer), onReport, reading);
        CFRunLoopRef loop = CFRunLoopGetCurrent();
        IOHIDDeviceScheduleWithRunLoop(device, loop, kCFRunLoopDefaultMode);
        CFRunLoopRunInMode(kCFRunLoopDefaultMode, 14, false);
        IOHIDDeviceUnscheduleFromRunLoop(device, loop, kCFRunLoopDefaultMode);
        IOHIDDeviceClose(device, 0);
        message = reading->percent >= 0 ? nil : readFailure(kIOReturnSuccess);
        break;
    }
    CFRelease(manager);
    return message;
}
