//
//  JMessageHistory.h
//  Fitbox
//
//  Created by Khatib H. on 10/24/16.
//  
//

#import <Foundation/Foundation.h>

@interface JMessageHistory : NSObject

@property (nonatomic, retain) NSString *_id;

@property (nonatomic, retain) JListing *listing;
@property (nonatomic, retain) JUser *user;
@property (nonatomic, retain) JUser *listingPoster;

@property (nonatomic, retain) NSString *roomID;
@property (nonatomic, retain) NSString *lastMessage;
@property (nonatomic, retain) NSNumber *unreadCountUser;
@property (nonatomic, retain) NSNumber *unreadCountPoster;

@property (nonatomic, retain) NSNumber *createdAt;
@property (nonatomic, retain) NSNumber *updatedAt;


+(NSMutableDictionary*)allDict;
+(NSMutableDictionary*)allDictWithRoomID;
+(NSMutableArray*)allArray;

-(id)initWithDictionary:(NSDictionary*)dict;
-(id)setDataWithDictionary:(NSDictionary*)dict;
+(JMessageHistory*)messageHistoryWithId:(NSString*)messageHistoryId;
+(JMessageHistory*)messageHistoryWithIdIfExists:(NSString*)messageHistoryId;
+(JMessageHistory*)messageHistoryWithRoomIdIfExists:(NSString*)roomId;
+(JMessageHistory*)messageHistoryWithDictionary:(NSDictionary*)dict;


@end
