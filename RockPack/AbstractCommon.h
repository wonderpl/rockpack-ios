#import "_AbstractCommon.h"


@interface AbstractCommon : _AbstractCommon

typedef enum {
    kVideoInstanceRootObject = 0,
    kChannelRootObject = 1,
    kChannelOwnerRootObject = 2,
    kVideoRootObject = 3,
} RootObject;

@end
