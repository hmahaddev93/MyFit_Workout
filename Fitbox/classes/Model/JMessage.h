//
//  JMessage.h

#import <Foundation/Foundation.h>

#define MESSAGE_TYPE_NOTE   @"note"
#define MESSAGE_TYPE_PHOTO   @"photo"

@interface JMessage : NSObject

@property (nonatomic, retain) NSString    *userId;
//@property (nonatomic, retain) NSString    *objectId;
@property (nonatomic, retain) NSString    *roomID;
@property (nonatomic) int    createdAt;
@property (nonatomic, retain) NSString    *message;
@property (nonatomic, retain) NSString    *type;

- (id)initWithDictionary:(NSDictionary*)dict;
- (id)setDataWithDictionary:(NSDictionary*)dict;
@end
