//
//  JItem.h
//  Fitbox
//
//  Created by Khatib H. on 7/18/14.
//  
//

#import <Foundation/Foundation.h>

@interface JItem : NSObject

@property (nonatomic, retain) NSString *_id;

@property (nonatomic, retain) JUser *user;

@property (nonatomic, retain) NSString *item_name;
@property (nonatomic, retain) NSString *itemType;
@property (nonatomic, retain) NSString *desc;
@property (nonatomic, retain) NSNumber *listingprice;

@property (nonatomic, retain) NSMutableArray *photos;
@property (nonatomic, retain) NSString *video;


@property (nonatomic, retain) NSString *topBottom;
@property (nonatomic, retain) NSString *shippingOption;


@property (nonatomic, retain) NSString *shippingPeriod;
@property (nonatomic, retain) NSString *status;
@property (nonatomic, retain) NSNumber *likesCount;
@property (nonatomic, retain) NSNumber *createdAt;
@property (nonatomic, retain) NSNumber *updatedAt;





+(NSMutableDictionary*)allDict;
+(NSMutableArray*)allArray;
-(id)initWithDictionary:(NSDictionary*)dict;
-(id)setDataWithDictionary:(NSDictionary*)dict;
-(BOOL)hasTop;
-(BOOL)hasBottom;
-(BOOL)hasTopBottom;

+(JItem*)itemWithId:(NSString*)itemId;
+(JItem*)itemWithIdIfExists:(NSString*)itemId;
+(JItem*)itemWithDictionary:(NSDictionary*)dict;


//-(id)updateObject:(PFObject*)object;
//
//+(void)loadItemsWithWithIDs:(NSArray *)itemIds completionBlock:(void (^)(void))completionBlock;
//+(void)loadItemWithWithID:(NSString *)itemId completionBlock:(void (^)(JItem*))completionBlock;
//+(void)checkItemWithWithID:(NSString *)itemId completionBlock:(void (^)(JItem*))completionBlock;


@end
