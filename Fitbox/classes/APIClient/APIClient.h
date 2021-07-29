//
//  APIClient.h
//  TwinPoint
//
//  Created by Khatib H. on 11/12/14.
//  
//
// --- Headers ---;

#import "AFHTTPSessionManager.h"


// --- Defines ---;
// APIClient Class;
@interface APIClient : AFHTTPSessionManager


#pragma mark -User


+ (void)signInWithUsername:(NSString *)username password:(NSString *)password success:(void (^)(JUser *user))success
                   failure:(void (^)(NSString *errorMessage))failure;
+ (void)signUpWithUserName:(NSString *)username email:(NSString *)email password:(NSString *)password success:(void (^)(JUser *user))success
                   failure:(void (^)(NSString *errorMessage))failure;
+ (void)forgotPasswordForEmail:(NSString *)email success:(void (^)(NSString *response))success
                       failure:(void (^)(NSString *errorMessage))failure;

+ (void)updateProfile:(NSMutableDictionary *)dictToUpdate success:(void (^)(JUser *user))success
              failure:(void (^)(NSString *errorMessage))failure;
+ (void)getCurrentUserInfo:(void (^)(JUser *user))success
                   failure:(void (^)(NSString *errorMessage))failure;
+ (void)getSingleUser:(NSString *)userId success:(void (^)(JUser *user))success
              failure:(void (^)(NSString *errorMessage))failure;
+ (void)getFitlifeUsers:(NSString *)keyword lastUser:(JUser*)lastUser success:(void (^)(NSArray *users))success
                failure:(void (^)(NSString *errorMessage))failure;

+(void)registerPush;
+(void)removePush;
#pragma mark - Item

+ (void)getSingleItem:(NSString *)itemId success:(void (^)(JItem *item))success
              failure:(void (^)(NSString *errorMessage))failure;
+ (void)likeItem:(JItem *)item isLike:(int)isLike success:(void (^)(JItem *item))success
         failure:(void (^)(NSString *errorMessage))failure;
+ (void)getUserItems:(NSString *)userId lastItem:(JItem*)lastItem success:(void (^)(NSMutableArray *items))success
             failure:(void (^)(NSString *errorMessage))failure;
+ (void)getHomepageItems:(void (^)(NSMutableArray *items, int lastRequestDate))success
                 failure:(void (^)(NSString *errorMessage))failure;
+ (void)getHomepageItemsNew:(int)lastRequestDate success:(void (^)(NSMutableArray *items, NSMutableArray *listings, int lastRequestDate))success
                    failure:(void (^)(NSString *errorMessage))failure;
+ (void)getFavoriteItems:(JItem*)lastItem success:(void (^)(NSMutableArray *items))success
                 failure:(void (^)(NSString *errorMessage))failure;
+ (void)getStoreItems:(JItem*)lastItem success:(void (^)(NSMutableArray *items))success
              failure:(void (^)(NSString *errorMessage))failure;
+ (void)charge:(NSDictionary*)purchaseParams success:(void (^)(NSString *message))success
       failure:(void (^)(NSString *errorMessage))failure;
+ (void)getFavoriteItemIds;

#pragma mark - Listing

+ (void)loadListing:(NSString *)listingId success:(void (^)(JListing *item))success
            failure:(void (^)(NSString *errorMessage))failure;
+ (void)loadListings:(NSString *)keyword lastListing:(JListing*)lastListing success:(void (^)(NSArray *listings))success
             failure:(void (^)(NSString *errorMessage))failure;

+ (void)postListing:(NSDictionary *)listingParams success:(void (^)(JListing *item))success
            failure:(void (^)(NSString *errorMessage))failure;

+ (void)acceptListing:(NSString *)listingId success:(void (^)(JListing *item, JMessageHistory *messageHistory))success
              failure:(void (^)(NSString *errorMessage))failure;
+ (void)cancelListing:(NSString *)listingId success:(void (^)(NSString *message))success
              failure:(void (^)(NSString *errorMessage))failure;
+(void)checkListingCount;


#pragma mark - Message History
+ (void)loadMessageHistoryWithRoom:(NSString *)roomId success:(void (^)(JMessageHistory *messagHistory))success
                           failure:(void (^)(NSString *errorMessage))failure;
+ (void)loadMessageHistories:(JMessageHistory*)lastMessageHistory success:(void (^)(NSArray *messageHistories))success
                     failure:(void (^)(NSString *errorMessage))failure;
+ (void)removeMessageHistory:(JMessageHistory *)messageHistory success:(void (^)(JMessageHistory *messageHistory))success
                     failure:(void (^)(NSString *errorMessage))failure;
+ (void)postMessageHistory:(NSDictionary *)historyParams success:(void (^)(JMessageHistory *messageHistory))success
                   failure:(void (^)(NSString *errorMessage))failure;
+(void)checkNewMessages;

@end

