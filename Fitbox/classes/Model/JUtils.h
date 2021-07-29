//
//  JUtils.h
//  Fitbox
//
//  Created by Khatib H. on 11/8/15.
//  
//

#import <Foundation/Foundation.h>

@interface JUtils : NSObject
+ (UIImage*)imageWithImage:(UIImage*)image
              scaledToSize:(CGSize)newSize;
+(void)showMessageAlert:(NSString*)message;
+ (void)showLoadingIndicator:(UIView*)mView message:(NSString*)message;
+ (void)hideLoadingIndicator:(UIView*)mView;

+ (UIImage*) imageWithView:(UIView*)view;

+ (BOOL) validateEmail: (NSString *) candidate;
+ (BOOL) validatePhoneNumber: (NSString *) candidate;
+ (BOOL) validateUsername: (NSString *)screenName;
+(NSString*)stripePhoneNumber:(NSString*) phoneNumber;

+(NSString*)getVideoNameFromVideoURL:(NSString*)videoURL;
+(BOOL)videoDownloaded:(NSString*)videoName;
+(NSString *)getTemporaryURL:(NSString*)videoName;
+(BOOL)checkIfValueExists:(NSObject*)object;
+(UIView*)createSuccessViewWithMessage:(NSString*)message;

+(BOOL)isLocationAvailable;

+ (NSString *)dateTimeStringWithFormatFromDate:(NSDate*)date format:(NSString*)format;
+ (NSString *)dateTimeStringWithFormatFromTimestap:(int)timeStamp format:(NSString*)format;
+ (NSString *)dateTimeStringWithFormatFromTimestapString:(NSString *)timeStr format:(NSString*)format;

+ (NSString *)dateTimeStringFromTimestap:(int)timeStamp;
+ (NSString *)dateTimeStringFromTimestapString:(NSString*)timeStr;
+ (NSString *)dateTimeStringFromDate:(NSDate*)date;
+ (NSString *)md5Of:(NSString*)strValue;
//
//+(void)checkNewMessages;
//+(void)checkListingCount;
@end
