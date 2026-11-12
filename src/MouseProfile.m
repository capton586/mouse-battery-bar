#import "MouseProfile.h"

NSString *MouseName(void) { return @"VT9PRO"; }
#import <IOKit/hid/IOHIDLib.h>


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
            message = (status == kIOReturnNotPermitted || status == kIOReturnNotPrivileged)
              ? @"macOS 拒绝访问接收器。请在「系统设置 → 隐私与安全性 → 输入监控」中允许此工具，然后重新打开。"
              : [NSString stringWithFormat:@"无法打开接收器（0x%08x）。请关闭占用接收器的程序后重试。", (unsigned)status];
            continue;
        }
        uint8_t buffer[64] = {};
        IOHIDDeviceRegisterInputReportCallback(device, buffer, sizeof(buffer), onReport, reading);
        CFRunLoopRef loop = CFRunLoopGetCurrent();
        IOHIDDeviceScheduleWithRunLoop(device, loop, kCFRunLoopDefaultMode);
        CFRunLoopRunInMode(kCFRunLoopDefaultMode, 14, false);
        IOHIDDeviceUnscheduleFromRunLoop(device, loop, kCFRunLoopDefaultMode);
        IOHIDDeviceClose(device, 0);
        message = reading->percent >= 0 ? nil : @"接收器没有发来新的电量。请移动鼠标唤醒，再点「立即刷新」。";
        break;
    }
    CFRelease(manager);
    return message;
}
