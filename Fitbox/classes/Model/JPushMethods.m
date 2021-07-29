//
//  JPushMethods.m
//  Zold
//
//  Created by Khatib H. on 9/2/14.
//  


#import "JPushMethods.h"
#import <OneSignal/OneSignal.h>

@implementation JPushMethods


+ (void)likedPost:(JItem*)post
{
    if ([post.user._id isEqualToString:[JUser me]._id]) {
        return;
    }
    
    if (post.user.pushIds && [post.user.pushIds count]>0) {
        NSDictionary *data1 = [NSDictionary dictionaryWithObjectsAndKeys:
                               NOTIF_TYPE_LIKE, @"notifType",//Message
                               [JUser me]._id,@"sender",
                               post._id,@"item",
                               nil];
        
        [self sendPushMessage:post.user.pushIds pushMsg:[NSString stringWithFormat:@"%@ liked your item", [JUser me].fullName] pushData:data1];
    }
    
}

+ (void)acceptListing:(JListing*)listing
{
    if ([listing.user._id isEqualToString:[JUser me]._id]) {
        return;
    }
    if (listing.user.pushIds && [listing.user.pushIds count]>0) {
        NSDictionary *data1 = [NSDictionary dictionaryWithObjectsAndKeys:
                               NOTIF_TYPE_ACCEPT_LISTING, @"notifType",//Message
                               [JUser me]._id,@"sender",
                               listing._id,@"listing",
                               nil];
        
        [self sendPushMessage:listing.user.pushIds pushMsg:[NSString stringWithFormat:@"%@ accepted your listing", [JUser me].fullName] pushData:data1];
    }
}

+ (void)sendPushMessage:(NSArray *)receiver pushMsg:(NSString *)pushMsg pushData:(NSDictionary*)pushData
{
    //  TODO: Needto    integratePushWoosh
    [OneSignal postNotification:@{
                                  @"contents" : @{@"en": pushMsg},
                                  @"data" : pushData,
                                  @"include_player_ids": receiver
                                  }];
    
//    PFQuery *pushQuery = [PFInstallation query];
//    
//    [pushQuery whereKey:@"owner" equalTo:receiver];
//    PFPush *push = [[PFPush alloc] init];
//    [push setQuery:pushQuery];
//    [push setData:pushMsg];
//    [push sendPushInBackground];
    
}

+ (void)handlePushUserInfo:(NSDictionary *)userInfo withAlertDelegate:(id)delegate
{
//    NSString *mNotifType=[userInfo valueForKey:kPushType];
//    
//    NSLog(@"Alert Info: %@", userInfo);
//    if([mNotifType isEqualToString:NOTIF_TYPE_LIKE]||[mNotifType isEqualToString:NOTIF_TYPE_FOLLOW])
//    {
//        return;
//    }
//        [PFPush handlePush:userInfo];
    return;
}

@end
