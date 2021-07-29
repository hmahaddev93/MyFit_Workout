//
//  JUtils.m
//  Fitbox
//
//  Created by Khatib H. on 11/8/15.
//  
//

#import "JUtils.h"
#import <CommonCrypto/CommonDigest.h>

@implementation JUtils

+ (UIImage*)imageWithImage:(UIImage*)image
              scaledToSize:(CGSize)newSize
{
    CGFloat width = image.size.width;
    CGFloat height = image.size.height;
    
    CGFloat scaleRatio =newSize.width/width;
    if(scaleRatio<(newSize.height/height))
    {
        scaleRatio=newSize.height/height;
    }
    
    
    UIGraphicsBeginImageContext( newSize );
    //    [image drawInRect:CGRectMake(0,0,newSize.width,newSize.height)];
    [image drawInRect:CGRectMake((newSize.width-width*scaleRatio)/2.0,(newSize.height-height*scaleRatio)/2.0,width*scaleRatio,height*scaleRatio)];
    UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newImage;
}

+ (UIImage*) imageWithView:(UIView*)view
{
    UIGraphicsBeginImageContextWithOptions(view.bounds.size, view.opaque, 0.0);
    [view.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage* img = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return img;
}

+(void)showMessageAlert:(NSString*)message
{
    //    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:APP_NAME message:message delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
    //    [alert show];
    
    //    NSLog(@"%@", error);
    dispatch_async(dispatch_get_main_queue(),  ^ {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle: APP_NAME message: message delegate: self cancelButtonTitle: @"Ok" otherButtonTitles: nil];
        [alertView show];
        //        [mProgress hide: YES];
    });
}

+ (void)showLoadingIndicator:(UIView*)mView message:(NSString*)message
{
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:mView animated:YES];
    hud.labelText = message;
}

+ (void)hideLoadingIndicator:(UIView*)mView
{
    [MBProgressHUD hideAllHUDsForView:mView animated:YES];
}


+(NSString*)getVideoNameFromVideoURL:(NSString*)videoURL
{
    NSRange mRange = [videoURL rangeOfString:@"/" options:NSBackwardsSearch];
    NSString *mString = [videoURL substringFromIndex:mRange.location+mRange.length];
    mRange = [mString rangeOfString:@"?"];
    if(mRange.location == NSNotFound)
    {
        return mString;
    }
    mString = [mString substringToIndex:mRange.location];
    return mString;
}

+(BOOL)videoDownloaded:(NSString*)videoName
{
    BOOL exist= [[NSFileManager defaultManager] fileExistsAtPath:[self getTemporaryURL:videoName]];
    //    NSLog(@"Exist: %d", exist);
    return exist;
}

+(BOOL)checkIfValueExists:(NSObject*)object
{
    if (object && ![object isEqual:[NSNull null]]) {
        return true;
    }
    return false;
}
+(NSString *)getTemporaryURL:(NSString*)videoName
{
    NSString* documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString* videoPath=[documentsPath stringByAppendingString:@"/media/"];
    NSString* filePath;
    filePath = [videoPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@",videoName]];
    return filePath;
}

+ (BOOL) validateEmail: (NSString *) candidate
{
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,6}";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    
    return [emailTest evaluateWithObject:candidate];
}

+ (BOOL) validatePhoneNumber: (NSString *) candidate
{
    //    NSString *phoneNumberRegex = @"[0-9+-()]{1,20}";
    NSString *phoneNumberRegex = @"[0-9+-]{1,20}";
    NSPredicate *phoneNumberTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", phoneNumberRegex];
    
    return [phoneNumberTest evaluateWithObject:candidate];
}

+(NSString*)stripePhoneNumber:(NSString*) phoneNumber
{
    return [phoneNumber stringByReplacingOccurrencesOfString:@"[^0-9]" withString:@"" options:NSRegularExpressionSearch range:NSMakeRange(0, [phoneNumber length])];
    //    return [phoneNumber stringByReplacingOccurrencesOfRegex:@"[^0-9]" withString:@""];
}

+ (BOOL) validateUsername: (NSString *)screenName
{
    
    NSString* filterString = @"[A-Za-z]{1}[A-Z0-9a-z_.-]*";
    NSPredicate *screenNameTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", filterString];// NSPredicate(format: "SELF MATCHES %@", filterString)
    
    return [screenNameTest evaluateWithObject:screenName];
    //    if (screenNameTest.evaluateWithObject(screenName) == false) {
    //        return false;
    //    }
    //
    //    return true;
    
}


+ (NSString *)dateTimeStringWithFormatFromDate:(NSDate*)date format:(NSString*)format
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:format];
    return [dateFormatter stringFromDate:date];
}

