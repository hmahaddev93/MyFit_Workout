//
//  JUser.h
//  Zold
//
//  Created by Khatib H. on 9/2/14.
//  
//
//
#import <Foundation/Foundation.h>

@interface JUser : NSObject

@property (nonatomic, retain) NSString *_id;
@property (nonatomic, retain) NSString *fullName;
@property (nonatomic, retain) NSString *username;
@property (nonatomic, retain) NSString *firstName;
@property (nonatomic, retain) NSString *lastName;
//@property (nonatomic, retain) NSString *specData;
@property (nonatomic, retain) NSString *email;
@property (nonatomic, retain) NSString *profilePhoto;
@property (nonatomic, retain) NSString *backgroundPhoto;
@property (nonatomic, retain) NSString *userType;
@property (nonatomic, retain) NSString *siteLink;
@property (nonatomic, retain) NSArray *pushIds;


@property (nonatomic, retain) NSString *token;

@property (nonatomic, retain) NSNumber *createdAt;
@property (nonatomic, retain) NSNumber *updatedAt;





+(NSMutableDictionary*)allDict;
+(NSMutableArray*)allArray;

-(BOOL)isAuthorized;
-(void)logout;
-(id)initWithDictionary:(NSDictionary*)dict;
-(id)setDataWithDictionary:(NSDictionary*)dict;
+(JUser*)userWithId:(NSString*)userId;
+(JUser*)userWithIdIfExists:(NSString*)userId;
+(JUser*)userWithDictionary:(NSDictionary*)dict;



+(void)loadFromNSDefaults;
+(void)saveToNSDefaults:(NSDictionary*)dict;
+(void)clearNSDefaults;
+(void)clearTokenFromNSDefaults;
+(void)loadTokenFromNSDefaults;
+(void)saveTokenToNSDefaults:(NSString*)token;





//+(void)initUserAfterSignup;
+(NSString*)securingData:(NSString*)input;
+ (void)actionAfterLogin;
+ (JUser *)me;

@end
