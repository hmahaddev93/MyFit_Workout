//
//  APIClient.m
//  TwinPoint
//
//  Created by Khatib H. on 11/12/14.
//  
//
// --- Headers ---;
#import "APIClient.h"
#import "JAmazonS3ClientManager.h"
#import "JPushMethods.h"



#define SECRET_KEY  @"8b8d37254f12372637eaaeac3d36ceeaf"



#define SUCCESS_CODE        @"1"
// --- Defines ---;
// APIBase URL;


// APIClient Class;
@implementation APIClient

// Functions;
#pragma mark - Shared Client
+ (instancetype)sharedClient
{
    static APIClient *_sharedClient;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        _sharedClient = [[APIClient alloc] initWithBaseURL:[NSURL URLWithString:WEB_SERVICES_URL]];
        
        // Set;
        _sharedClient.responseSerializer = [AFJSONResponseSerializer serializer];
        _sharedClient.responseSerializer.acceptableContentTypes =[NSSet setWithObjects:@"application/json", @"text/json", @"text/javascript", nil];
        //[NSSet setWithObject: @"application/json"];
    });
    
    return _sharedClient;
}

-(void)signRequest:(NSMutableDictionary*)parameters
{
    NSString* mCurrentDateUTC = [NSString stringWithFormat:@"%d", (int)[[NSDate date] timeIntervalSince1970]];
    NSString* stringForBake =[NSString stringWithFormat:@"%@%@", SECRET_KEY , mCurrentDateUTC];
    
    if([[JUser me] isAuthorized])
    {
        stringForBake = [NSString stringWithFormat:@"%@%@", stringForBake , [JUser me].token];
//        [parameters setObject:[Engine gPersonInfo].mUserId forKey:@"user_id"];
        [parameters setObject:[JUser me].token forKey:@"token"];
    }
    
    NSString* signature = [JUtils md5Of:stringForBake];
    
    [parameters setObject:signature forKey:@"signature"];
    [parameters setObject:mCurrentDateUTC forKey:@"requesttime"];
}

