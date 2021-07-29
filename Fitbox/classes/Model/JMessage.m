//
//  JMessage.m

#import "JMessage.h"

@implementation JMessage

- (id)initWithDictionary:(NSDictionary*)dict {
    if (self = [super init]) {
        //        _mArrLike        = [[NSMutableArray alloc] init];
        [self setDataWithDictionary:dict];
    }
    return self;
}


- (id)setDataWithDictionary:(NSDictionary*)dict {
    _userId = [dict objectForKey: @"user"];
    _type = [dict objectForKey: @"type"];
    _message = [Engine base64Decode:[dict objectForKey: @"message"]];
    _createdAt = [[dict objectForKey: @"createdAt"] intValue];
    _roomID = [dict objectForKey: @"roomID"];
//    _objectId = [dict objectForKey: @"objectId"];
    return self;
}

@end

