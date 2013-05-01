#import "_AbstractCommon.h"


@interface AbstractCommon : _AbstractCommon

typedef enum {
    kIgnoreNothing = 0,
    kIgnoreVideoInstanceObjects = 1,
    kIgnoreChannelObjects = 2,
    kIgnoreChannelOwnerObject = 4,
    kIgnoreVideoObjects = 8,
    kIgnoreStoredObjects = 16,
    kIgnoreViewId = 32
} IgnoringObjects;

@end
