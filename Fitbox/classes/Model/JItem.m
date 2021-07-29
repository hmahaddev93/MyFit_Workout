//
//  JItem.m
//  Zold
//
//  Created by Khatib H. on 7/18/14.
//  
//

#import "JItem.h"

@implementation JItem

+(NSMutableDictionary*)allDict
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
        self.photos     = [[NSMutableArray alloc] init];
    }
    return self;
}

- (id)initWithDictionary:(NSDictionary*)dict {
    if (self = [super init]) {
        self.photos     = [[NSMutableArray alloc] init];
        [self setDataWithDictionary:dict];
    }
    return self;
}

-(id)setDataWithDictionary:(NSDictionary*)dict
{
    self._id = [dict objectForKey:@"_id"];
    self.item_name = [dict objectForKey:@"item_name"];
    self.itemType = [dict objectForKey:@"itemType"];
    self.desc = [dict objectForKey:@"description"];
    self.listingprice = [dict objectForKey:@"listingprice"];
    self.photos = [[dict objectForKey:@"photos"] mutableCopy];
    self.video = [dict objectForKey:@"video"];
    self.topBottom = [dict objectForKey:@"topBottom"];
    self.shippingOption = [dict objectForKey:@"shippingOption"];
    self.shippingPeriod = [dict objectForKey:@"shippingPeriod"];
    self.status = [dict objectForKey:@"status"];
    self.likesCount = [dict objectForKey:@"likesCount"];

    if ([dict objectForKey:@"user"] && ![[dict objectForKey:@"user"] isKindOfClass:[NSNull class]]) {
        if ([[dict objectForKey:@"user"] isKindOfClass:[NSString class]]) {
            self.user = [JUser userWithIdIfExists:[dict objectForKey:@"user"]];
        }
        else
        {
            self.user = [JUser userWithDictionary:[dict objectForKey:@"user"]];
        }
    }
    
    self.updatedAt = [dict objectForKey:@"updatedAt"];
    self.createdAt = [dict objectForKey:@"createdAt"];
    return self;
}
-(BOOL)hasTop
{
    return [self.topBottom containsString:SIZE_TOPS];
}
-(BOOL)hasBottom
{
    return [self.topBottom containsString:SIZE_BOTTOMS];
}
-(BOOL)hasTopBottom
{
    return [self.topBottom containsString:SIZE_TOPS] && [self.topBottom containsString:SIZE_BOTTOMS];
}

+(JItem*)itemWithId:(NSString*)itemId
{
    JItem *item = [[self allDict] objectForKey:itemId];
    if (!item) {
        item = [[JItem alloc] init];
        item._id = itemId;
        [[self allDict] setObject:item forKey:itemId];
    }
    return item;
}

+(JItem*)itemWithIdIfExists:(NSString*)itemId
{
    return [[self allDict] objectForKey:itemId];
}

+(JItem*)itemWithDictionary:(NSDictionary*)dict;
{
    JItem *item = [self itemWithId:[dict objectForKey:@"_id"]];
    [item setDataWithDictionary:dict];
    return item;
}


//
//+(void)loadItemsWithWithIDs:(NSArray *)itemIds completionBlock:(void (^)(void))completionBlock
//{
//    PFQuery *query=[PFQuery queryWithClassName:[JItem className]];
//    [query whereKey:@"objectId" containedIn:itemIds];
//    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
//        if(!error)
//        {
//            for (int i=0; i<[objects count]; i++) {
//                PFObject *object=[objects objectAtIndex:i];
//                JItem *item;//=[[Engine gFeedDict] objectForKey:object.objectId];
//                if(!item)
//                {
//                    item=[JItem convertedObject:object];
//                    [[Engine gFeedDict] setObject:item forKey:item.objectId];
//                }
//                else
//                {
//                    [item updateObject:object];
//                }
////                [mPerson setD:object];
////                [mPerson saveToManageObject];
//            }
//            
//            
//            if(completionBlock)
//            {
//                completionBlock();
//            }
//        }
//        else{
//            if(completionBlock)
//            {
//                completionBlock();
//            }
//        }
//    }];
//}
//
//
//+(void)checkItemWithWithID:(NSString *)itemId completionBlock:(void (^)(JItem*))completionBlock
//{
//    PFQuery *query=[PFQuery queryWithClassName:[JItem className]];
//    [query whereKey:@"objectId" equalTo:itemId];
//    query.cachePolicy=kPFCachePolicyNetworkOnly;
//    [query getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
//        if(object)
//        {
//            JItem *mItem=[[Engine gFeedDict] objectForKey:object.objectId];
//            if(mItem)
//            {
//                [mItem updateObject:object];
//            }
//            else
//            {
//                mItem=[JItem convertedObject:object];
//                [[Engine gFeedDict] setObject:mItem forKey:object.objectId];
//            }
//            if(completionBlock)
//            {
//                completionBlock(mItem);
//            }
//        }
//        else
//        {
//            if(completionBlock)
//            {
//                completionBlock(nil);
//            }
//        }
//        
//    }];
//}
//
//
//+(void)loadItemWithWithID:(NSString *)itemId completionBlock:(void (^)(JItem*))completionBlock
//{
//    PFQuery *query=[PFQuery queryWithClassName:[JItem className]];
//    [query whereKey:@"objectId" equalTo:itemId];
//    query.cachePolicy=kPFCachePolicyCacheThenNetwork;
//    __block BOOL cacheResult=YES;
//    __block BOOL callbackCalled=NO;
//    [query getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
//        if(cacheResult)
//        {
//            cacheResult=NO;
//            
//            if(object)
//            {
//                callbackCalled=YES;
//                JItem *mItem=[[Engine gFeedDict] objectForKey:object.objectId];
//                if(mItem)
//                {
//                    [mItem updateObject:object];
//                }
//                else
//                {
//                    mItem=[JItem convertedObject:object];
//                    [[Engine gFeedDict] setObject:mItem forKey:object.objectId];
//                }
//                completionBlock(mItem);
//            }
//        }
//        else
//        {
//            if(!callbackCalled)
//            {
//                if(object)
//                {
//                    callbackCalled=YES;
//                    JItem *mItem=[[Engine gFeedDict] objectForKey:object.objectId];
//                    if(mItem)
//                    {
//                        [mItem updateObject:object];
//                    }
//                    else
//                    {
//                        mItem=[JItem convertedObject:object];
//                        [[Engine gFeedDict] setObject:mItem forKey:object.objectId];
//                    }
//                    
//                    completionBlock(mItem);
//                }
//                else
//                {
//                    completionBlock(nil);
//                }
//            }
//        }
//
//    }];
//}
//
//-(id)updateObject:(PFObject*)object
//{
//    self.likesCount=[object valueForKey:@"likesCount"];
//    self.status=[object valueForKey:@"status"];
//    
//    return self;
//}
//

@end
