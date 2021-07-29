//
//  JListing.m
//  Fitbox
//
//  Created by Khatib H. on 10/24/16.
//  
//

#import "JListing.h"

@implementation JListing

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
        self.attendees = [NSMutableArray new];
    }
    return self;
}

- (id)initWithDictionary:(NSDictionary*)dict {
    if (self = [self init]) {
//        self.attendees = [NSMutableArray new];
        [self setDataWithDictionary:dict];
    }
    return self;
}

-(id)setDataWithDictionary:(NSDictionary*)dict
{
    self._id = [dict objectForKey:@"_id"];
    self.placeName = [dict objectForKey:@"placeName"];
    self.comments = [dict objectForKey:@"comments"];
    self.classType = [dict objectForKey:@"classType"];
    self.payPref = [dict objectForKey:@"payPref"];
    
    self.photo = [dict objectForKey:@"photo"];
    self.genderPref = [dict objectForKey:@"genderPref"];
    self.price = [dict objectForKey:@"price"];
    self.status = [dict objectForKey:@"status"];
    self.event_date = [dict objectForKey:@"event_date"];
    self.signupURL = [dict objectForKey:@"signupURL"];
    
    if (!self.event_date || [self.event_date intValue] == 0) {
        self.event_date = [dict objectForKey:@"expire_date"];
    }
    self.lnglat = [[dict objectForKey:@"lnglat"] objectForKey:@"coordinates"];
    
    self.updatedAt = [dict objectForKey:@"updatedAt"];
    self.createdAt = [dict objectForKey:@"createdAt"];

    self.maxAttendeeCount = [dict objectForKey:@"maxAttendeeCount"];

    
    if ([dict objectForKey:@"user"] && ![[dict objectForKey:@"user"] isKindOfClass:[NSNull class]]) {
        if ([[dict objectForKey:@"user"] isKindOfClass:[NSString class]]) {
            self.user = [JUser userWithIdIfExists:[dict objectForKey:@"user"]];
        }
        else
        {
            self.user = [JUser userWithDictionary:[dict objectForKey:@"user"]];
        }
    }
    
    if ([dict objectForKey:@"attendees"] && ![[dict objectForKey:@"attendees"] isKindOfClass:[NSNull class]]) {
        [self.attendees removeAllObjects];
        for (int i=0; i<[[dict objectForKey:@"attendees"] count]; i++) {
            JUser *partner;
            if ([[[dict objectForKey:@"attendees"] objectAtIndex: i] isKindOfClass:[NSString class]]) {
                partner = [JUser userWithIdIfExists:[[dict objectForKey:@"attendees"] objectAtIndex: i]];
            }
            else
            {
                partner = [JUser userWithDictionary:[[dict objectForKey:@"attendees"] objectAtIndex: i]];
            }
            if(partner)
            {
                [self.attendees addObject:partner];
            }
        }
    }
    else if ([dict objectForKey:@"partner"] && ![[dict objectForKey:@"partner"] isKindOfClass:[NSNull class]]) {
        JUser *partner;
        if ([[dict objectForKey:@"partner"] isKindOfClass:[NSString class]]) {
            partner = [JUser userWithIdIfExists:[dict objectForKey:@"partner"]];
        }
        else
        {
            partner = [JUser userWithDictionary:[dict objectForKey:@"partner"]];
        }
        if(partner)
        {
            [self.attendees addObject:partner];
        }
    }
    
    
    return self;
}


+(JListing*)listingWithId:(NSString*)listingId
{
    JListing *listing = [[self allDict] objectForKey:listingId];
    if (!listing) {
        listing = [[JListing alloc] init];
        listing._id = listingId;
        [[self allDict] setObject:listing forKey:listingId];
    }
    return listing;
}

+(JListing*)listingWithIdIfExists:(NSString*)listingId
{
    return [[self allDict] objectForKey:listingId];
}

+(JListing*)listingWithDictionary:(NSDictionary*)dict;
{
    JListing *listing = [self listingWithId:[dict objectForKey:@"_id"]];
    [listing setDataWithDictionary:dict];
    return listing;
}



@end