#pragma mark - APIClient
- (void)GET:(NSString *)url parameters:(NSMutableDictionary *)parameters completion:(void (^)(id responseObject, NSError *error))completion
{
    [self signRequest:parameters];
    [self GET:url parameters:parameters success:^(NSURLSessionDataTask *task, id responseObject) {
        if (completion) {
            completion(responseObject, nil);
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        if (completion) {
            completion(nil, error);
        }
    }];
}

- (void)POST:(NSString *)url parameters:(NSMutableDictionary *)parameters completion:(void (^)(id responseObject, NSError *error))completion
{
    [self signRequest:parameters];
    [self POST:url parameters:parameters success:^(NSURLSessionDataTask *task, id responseObject) {
        if (completion) {
            completion(responseObject, nil);
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        if (completion) {
            completion(nil, error);
        }
    }];
}

- (void)POST:(NSString *)url parameters:(NSMutableDictionary *)parameters constructing:(void (^)(id <AFMultipartFormData> formData))block completion:(void (^)(id responseObject, NSError *error))completion
{
    [self signRequest:parameters];
        [self POST:url parameters:parameters constructingBodyWithBlock:block success:^(NSURLSessionDataTask *task, id responseObject) {
            if (completion) {
                completion(responseObject, nil);
            }
        } failure:^(NSURLSessionDataTask *task, NSError *error) {
            NSLog(@"%@", task.currentRequest.allHTTPHeaderFields);
            
            if (completion) {
                completion(nil, error);
            }
        }];
}

- (void)DELETE:(NSString *)url parameters:(NSMutableDictionary *)parameters completion:(void (^)(id responseObject, NSError *error))completion
{
    [self signRequest:parameters];
    [self DELETE:url parameters:parameters success:^(NSURLSessionDataTask *task, id responseObject) {
        if (completion) {
            completion(responseObject, nil);
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        if (completion) {
            completion(nil, error);
        }
    }];
}

- (void)PUT:(NSString *)url parameters:(NSMutableDictionary *)parameters completion:(void (^)(id responseObject, NSError *error))completion
{
    [self signRequest:parameters];
    [self PUT:url parameters:parameters success:^(NSURLSessionDataTask *task, id responseObject) {
        if (completion) {
            completion(responseObject, nil);
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        if (completion) {
            completion(nil, error);
        }
    }];
}
#pragma mark - USER


+ (void)signInWithUsername:(NSString *)username password:(NSString *)password success:(void (^)(JUser *user))success
                   failure:(void (^)(NSString *errorMessage))failure
{
    // Params;
    NSMutableDictionary *params = [[NSMutableDictionary alloc] initWithObjectsAndKeys:username,@"username",password,@"password", nil];
    // POST;
    [[APIClient sharedClient] POST:@"users/login" parameters:params completion:^(id responseObject, NSError *error) {
        if (!error)
        {
            if([responseObject objectForKey:@"api_token"])
            {
                [[JUser me] setDataWithDictionary:[responseObject objectForKey:@"user"]];
                [JUser me].token = [responseObject objectForKey:@"api_token"];
                [JUser saveToNSDefaults:[responseObject objectForKey:@"user"]];
                [JUser saveTokenToNSDefaults:[JUser me].token];
                success([JUser me]);
            }
            else
            {
                failure(@"Connection Error");
            }
        }
        else
        {
            failure([self fetchErrorMessage:error]);
        }
    }];
}

+ (void)signUpWithUserName:(NSString *)username email:(NSString *)email password:(NSString *)password success:(void (^)(JUser *user))success
                   failure:(void (^)(NSString *errorMessage))failure
{
    // Params;
    NSMutableDictionary *params = [[NSMutableDictionary alloc] initWithObjectsAndKeys: username, @"username", email, @"email",password, @"password", nil];
    // POST;
    [[APIClient sharedClient] POST:@"users/signup" parameters:params completion:^(id responseObject, NSError *error) {
        if (!error)
        {
            if([responseObject objectForKey:@"api_token"])
            {
                [[JUser me] setDataWithDictionary:[responseObject objectForKey:@"user"]];
                [JUser me].token = [responseObject objectForKey:@"api_token"];
                [JUser saveToNSDefaults:[responseObject objectForKey:@"user"]];
                [JUser saveTokenToNSDefaults:[JUser me].token];
                success([JUser me]);
            }
            else
            {
                failure(@"Connection Error");
            }
        }
        else
        {
            failure([self fetchErrorMessage:error]);
        }
    }];
}

+ (void)forgotPasswordForEmail:(NSString *)email success:(void (^)(NSString *response))success
                   failure:(void (^)(NSString *errorMessage))failure
{
    // Params;
    NSMutableDictionary *params = [[NSMutableDictionary alloc] initWithObjectsAndKeys: email, @"email", nil];
    // POST;
    [[APIClient sharedClient] POST:@"users/forgotpassword" parameters:params completion:^(id responseObject, NSError *error) {
        if (!error)
        {
            if([responseObject objectForKey:@"message"])
            {
                success([responseObject objectForKey:@"message"]);
            }
            else
            {
                failure(@"Connection Error");
            }
        }
        else
        {
            failure([self fetchErrorMessage:error]);
        }
    }];
}


+ (void)updateProfile:(NSMutableDictionary *)dictToUpdate success:(void (^)(JUser *user))success
                       failure:(void (^)(NSString *errorMessage))failure
{
    // Params;
    NSMutableDictionary *params = [dictToUpdate mutableCopy];
    // POST;
    [[APIClient sharedClient] PUT:@"me/updateprofile" parameters:params completion:^(id responseObject, NSError *error) {
        if (!error)
        {
            if([responseObject objectForKey:@"user"])
            {
                [[JUser me] setDataWithDictionary:[responseObject objectForKey:@"user"]];
                [JUser saveToNSDefaults:[responseObject objectForKey:@"user"]];
                success([JUser me]);
            }
            else
            {
                failure(@"Connection Error");
            }
        }
        else
        {
            failure([self fetchErrorMessage:error]);
        }
    }];
}

+ (void)getCurrentUserInfo:(void (^)(JUser *user))success
              failure:(void (^)(NSString *errorMessage))failure
{
    // Params;
    NSMutableDictionary *params = [NSMutableDictionary new];
    // POST;
    [[APIClient sharedClient] GET:@"me/info" parameters:params completion:^(id responseObject, NSError *error) {
        if (!error)
        {
            if([responseObject objectForKey:@"user"])
            {
                [[JUser me] setDataWithDictionary:[responseObject objectForKey:@"user"]];
                [JUser me].token = [responseObject objectForKey:@"api_token"];
                [JUser saveToNSDefaults:[responseObject objectForKey:@"user"]];
                [JUser saveTokenToNSDefaults:[JUser me].token];
                success([JUser me]);
            }
            else
            {
                failure(@"Connection Error");
            }
        }
        else
        {
            failure([self fetchErrorMessage:error]);
        }
    }];
}
+ (void)getSingleUser:(NSString *)userId success:(void (^)(JUser *user))success
              failure:(void (^)(NSString *errorMessage))failure
{
    // Params;
    NSMutableDictionary *params = [NSMutableDictionary new];
    // POST;
    [[APIClient sharedClient] POST:[NSString stringWithFormat:@"users/%@", userId]  parameters:params completion:^(id responseObject, NSError *error) {
        if (!error)
        {
            if([responseObject objectForKey:@"user"])
            {
                JUser *user =[JUser userWithDictionary:[responseObject objectForKey:@"user"]];
                success(user);
            }
            else
            {
                failure(@"Connection Error");
            }
        }
        else
        {
            failure([self fetchErrorMessage:error]);
        }
    }];
}


+ (void)getFitlifeUsers:(NSString *)keyword lastUser:(JUser*)lastUser success:(void (^)(NSArray *users))success
             failure:(void (^)(NSString *errorMessage))failure
{
    // Params;
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%f",[Engine myLocation].latitude],@"lat",[NSString stringWithFormat:@"%f",[Engine myLocation].longitude],@"lng", @"true", @"fitlife", nil];
    if (keyword) {
        [params setObject:keyword forKey:@"keyword"];
    }
    if (lastUser) {
        [params setObject:lastUser.createdAt forKey:@"last_date"];
    }
    // POST;
    [[APIClient sharedClient] GET:@"users/fitlifesellers" parameters:params completion:^(id responseObject, NSError *error) {
        if (!error)
        {
            if([responseObject objectForKey:@"users"])
            {
                NSArray*usersJSON=[responseObject objectForKey:@"users"];
                NSMutableArray*users=[NSMutableArray new];
                for (int i=0; i<[usersJSON count]; i++) {
                    JUser *item =[JUser userWithDictionary:[usersJSON objectAtIndex:i]];
                    [users addObject:item];
                }
                success(users);
            }
            else
            {
                failure(@"Connection Error");
            }
        }
        else
        {
            failure([self fetchErrorMessage:error]);
        }
    }];
}

+(void)registerPush
{
    if ([[JUser me] isAuthorized] && [Engine gPushId]) {
        // Params;
        NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:[Engine gPushId],@"pushId", nil];
        // POST;
        [[APIClient sharedClient] PUT:@"me/registerpush" parameters:params completion:^(id responseObject, NSError *error) {
            if (!error)
            {
                NSLog(@"%@",responseObject);
            }
            else
            {
                NSLog(@"Error:%@",[self fetchErrorMessage:error]);
            }
        }];
    }
}

+(void)removePush
{
    if ([[JUser me] isAuthorized] && [Engine gPushId]) {
        // Params;
        NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:[Engine gPushId],@"pushId", nil];
        // POST;
        [[APIClient sharedClient] PUT:@"me/removepush" parameters:params completion:^(id responseObject, NSError *error) {
            if (!error)
            {
                NSLog(@"%@",responseObject);
            }
            else
            {
                NSLog(@"Error:%@",[self fetchErrorMessage:error]);
            }
        }];
    }
}


#pragma mark - Item

+ (void)getSingleItem:(NSString *)itemId success:(void (^)(JItem *item))success
         failure:(void (^)(NSString *errorMessage))failure
{
    // Params;
    NSMutableDictionary *params = [NSMutableDictionary new];
    // POST;
    [[APIClient sharedClient] POST:[NSString stringWithFormat:@"items/%@", itemId]  parameters:params completion:^(id responseObject, NSError *error) {
        if (!error)
        {
            if([responseObject objectForKey:@"item"])
            {
                JItem *item =[JItem itemWithDictionary:[responseObject objectForKey:@"item"]];
                success(item);
            }
            else
            {
                failure(@"Connection Error");
            }
        }
        else
        {
            failure([self fetchErrorMessage:error]);
        }
    }];
}

+ (void)getHomeItems:(NSString *)userId success:(void (^)(NSMutableArray *items))success
             failure:(void (^)(NSString *errorMessage))failure
{
    // Params;
    NSMutableDictionary *params = [NSMutableDictionary new];
    // POST;
    [[APIClient sharedClient] GET:[NSString stringWithFormat:@"items/user/%@", userId] parameters:params completion:^(id responseObject, NSError *error) {
        if (!error)
        {
            if([responseObject objectForKey:@"items"])
            {
                NSArray*itemsJSON=[responseObject objectForKey:@"items"];
                NSMutableArray*items=[NSMutableArray new];
                for (int i=0; i<[itemsJSON    count]; i++) {
                    JItem *item =[JItem itemWithDictionary:[itemsJSON objectAtIndex:i]];
                    [items addObject:item];
                }
                success(items);
            }
            else
            {
                failure(@"Connection Error");
            }
        }
        else
        {
            failure([self fetchErrorMessage:error]);
        }
    }];
}

+ (void)getUserItems:(NSString *)userId lastItem:(JItem*)lastItem success:(void (^)(NSMutableArray *items))success
              failure:(void (^)(NSString *errorMessage))failure
{
    // Params;
    NSMutableDictionary *params = [NSMutableDictionary new];
    if (lastItem) {
        [params setObject:lastItem.createdAt forKey:@"last_date"];
    }
    // POST;
    [[APIClient sharedClient] GET:[NSString stringWithFormat:@"items/user/%@", userId] parameters:params completion:^(id responseObject, NSError *error) {
        if (!error)
        {
            if([responseObject objectForKey:@"items"])
            {
                NSArray*itemsJSON=[responseObject objectForKey:@"items"];
                NSMutableArray*items=[NSMutableArray new];
                for (int i=0; i<[itemsJSON    count]; i++) {
                    JItem *item =[JItem itemWithDictionary:[itemsJSON objectAtIndex:i]];
                    [items addObject:item];
                }
                success(items);
            }
            else
            {
                failure(@"Connection Error");
            }
        }
        else
        {
            failure([self fetchErrorMessage:error]);
        }
    }];
}


+ (void)getFavoriteItems:(JItem*)lastItem success:(void (^)(NSMutableArray *items))success
             failure:(void (^)(NSString *errorMessage))failure
{
    // Params;
    NSMutableDictionary *params = [NSMutableDictionary new];
    if (lastItem) {
        [params setObject:lastItem.createdAt forKey:@"last_date"];
    }
    // POST;
    [[APIClient sharedClient] GET:@"me/favorite/items" parameters:params completion:^(id responseObject, NSError *error) {
        if (!error)
        {
            if([responseObject objectForKey:@"items"])
            {
                NSArray*itemsJSON=[responseObject objectForKey:@"items"];
                NSMutableArray*items=[NSMutableArray new];
                for (int i=0; i<[itemsJSON    count]; i++) {
                    JItem *item =[JItem itemWithDictionary:[itemsJSON objectAtIndex:i]];
                    [items addObject:item];
                }
                success(items);
            }
            else
            {
                failure(@"Connection Error");
            }
        }
        else
        {
            failure([self fetchErrorMessage:error]);
        }
    }];
}

+ (void)getFavoriteItemIds
{
    if (![[JUser me] isAuthorized]) {
        return;
    }
    // Params;
    NSMutableDictionary *params = [NSMutableDictionary new];
    // POST;
    [[APIClient sharedClient] GET:@"me/favorite/ids" parameters:params completion:^(id responseObject, NSError *error) {
        if (!error)
        {
            if([responseObject objectForKey:@"itemIds"])
            {
                NSArray*itemsIds=[responseObject objectForKey:@"itemIds"];
                [[Engine likeItems] removeAllObjects];
                [[Engine likeItems] addObjectsFromArray:itemsIds];
            }
        }
    }];
}

+ (void)getHomepageItems:(void (^)(NSMutableArray *items, int lastRequestDate))success
              failure:(void (^)(NSString *errorMessage))failure
{
    // Params;
    NSMutableDictionary *params = [NSMutableDictionary new];
    
    if ([JUtils isLocationAvailable]) {
        [params setObject:[NSString stringWithFormat:@"%f",[Engine myLocation].latitude] forKey:@"lat"];
        [params setObject:[NSString stringWithFormat:@"%f",[Engine myLocation].longitude] forKey:@"lng"];
    }
    // POST;
    [[APIClient sharedClient] GET:@"v2/items/homepage" parameters:params completion:^(id responseObject, NSError *error) {
        if (!error)
        {
            if([responseObject objectForKey:@"items"])
            {
                NSMutableArray*items=[NSMutableArray new];

                NSArray*listingsJSON=[responseObject objectForKey:@"listings"];
//                NSMutableArray*listings=[NSMutableArray new];
                for (int i=0; i<[listingsJSON count]; i++) {
                    JListing *item =[JListing listingWithDictionary:[listingsJSON objectAtIndex:i]];
                    [items addObject:item];
                }

                NSArray*itemsJSON=[responseObject objectForKey:@"items"];
                for (int i=0; i<[itemsJSON    count]; i++) {
                    JItem *item =[JItem itemWithDictionary:[itemsJSON objectAtIndex:i]];
                    [items addObject:item];
                }
                
                NSNumber *lastRequest=[responseObject objectForKey:@"requestTime"];
                success(items, [lastRequest intValue]);
            }
            else
            {
                failure(@"Connection Error");
            }
        }
        else
        {
            failure([self fetchErrorMessage:error]);
        }
    }];
}

+ (void)getHomepageItemsNew:(int)lastRequestDate success:(void (^)(NSMutableArray *items, NSMutableArray *listings, int lastRequestDate))success
                 failure:(void (^)(NSString *errorMessage))failure
{
    // Params;
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%d", lastRequestDate], @"lastRequestDate", nil];
    if ([JUtils isLocationAvailable]) {
        [params setObject:[NSString stringWithFormat:@"%f",[Engine myLocation].latitude] forKey:@"lat"];
        [params setObject:[NSString stringWithFormat:@"%f",[Engine myLocation].longitude] forKey:@"lng"];
    }
    // POST;
    [[APIClient sharedClient] GET:@"v2/items/homepage/new" parameters:params completion:^(id responseObject, NSError *error) {
        if (!error)
        {
            if([responseObject objectForKey:@"items"])
            {
                NSMutableArray*listings=[NSMutableArray new];
                NSMutableArray*items=[NSMutableArray new];
                NSArray*listingsJSON=[responseObject objectForKey:@"listings"];
                
                for (int i=0; i<[listingsJSON count]; i++) {
                    JListing *item =[JListing listingWithDictionary:[listingsJSON objectAtIndex:i]];
                    [listings addObject:item];
                }
                
                NSArray*itemsJSON=[responseObject objectForKey:@"items"];
                for (int i=0; i<[itemsJSON    count]; i++) {
                    JItem *item =[JItem itemWithDictionary:[itemsJSON objectAtIndex:i]];
                    [items addObject:item];
                }
                NSNumber *lastRequest=[responseObject objectForKey:@"requestTime"];
                success(items, listings, [lastRequest intValue]);
            }
            else
            {
                failure(@"Connection Error");
            }
        }
        else
        {
            failure([self fetchErrorMessage:error]);
        }
    }];
}

+ (void)getStoreItems:(JItem*)lastItem success:(void (^)(NSMutableArray *items))success
             failure:(void (^)(NSString *errorMessage))failure
{
    // Params;
    NSMutableDictionary *params = [NSMutableDictionary new];
    if (lastItem) {
        [params setObject:lastItem.createdAt forKey:@"last_date"];
    }
    // POST;
    [[APIClient sharedClient] GET:@"items/store/products" parameters:params completion:^(id responseObject, NSError *error) {
        if (!error)
        {
            if([responseObject objectForKey:@"items"])
            {
                NSArray*itemsJSON=[responseObject objectForKey:@"items"];
                NSMutableArray*items=[NSMutableArray new];
                for (int i=0; i<[itemsJSON    count]; i++) {
                    JItem *item =[JItem itemWithDictionary:[itemsJSON objectAtIndex:i]];
                    [items addObject:item];
                }
                success(items);
            }
            else
            {
                failure(@"Connection Error");
            }
        }
        else
        {
            failure([self fetchErrorMessage:error]);
        }
    }];
}

+ (void)likeItem:(JItem *)item isLike:(int)isLike success:(void (^)(JItem *item))success
              failure:(void (^)(NSString *errorMessage))failure
{
    // Params;
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInteger:isLike], @"isLike", nil];
    // POST;
    [[APIClient sharedClient] POST:[NSString stringWithFormat:@"items/%@/like", item._id]  parameters:params completion:^(id responseObject, NSError *error) {
        if (!error)
        {
            if([responseObject objectForKey:@"item"])
            {
                [item setDataWithDictionary:[responseObject objectForKey:@"item"]];
                if (isLike) {
                    [JPushMethods likedPost:item];
                    [[Engine likeItems] addObject:item._id];
                }
                else
                {
                    [[Engine likeItems] removeObject:item._id];
                }
                success(item);
            }
            else
            {
                failure(@"Connection Error");
            }
        }
        else
        {
            failure([self fetchErrorMessage:error]);
        }
    }];
}

