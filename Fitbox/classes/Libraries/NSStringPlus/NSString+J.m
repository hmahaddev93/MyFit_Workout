//
//  NSString+SB.m
//  SongBooth
//
//  Created by Eric Yang on 9/25/12.
//  Copyright (c) 2012 LogN. All rights reserved.
//

#import "NSString+J.h"

@implementation NSString (J)

+ (NSString *)itemUUID
{
    CFUUIDRef theUUID = CFUUIDCreate(NULL);
    CFStringRef string = CFUUIDCreateString(NULL, theUUID);
    CFRelease(theUUID);
    return (__bridge NSString *)string;
}

+ (NSString *)timeStringForDuration:(NSInteger)duration
{
    NSInteger minutes = duration / 60;
    NSInteger seconds = duration % 60;
    return [NSString stringWithFormat:@"%02d:%02d",(int)minutes, (int)seconds];
}

+ (NSString *)dateTimeStringFromDate:(NSDate *)date
{
    NSTimeInterval interval = [date timeIntervalSinceNow];
    double elapse = 0 - (double)interval;
        NSLog(@"Date: %@", date);
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
+ (NSString *)dateTimeStringFromTimestap:(NSString*)timeStr
{
    NSDate* date=[NSDate dateWithTimeIntervalSince1970:[timeStr doubleValue]];
    NSTimeInterval interval = [date timeIntervalSinceNow];
    double elapse = 0 - (double)interval;
    NSLog(@"Date: %@", date);
    if (elapse < 2 * 60) {
        return @"Just now";
    } else if (elapse < 45 * 60) {
        int minute = round(elapse / 60);
        return [NSString stringWithFormat:@"%d minutes ago", minute];
    } else if (elapse < 1.5 * 60 * 60) {
        return @"About an hour ago";
    } else if (elapse < 23.5 * 60 * 60) {
        int hour = round(elapse / 60 / 60);
        return [NSString stringWithFormat:@"%d hours ago", hour];
    } else if (elapse < 48 * 60 * 60) {
        return @"Yesterday";
    } else if (elapse < 8 * 24 * 60 * 60) {
        int day = floor(elapse / 24 / 60 / 60);
        return [NSString stringWithFormat:@"%d days ago", day];
    } else {
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        formatter.dateFormat = @"MMM dd, yyyy";
        return [formatter stringFromDate:date];
    }
}




+ (NSString *)formattedStringForIAPPrice:(NSNumber *)price forLocal:(NSLocale *)local
{
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    [numberFormatter setFormatterBehavior:NSNumberFormatterBehavior10_4];
    [numberFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
    [numberFormatter setLocale:local];
    return [numberFormatter stringFromNumber:price];
}

@end
