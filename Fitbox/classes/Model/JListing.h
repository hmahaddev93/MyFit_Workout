//
//  JListing.h
//  Fitbox
//
//  Created by Khatib H. on 10/24/16.
//  
//

#import <Foundation/Foundation.h>

@interface JListing : NSObject

@property (nonatomic, retain) NSString *_id;

@property (nonatomic, retain) JUser *user;
//@property (nonatomic, retain) JUser *partner;

@property (nonatomic, retain) NSMutableArray *attendees;
@property (nonatomic, retain) NSNumber *maxAttendeeCount;


@property (nonatomic, retain) NSString *placeName;
@property (nonatomic, retain) NSString *comments;
@property (nonatomic, retain) NSString *classType;
@property (nonatomic, retain) NSNumber *payPref;

@property (nonatomic, retain) NSString *photo;

@property (nonatomic, retain) NSString *genderPref;
@property (nonatomic, retain) NSNumber *price;
@property (nonatomic, retain) NSString *status;
@property (nonatomic, retain) NSString *signupURL;
//@property (nonatomic, retain) NSNumber *expire_date;
@property (nonatomic, retain) NSNumber *event_date;

@property (nonatomic, retain) NSArray *lnglat;

@property (nonatomic, retain) NSNumber *createdAt;
@property (nonatomic, retain) NSNumber *updatedAt;

+(NSMutableDictionary*)allDict;
+(NSMutableArray*)allArray;
-(id)initWithDictionary:(NSDictionary*)dict;
-(id)setDataWithDictionary:(NSDictionary*)dict;
+(JListing*)listingWithId:(NSString*)listingId;
+(JListing*)listingWithIdIfExists:(NSString*)listingId;
+(JListing*)listingWithDictionary:(NSDictionary*)dict;
@end