+ (void)charge:(NSDictionary*)purchaseParams success:(void (^)(NSString *message))success
         failure:(void (^)(NSString *errorMessage))failure
{
    // Params;
    NSMutableDictionary *params = [purchaseParams mutableCopy];
    // POST;
    [[APIClient sharedClient] POST:@"charge"  parameters:params completion:^(id responseObject, NSError *error) {
        if (!error)
        {
            if([responseObject objectForKey:@"purchase"])
            {
                success([responseObject objectForKey:@"message"]);
            }
            else
            {
                failure(@"Connection Error");
            }
        }
        else
        {
            failure([self fetchErrorMessage:error]);
        }
    }];
}
#pragma mark - Listing


+ (void)loadListings:(NSString *)keyword lastListing:(JListing*)lastListing success:(void (^)(NSArray *listings))success
            failure:(void (^)(NSString *errorMessage))failure
{
    // Params;
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%f",[Engine myLocation].latitude],@"lat",[NSString stringWithFormat:@"%f",[Engine myLocation].longitude],@"lng", nil];
    if (keyword) {
        [params setObject:keyword forKey:@"keyword"];
    }
    if (lastListing) {
        [params setObject:lastListing.createdAt forKey:@"last_date"];
    }
    // POST;
    [[APIClient sharedClient] GET:@"v2/listings/nearby" parameters:params completion:^(id responseObject, NSError *error) {
        if (!error)
        {
            if([responseObject objectForKey:@"listings"])
            {
                NSArray*listingsJSON=[responseObject objectForKey:@"listings"];
                NSMutableArray*listings=[NSMutableArray new];
                for (int i=0; i<[listingsJSON count]; i++) {
                    JListing *item =[JListing listingWithDictionary:[listingsJSON objectAtIndex:i]];
                    [listings addObject:item];
                }
                success(listings);
            }
            else
            {
                failure(@"Connection Error");
            }
        }
        else
        {
            failure([self fetchErrorMessage:error]);
        }
    }];
}

