#import <Foundation/Foundation.h>

typedef struct {
    int percent; // 0–100 on success
    int dpi;     // 0 when unavailable
} MouseReading;

NSString *MouseName(void);
// Returns nil only when a fresh device report populated reading.
NSString *ReadBattery(MouseReading *reading);
