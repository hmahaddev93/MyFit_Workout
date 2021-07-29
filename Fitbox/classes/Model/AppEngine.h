//
//  AppEngine.h
//  Zold
//
//  Created by Khatib H. on 9/2/14.
//  

#import <UIKit/UIKit.h>


#import "JUser.h"
#import "JItem.h"
#import "JListing.h"
//#import "JPerson.h"
#import "JExtraInfo.h"
#import "JMessageHistory.h"
#import "JMessage.h"
#import <CoreLocation/CoreLocation.h>

#define Engine  [AppEngine getInstance]

#define LocalizedString(key) \
    [[Engine currentBundle] localizedStringForKey:(key) value:@"" table:nil]

#define isPhone5    [[UIScreen mainScreen] bounds].size.height > 480 && UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone

#define degreesToRadian(x) (M_PI * (x) / 180.0)

@interface AppEngine : NSObject<UIAlertViewDelegate>
{
    NSArray                 * _languages;
    NSString                * _currentLang;
    NSBundle                * _currentBundle;
    
    NSString                * _gSrvTime;
    NSString                * _gSearchEth;
}

@property (nonatomic, retain) NSArray            * languages;
@property (nonatomic, retain) NSString           * currentLang;
@property (nonatomic, retain, readonly) NSBundle * currentBundle;

@property (nonatomic, retain) NSString           * gSrvTime;
@property (nonatomic, retain) NSString           * gSearchEth;

@property (nonatomic, retain) NSString           * gPushId;

@property (nonatomic) int gNewMessageCount;
@property (nonatomic) int gClassListingCount;

@property (nonatomic) BOOL            isFirstRun;

@property (nonatomic) BOOL            WISH_LIST_NEED_UPDATE;

//@property (nonatomic, retain) NSMutableDictionary      * gPersonsDict;
//@property (nonatomic, retain) NSMutableDictionary      * gListingsDict;
//@property (nonatomic, retain) NSMutableDictionary      * gChatHistoryDictWithID;
//@property (nonatomic, retain) NSMutableDictionary      * gChatHistoryDictWithRoom;

@property (nonatomic, retain) NSMutableArray      * gShoppingCart;

@property (nonatomic, retain) JAddressInfo      * gAddress;
@property (nonatomic, retain) JCreditCardInfo      * gCreditCard;

//@property (nonatomic, retain) NSMutableArray           * gFeedList;
//@property (nonatomic, retain) NSMutableDictionary      * gFeedDict;



@property (nonatomic) BOOL            isBackAction;
@property (nonatomic) BOOL           gStatusForPush;

@property (nonatomic, retain) NSMutableArray           * gSearchResult;
@property (nonatomic, retain) NSMutableArray           * gMyPostList;

@property (nonatomic, retain) NSMutableArray           * gSoundCloudPlayLists;
@property (nonatomic, retain) NSMutableDictionary           * gSoundCloudPlayDict;

@property (nonatomic, retain) NSMutableDictionary           * gFlashDict;

@property (nonatomic, retain) NSMutableDictionary           * gSizeInfo;


@property (nonatomic, retain) NSArray           * gSizeList;

@property (nonatomic, retain) UIImage           * gImg;



@property (nonatomic, retain) NSArray           * gColorList;

@property (nonatomic, retain) NSMutableArray *likeItems;

@property (nonatomic) int newMessage;


@property (retain, nonatomic) CLLocationManager* locationManager;
@property (retain, nonatomic) CLLocation* lastLocation;
@property (nonatomic) CLLocationCoordinate2D myLocation;


@property(strong, nonatomic)UIViewController *currentStudioVC;
@property(strong, nonatomic)NSDictionary *pushUserInfo;
@property(readwrite, nonatomic)J_APP_STATUS_FOR_PUSH statusForPush;

+ (NSURL *)testingLocalMovieUrl;
+ (NSURL *)testingLocalAudioUrl;


+ (UIColor *) colorFromString:(NSString *)colorStr;

#pragma mark Check the reachability

- (void)checkNetworkReachability;
- (void)showAlertViewForLogin;


#pragma mark Status bar methods
//- (void) setBottomBarHidden : (bool) hidden;

-(void)actionAfterLogin;
-(void)saveInfoToUserDefault;
-(void)loadInfoFromUserDefaults;



#pragma mark singleton
+ (id)getInstance;

#pragma mark
- (void)setValue:(id)value forKey:(NSString *)key;
- (id)valueForKey:(NSString *)key;
- (NSString *)base64Encode:(NSString *)plainText;
- (NSString *)base64Decode:(NSString *)base64String;

@end


@implementation UIView (FindFirstResponder)
- (id)findFirstResponder
{
    if (self.isFirstResponder) {
        return self;
    }
    for (UIView *subView in self.subviews) {
        id responder = [subView findFirstResponder];
        if (responder) return responder;
    }
    return nil;
}
@end