+ (void)loadListing:(NSString *)listingId success:(void (^)(JListing *item))success
         failure:(void (^)(NSString *errorMessage))failure
{
    // Params;
    NSMutableDictionary *params = [NSMutableDictionary new];
    // POST;
    [[APIClient sharedClient] GET:[NSString stringWithFormat:@"listings/%@", listingId]  parameters:params completion:^(id responseObject, NSError *error) {
        if (!error)
        {
            if([responseObject objectForKey:@"listing"])
            {
                JListing *listing = [JListing listingWithDictionary:[responseObject objectForKey:@"listing"]];
                success(listing);
            }
            else
            {
                failure(@"Connection Error");
            }
        }
        else
        {
            failure([self fetchErrorMessage:error]);
        }
    }];
}

+ (void)postListing:(NSDictionary *)listingParams success:(void (^)(JListing *item))success
              failure:(void (^)(NSString *errorMessage))failure
{
    NSMutableDictionary *params = [listingParams mutableCopy];
    
    // POST;
    [[APIClient sharedClient] POST:@"listings" parameters:params completion:^(id responseObject, NSError *error) {
        if (!error)
        {
            if([responseObject objectForKey:@"listing"])
            {
                JListing *listing = [JListing listingWithDictionary:[responseObject objectForKey:@"listing"]];
                success(listing);
            }
            else
            {
                failure(@"Connection Error");
            }
        }
        else
        {
            failure([self fetchErrorMessage:error]);
        }
        
    }];
    
}
+ (void)acceptListing:(NSString *)listingId success:(void (^)(JListing *item, JMessageHistory *messageHistory))success
              failure:(void (^)(NSString *errorMessage))failure
{
    NSMutableDictionary *params = [NSMutableDictionary new];
    
    // POST;
    [[APIClient sharedClient] POST:[NSString stringWithFormat:@"v2/listings/%@/accept",listingId] parameters:params completion:^(id responseObject, NSError *error) {
        if (!error)
        {
            if([responseObject objectForKey:@"listing"])
            {
                JListing *listing = [JListing listingWithDictionary:[responseObject objectForKey:@"listing"]];
                JMessageHistory *messageHistory = [JMessageHistory messageHistoryWithDictionary:[responseObject objectForKey:@"messageHistory"]];
                success(listing,messageHistory);
            }
            else
            {
                failure(@"Connection Error");
            }
        }
        else
        {
            failure([self fetchErrorMessage:error]);
        }
        
    }];
    
}

