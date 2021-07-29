//
//  NSString+SB.h
//  SongBooth
//
//  Created by Eric Yang on 9/25/12.
//  Copyright (c) 2012 LogN. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (J)

+ (NSString *)itemUUID;
+ (NSString *)timeStringForDuration:(NSInteger)duration;
+ (NSString *)dateTimeStringFromDate:(NSDate *)date;
+ (NSString *)formattedStringForIAPPrice:(NSNumber *)price forLocal:(NSLocale *)local;
+ (NSString *)dateTimeStringFromTimestap:(NSString*)timeStr;
//+ (NSString *)dateTimeStringFromDate:(NSDate *)date;
@end
