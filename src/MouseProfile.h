#import <Foundation/Foundation.h>

// Implement these in MouseProfile.m for the one mouse used by this build.
// Return nil on success and set percent to a fresh value between 0 and 100.
NSString *MouseName(void);
NSString *ReadBattery(int *percent);
