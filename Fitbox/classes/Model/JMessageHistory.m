//
//  JMessageHistory.m
//  Fitbox
//
//  Created by Khatib H. on 10/24/16.
//  
//

#import "JMessageHistory.h"

@implementation JMessageHistory

+(NSMutableDictionary*)allDict
{
    static NSMutableDictionary * instance = nil;
    if (!instance) {
        instance = [[NSMutableDictionary alloc] init];
    }
    return instance;
}
+(NSMutableDictionary*)allDictWithRoomID
{
    static NSMutableDictionary * instance = nil;
    if (!instance) {
        instance = [[NSMutableDictionary alloc] init];
    }
    return instance;
}
+(NSMutableArray*)allArray
{
    static NSMutableArray * instance = nil;
    if (!instance) {
        instance = [[NSMutableArray alloc] init];
    }
    return instance;
}

- (id)init {
    if (self = [super init]) {
    }
    return self;
}

- (id)initWithDictionary:(NSDictionary*)dict {
    if (self = [super init]) {
        [self setDataWithDictionary:dict];
    }
    return self;
}

-(id)setDataWithDictionary:(NSDictionary*)dict
{
    self._id = [dict objectForKey:@"_id"];
    self.roomID = [dict objectForKey:@"roomID"];
    self.unreadCountUser = [dict objectForKey:@"unreadCountUser"];
    self.unreadCountPoster = [dict objectForKey:@"unreadCountPoster"];
    self.createdAt = [dict objectForKey:@"createdAt"];
    self.updatedAt = [dict objectForKey:@"updatedAt"];

    
    [[JMessageHistory allDict] setObject:self forKey:self.roomID];
    
    self.lastMessage = [dict objectForKey:@"lastMessage"];
    
    
    if ([dict objectForKey:@"user"] && ![[dict objectForKey:@"user"] isKindOfClass:[NSNull class]]) {
        if ([[dict objectForKey:@"user"] isKindOfClass:[NSString class]]) {
            self.user = [JUser userWithIdIfExists:[dict objectForKey:@"user"]];
        }
        else
        {
            self.user = [JUser userWithDictionary:[dict objectForKey:@"user"]];
        }
    }
    
    if ([dict objectForKey:@"listingPoster"] && ![[dict objectForKey:@"listingPoster"] isKindOfClass:[NSNull class]]) {
        if ([[dict objectForKey:@"listingPoster"] isKindOfClass:[NSString class]]) {
            self.listingPoster = [JUser userWithIdIfExists:[dict objectForKey:@"listingPoster"]];
        }
        else
        {
            self.listingPoster = [JUser userWithDictionary:[dict objectForKey:@"listingPoster"]];
        }
    }
    if ([dict objectForKey:@"listing"] && ![[dict objectForKey:@"listing"] isKindOfClass:[NSNull class]]) {
        if ([[dict objectForKey:@"listing"] isKindOfClass:[NSString class]]) {
            self.listing = [JListing listingWithIdIfExists:[dict objectForKey:@"listing"]];
        }
        else
        {
            self.listing = [JListing listingWithDictionary:[dict objectForKey:@"listing"]];
        }
    }
    return self;
}


+(JMessageHistory*)messageHistoryWithId:(NSString*)messageHistoryId
{
    JMessageHistory *messageHistory = [[self allDict] objectForKey:messageHistoryId];
    if (!messageHistory) {
        messageHistory = [[JMessageHistory alloc] init];
        messageHistory._id = messageHistoryId;
        [[self allDict] setObject:messageHistory forKey:messageHistoryId];
    }
    return messageHistory;
}
+(JMessageHistory*)messageHistoryWithRoomIdIfExists:(NSString*)roomId
{
    JMessageHistory *messageHistory = [[self allDictWithRoomID] objectForKey:roomId];
    return messageHistory;
}
+(JMessageHistory*)messageHistoryWithIdIfExists:(NSString*)messageHistoryId
{
    return [[self allDict] objectForKey:messageHistoryId];
}

+(JMessageHistory*)messageHistoryWithDictionary:(NSDictionary*)dict;
{
    JMessageHistory *messageHistory = [self messageHistoryWithId:[dict objectForKey:@"_id"]];
    [messageHistory setDataWithDictionary:dict];
    return messageHistory;
}


@end