+ (void)cancelListing:(NSString *)listingId success:(void (^)(NSString *message))success
            failure:(void (^)(NSString *errorMessage))failure
{
    // Params;
    NSMutableDictionary *params = [NSMutableDictionary new];
    // POST;
    [[APIClient sharedClient] POST:[NSString stringWithFormat:@"listings/%@/cancel", listingId]  parameters:params completion:^(id responseObject, NSError *error) {
        if (!error)
        {
            if([responseObject objectForKey:@"listing_id"])
            {
                success([responseObject objectForKey:@"message"]);
            }
            else
            {
                failure(@"Connection Error");
            }
        }
        else
        {
            failure([self fetchErrorMessage:error]);
        }
    }];
}

+(void)checkListingCount
{
    if ([JUtils isLocationAvailable]) {
        [self loadListings:nil lastListing:nil success:^(NSArray *listings) {
            if (listings) {
                [[JListing allArray] removeAllObjects];
                [[JListing allArray] addObjectsFromArray:listings];
                
                [Engine setGClassListingCount:(int)[listings count]];
                [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_CLASS_LISTING_COUNT_UPDATED object:nil];
                
            }
        } failure:^(NSString *errorMessage) {
            
        }];
        
//        NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%f",[Engine myLocation].latitude],@"lat",[NSString stringWithFormat:@"%f",[Engine myLocation].longitude],@"lng", nil];
//        // POST;
//        [[APIClient sharedClient] GET:@"listings/nearbycount" parameters:params completion:^(id responseObject, NSError *error) {
//            if (!error)
//            {
//                if([responseObject objectForKey:@"listing_count"])
//                {
//                    NSNumber *unread_count = [responseObject objectForKey:@"listing_count"];
//                    [Engine setGClassListingCount:[unread_count intValue]];
//                    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_CLASS_LISTING_COUNT_UPDATED object:nil];
//
//                }
//            }
//        }];
    }
}
//
//+(void)checkListingCount
//{
//    if ([JUtils isLocationAvailable]) {
//        
//        NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%f",[Engine myLocation].latitude],@"lat",[NSString stringWithFormat:@"%f",[Engine myLocation].longitude],@"lng", nil];
//        // POST;
//        [[APIClient sharedClient] GET:@"listings/nearbycount" parameters:params completion:^(id responseObject, NSError *error) {
//            if (!error)
//            {
//                if([responseObject objectForKey:@"listing_count"])
//                {
//                    NSNumber *unread_count = [responseObject objectForKey:@"listing_count"];
//                    [Engine setGClassListingCount:[unread_count intValue]];
//                    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_CLASS_LISTING_COUNT_UPDATED object:nil];
//                    
//                }
//            }
//        }];
//    }
//}



