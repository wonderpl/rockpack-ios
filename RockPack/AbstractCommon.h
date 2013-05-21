#import "_AbstractCommon.h"


@interface AbstractCommon : _AbstractCommon

typedef enum {
    kIgnoreNothing = 0,
    kIgnoreVideoInstanceObjects = 1 << 0,
    kIgnoreChannelObjects = 1 << 2,
    kIgnoreChannelOwnerObject = 1 << 3,
    kIgnoreVideoObjects = 1 << 4,
    kIgnoreStoredObjects = 1 << 5,
    kIgnoreViewId = 1 << 6,
    kIgnoreChannelCover = 1 << 7,
    kIgnoreFreshData = 1 << 8,
    kIgnoreAll = INT32_MAX
} IgnoringObjects;

@end