+ (NSString *)dateTimeStringWithFormatFromTimestap:(int)timeStamp format:(NSString*)format
{
    NSDate* date=[NSDate dateWithTimeIntervalSince1970:timeStamp];
    return [JUtils dateTimeStringWithFormatFromDate:date format:format];
}


+ (NSString *)dateTimeStringWithFormatFromTimestapString:(NSString *)timeStr format:(NSString*)format
{
    NSDate* date=[NSDate dateWithTimeIntervalSince1970:[timeStr doubleValue]];
    return [JUtils dateTimeStringWithFormatFromDate:date format:format];
}

+ (NSString *)dateTimeStringFromTimestap:(int)timeStamp
{
    NSDate* date=[NSDate dateWithTimeIntervalSince1970:timeStamp];
    return [JUtils dateTimeStringFromDate:date];
}


+ (NSString *)dateTimeStringFromTimestapString:(NSString *)timeStr
{
    NSDate* date=[NSDate dateWithTimeIntervalSince1970:[timeStr doubleValue]];
    return [JUtils dateTimeStringFromDate:date];
}


+ (NSString *)dateTimeStringFromDate:(NSDate*)date
{
    NSTimeInterval interval = [date timeIntervalSinceNow];
    double elapse = 0 - (double)interval;
    //    NSLog(@"Date: %@", date);
    if (elapse < 60) {
        if(elapse<1)
            elapse=1;
        return [NSString stringWithFormat:@"%ds", (int)elapse];
    }
    else if (elapse < 60 * 60) {
        int minute = round(elapse / 60);
        return [NSString stringWithFormat:@"%dm", minute];
        //    } else if (elapse < 1.5 * 60 * 60) {
        //        return @"An hour";
    } else if (elapse < 24 * 60 * 60) {
        int hour = round(elapse / 60 / 60);
        return [NSString stringWithFormat:@"%dh", hour];
        //    } else if (elapse < 48 * 60 * 60) {
        //        return @"Yesterday";
    } else if (elapse < 7 * 24 * 60 * 60) {
        int day = floor(elapse / 24 / 60 / 60);
        return [NSString stringWithFormat:@"%dd", day];
    } else//(elapse < 365 * 24 * 60 * 60)
    {
        int day = floor(elapse / 24 / 60 / 60/7);
        return [NSString stringWithFormat:@"%dw", day];
        //    } else if (elapse < 365 * 24 * 60 * 60) {
        //        int day = floor(elapse / 24 / 60 / 60/30);
        //        return [NSString stringWithFormat:@"%dm", day];
        //    }
        //    else
        //    {
        //        int day = floor(elapse / 24 / 60 / 60/365);
        //        return [NSString stringWithFormat:@"%dy", day];
        //
    }
}

+(UIView*)createSuccessViewWithMessage:(NSString*)message
{
    UIView *mView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
    
    UIView *mViewContent = [[UIView alloc] initWithFrame:CGRectMake((SCREEN_WIDTH - 255)/2.0, 133, 255, 192)];
    mViewContent.backgroundColor = [UIColor colorWithRed:46.0/255.0 green:46.0/255.0 blue:46.0/255.0 alpha:0.9];
    mViewContent.layer.masksToBounds = true;
    mViewContent.layer.cornerRadius = 10;
    [mView addSubview:mViewContent];
    
    UIImageView *mImgTick = [[UIImageView alloc] initWithFrame:CGRectMake(68, 93, 115, 66)];
    mImgTick.image = [UIImage imageNamed:@"btnIconBigTick"];
    mImgTick.contentMode = UIViewContentModeCenter;
    [mViewContent addSubview:mImgTick];
    
    UILabel *mLblMessage = [[UILabel alloc] initWithFrame:CGRectMake(29, 21, 196, 64)];
    mLblMessage.font = [UIFont fontWithName:FONT_NAME_AAUX_PROREGULAR size:19];
    mLblMessage.textColor = [UIColor whiteColor];
    mLblMessage.text = message;
    mLblMessage.numberOfLines = 0;
    mLblMessage.textAlignment = NSTextAlignmentCenter;
    [mViewContent addSubview:mLblMessage];
    
    return mView;
}

+(BOOL)isLocationAvailable
{
    if (([Engine myLocation].latitude == 0)  && ([Engine myLocation].longitude == 0)){
        return false;
    }
    return true;
}

+ (NSString *)md5Of:(NSString*)strValue
{
    const char *cStr = [strValue UTF8String];
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    CC_MD5( cStr, (int)strlen(cStr), result ); // This is the md5 call
    return [NSString stringWithFormat:
            @"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
            result[0], result[1], result[2], result[3],
            result[4], result[5], result[6], result[7],
            result[8], result[9], result[10], result[11],
            result[12], result[13], result[14], result[15]
            ];
}

@end