#pragma mark - Message History
+ (void)loadMessageHistoryWithRoom:(NSString *)roomId success:(void (^)(JMessageHistory *messagHistory))success
            failure:(void (^)(NSString *errorMessage))failure
{
    // Params;
    NSMutableDictionary *params = [NSMutableDictionary new];
    // POST;
    [[APIClient sharedClient] GET:[NSString stringWithFormat:@"messagehistories/room/%@", roomId]  parameters:params completion:^(id responseObject, NSError *error) {
        if (!error)
        {
            if([responseObject objectForKey:@"listing"])
            {
                JMessageHistory *listing = [JMessageHistory messageHistoryWithDictionary:[responseObject objectForKey:@"messageHistory"]];
                success(listing);
            }
            else
            {
                failure(@"Connection Error");
            }
        }
        else
        {
            failure([self fetchErrorMessage:error]);
        }
    }];
}

+ (void)loadMessageHistories:(JMessageHistory*)lastMessageHistory success:(void (^)(NSArray *messageHistories))success
             failure:(void (^)(NSString *errorMessage))failure
{
    // Params;
    NSMutableDictionary *params = [NSMutableDictionary new];
    if (lastMessageHistory) {
        [params setObject:lastMessageHistory.createdAt forKey:@"last_date"];
    }
    // POST;
    [[APIClient sharedClient] GET:@"me/messagehistories" parameters:params completion:^(id responseObject, NSError *error) {
        if (!error)
        {
            if([responseObject objectForKey:@"messagehistories"])
            {
                NSArray*historyJSON=[responseObject objectForKey:@"messagehistories"];
                NSMutableArray*histories=[NSMutableArray new];
                for (int i=0; i<[historyJSON count]; i++) {
                    JMessageHistory *item =[JMessageHistory messageHistoryWithDictionary:[historyJSON objectAtIndex:i]];
                    [histories addObject:item];
                }
                success(histories);
            }
            else
            {
                failure(@"Connection Error");
            }
        }
        else
        {
            failure([self fetchErrorMessage:error]);
        }
    }];
}


