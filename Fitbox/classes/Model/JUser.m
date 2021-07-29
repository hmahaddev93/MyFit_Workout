//
//  JUser.m
//
//  Created by Khatib H. on 9/2/14.
//  
//
//
#import "JUser.h"
#import <CommonCrypto/CommonDigest.h>
#import <OneSignal/OneSignal.h>

@implementation JUser


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
+(JUser*)me
{
    static JUser * instance = nil;
    if (!instance) {
        instance = [[JUser alloc] init];
    }
    return instance;
}

-(BOOL)isAuthorized
{
    return (self.token != nil);
}

-(void)logout
{
//    [OneSignal setSubscription:false];
    [APIClient removePush];
    self.token = nil;
    [JUser clearNSDefaults];
    [JUser clearTokenFromNSDefaults];
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
    
    self.fullName = [dict objectForKey:@"fullName"];
    self.username = [dict objectForKey:@"username"];
    self.firstName = [dict objectForKey:@"firstName"];
    self.lastName = [dict objectForKey:@"lastName"];
    
//    self.specData = [dict objectForKey:@"specData"];
    self.email = [dict objectForKey:@"email"];
    self.profilePhoto = [dict objectForKey:@"profilePhoto"];
    self.backgroundPhoto = [dict objectForKey:@"backgroundPhoto"];
    self.userType = [dict objectForKey:@"userType"];
    self.siteLink = [dict objectForKey:@"siteLink"];
    self.pushIds = [dict objectForKey:@"pushIds"];
    
    self.updatedAt = [dict objectForKey:@"updatedAt"];
    self.createdAt = [dict objectForKey:@"createdAt"];
        
    return self;
}


+(JUser*)userWithId:(NSString*)userId
{
    JUser *user = [[self allDict] objectForKey:userId];
    if (!user) {
        user = [[JUser alloc] init];
        user._id = userId;
        [[self allDict] setObject:user forKey:userId];
    }
    return user;
}

+(JUser*)userWithIdIfExists:(NSString*)userId
{
    return [[self allDict] objectForKey:userId];
}

+(JUser*)userWithDictionary:(NSDictionary*)dict;
{
    JUser *user = [self userWithId:[dict objectForKey:@"_id"]];
    [user setDataWithDictionary:dict];
    return user;
}





/*** Current User Realted ****/


+(void)loadFromNSDefaults
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSDictionary* dict = [defaults dictionaryForKey: CURRENT_USER_NSDEFAULT];
    if(dict)
    {
        [[JUser me] setDataWithDictionary:dict];
    }
}

+(void)saveToNSDefaults:(NSDictionary*)dict
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:dict forKey:CURRENT_USER_NSDEFAULT];
    [defaults synchronize];
}
+(void)clearNSDefaults
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults removeObjectForKey:CURRENT_USER_NSDEFAULT];
    [defaults synchronize];
}

+(void)clearTokenFromNSDefaults
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults removeObjectForKey:@"token_info"];
    [defaults synchronize];
}
+(void)loadTokenFromNSDefaults
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *token = [defaults stringForKey:@"token_info"];
    if(token)
    {
        [JUser me].token = token;
    }
}

+(void)saveTokenToNSDefaults:(NSString*)token
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:token forKey:@"token_info"];
    [defaults synchronize];
}








+ (void)actionAfterLogin
{
    if([[JUser me] isAuthorized])
    {
        // TODO: Register Push with PushWoosh
        [APIClient registerPush];
//        [OneSignal setSubscription:true];
//        [OneSignal registerForPushNotifications];
        [Engine setGStatusForPush:YES];
        [Engine actionAfterLogin];
        [APIClient getFavoriteItemIds];
    }
}


+(NSString*)securingData:(NSString*)input
{

    input=[self md5:[NSString stringWithFormat:@"se!#%@6*",input]];
    
    
    const char *cstr = [input cStringUsingEncoding:NSUTF8StringEncoding];
    NSData *data = [NSData dataWithBytes:cstr length:input.length];
    
    uint8_t digest[CC_SHA1_DIGEST_LENGTH];
    
    CC_SHA1(data.bytes, (CC_LONG)data.length, digest);
    
    NSMutableString* output = [NSMutableString stringWithCapacity:CC_SHA1_DIGEST_LENGTH * 2];
    
    for(int i = 0; i < CC_SHA1_DIGEST_LENGTH; i++)
        [output appendFormat:@"%02x", digest[i]];
    
    return output;
}
//
+(NSString *) md5:(NSString *) input
{
    const char *cStr = [input UTF8String];
    unsigned char digest[16];
    CC_MD5( cStr,(CC_LONG)strlen(cStr), digest ); // This is the md5 call
    
    NSMutableString *output = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    
    for(int i = 0; i < CC_MD5_DIGEST_LENGTH; i++)
        [output appendFormat:@"%02x", digest[i]];
    
    return  output;
    
}
@end