+ (void)removeMessageHistory:(JMessageHistory *)messageHistory success:(void (^)(JMessageHistory *messageHistory))success
              failure:(void (^)(NSString *errorMessage))failure
{
    // Params;
    NSMutableDictionary *params = [NSMutableDictionary new];
    // POST;
    [[APIClient sharedClient] POST:[NSString stringWithFormat:@"messagehistories/%@/remove", messageHistory._id]  parameters:params completion:^(id responseObject, NSError *error) {
        if (!error)
        {
            if([responseObject objectForKey:@"messageHistory"])
            {
                [messageHistory setDataWithDictionary:[responseObject objectForKey:@"messageHistory"]];
                success(messageHistory);
            }
            else
            {
                failure(@"Connection Error");
            }
        }
        else
        {
            failure([self fetchErrorMessage:error]);
        }
    }];
}
+(void)checkNewMessages
{
    if ([[JUser me] isAuthorized]) {
        
        NSMutableDictionary *params = [NSMutableDictionary new];
        // POST;
        [[APIClient sharedClient] GET:@"messagehistories/unreadcount" parameters:params completion:^(id responseObject, NSError *error) {
            if (!error)
            {
                if([responseObject objectForKey:@"unread_count"])
                {
                    NSNumber *unread_count = [responseObject objectForKey:@"unread_count"];
                    [Engine setGNewMessageCount:[unread_count intValue]];
                    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_MESSAGE_COUNT_UPDATED object:nil];

                }
            }
        }];
    }
}

+ (void)postMessageHistory:(NSDictionary *)historyParams success:(void (^)(JMessageHistory *messageHistory))success
            failure:(void (^)(NSString *errorMessage))failure
{
    NSMutableDictionary *params = [historyParams mutableCopy];
    
    // POST;
    [[APIClient sharedClient] POST:@"messagehistories" parameters:params completion:^(id responseObject, NSError *error) {
        if (!error)
        {
            if([responseObject objectForKey:@"messageHistory"])
            {
                JMessageHistory *messageHistory = [JMessageHistory messageHistoryWithDictionary:[responseObject objectForKey:@"messageHistory"]];
                success(messageHistory);
            }
            else
            {
                failure(@"Connection Error");
            }
        }
        else
        {
            failure([self fetchErrorMessage:error]);
        }
        
    }];
    
}
#pragma mark - Fetch Error Message From API Failure
+(NSString*)fetchErrorMessage:(NSError*)error
{
    NSString *errorMessage = @"Network Error";
    
    NSError *err;
    if ((NSData*)error.userInfo[AFNetworkingOperationFailingURLResponseDataErrorKey]) {
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:(NSData*)error.userInfo[AFNetworkingOperationFailingURLResponseDataErrorKey] options:kNilOptions error:&err];
        
        if (dict && [dict objectForKey:@"message"]) {
            errorMessage = [dict objectForKey:@"message"];
        }
    }
    
    return errorMessage;
}

@end
