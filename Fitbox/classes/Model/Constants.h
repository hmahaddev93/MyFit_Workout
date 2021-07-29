//
//  Contants.h
//  fitbox
//
//  Created by Khatib H. on 9/2/14.
//  

#ifndef Contants_h
#define Contants_h

// user defaults
#define kUserDefaultsCurrentLanguageKey       @"_langKey"

// lang options
#define kLanguages                            [NSArray arrayWithObjects:@"en", @"he", nil]
#define kDefaultLanguage                      @"en"
#define kBgQueue dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)

#define PREFERED_PROFILE_WITH 200
#define PREFERED_PROFILE_HEIGHT 200
#define PREFERED_PROFILE_RATIO 1//1136.0/640.0


// Notifications
#define APP_NAME [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleDisplayName"]

#define kInstallationOwner @"owner"

typedef enum  {
    J_APP_STATUS_FOR_PUSH_GERNAL,
    J_APP_STATUS_FOR_PUSH_WITHOUT_ACTION,
    J_APP_STATUS_FOR_PUSH_IGNORE
}J_APP_STATUS_FOR_PUSH;

#define kPushedAlertMsg @"alert"
#define kPushedItemId @"item"
#define kPushedMessageId @"message"
//#define kPushHasAction @"hasAction"
#define kPushedSenderId @"sender"
#define kPushType @"notifType"


typedef enum  {
    J_PUSH_TYPE_GENERAL = 0,
    J_PUSH_TYPE_FOLLOWED = 1010,
    J_PUSH_TYPE_POST_LIKED = 1020,
    J_PUSH_TYPE_POST_COMMENT = 1030
} J_PUSH_TYPE;


#define NOTIF_TYPE_LIKE @"1"
#define NOTIF_TYPE_MESSAGE @"2"
#define NOTIF_TYPE_FOLLOW @"3"
#define NOTIF_TYPE_ACCEPT_LISTING @"4"


#define PAGE_ABOUT      40
#define PAGE_TIPS      41
#define PAGE_BUYERPROTECTION      42

#define ITEM_INPUT_ITEM_NAME        11
#define ITEM_INPUT_CATEGORY        12
#define ITEM_INPUT_SIZE        13
#define ITEM_INPUT_BRAND        14
#define ITEM_INPUT_CONDITION        15
#define ITEM_INPUT_DESCRIPTION        16
#define ITEM_INPUT_COLOR        17
#define ITEM_INPUT_RETAILPRICE        18
#define ITEM_INPUT_LISTINGPRICE        19
#define ITEM_INPUT_FILTERPRICE        20

#define SIZE_GENERIC_TAG         100
#define SIZE_NECK_TAG         120
#define SIZE_WAIST_TAG         140
#define SIZE_SHOE_TAG         160


//
//#define WEB_SERVICES_URL              @"http://192.168.3.118:3000/api/"
//#define WEB_SERVICE_CHAT_URL @"http://192.168.3.118:3001"
//
#define WEB_SERVICES_URL              @"http://52.86.127.157/api/"
#define WEB_SERVICE_CHAT_URL @"http://52.86.127.157:3001"



#define IS_OS_8_OR_LATER ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)


//#define FONT_FAMILY_REGULAR_NAME   @"Helvetica"
//#define FONT_FAMILY_BOLD_NAME   @"Helvetica-Bold"
#define FONT_FAMILY_REGULAR_NAME   @"Aaux ProRegular"
#define FONT_FAMILY_BOLD_NAME   @"Aaux ProBold"


#define J_ITEM_PHOTO_LIB_BUCKET @"fitbox.photo"
#define J_ITEM_PHOTO_THUMB_LIB_BUCKET @"fitbox.photo.thumb"

#define J_ITEM_VIDEO_LIB_BUCKET @"fitbox.video"
#define J_ITEM_VIDEO_THUMB_LIB_BUCKET @"fitbox.video.thumb"


#define J_PROFILE_PHOTO_LIB_BUCKET @"fitbox.profile.photo"
#define J_PROFILE_PHOTO_THUMB_LIB_BUCKET @"fitbox.profile.photo.thumb"
#define J_PROFILE_BG_LIB_BUCKET @"fitbox.profile.bg"

#define J_MESSAGE_PHOTO_LIB_BUCKET @"fitbox.message.photo"
#define J_MESSAGE_PHOTO_THUMB_LIB_BUCKET @"fitbox.message.photo.thumb"

#define FEED_VIEW_MY_CLOSET         1
#define FEED_VIEW_MY_FOLLOWING         2
//#define FEED_VIEW_FAVOURITE       3
//#define FEED_VIEW_WISHLIST        4

#define FEED_VIEW_FRIEND_PAGE      6

#define LikedPhotoCallbackFinishedNotification @"LikedPhotoCallbackFinishedNotification"

#define SHOPPING_CART_NOTIFICATION @"SHOPPING_CART_NOTIFICATION"


#define ITEM_LIKED_NOTIFICATION @"ITEM_LIKED_NOTIFICATION"

#define RELOAD_TABLEVIEW_NOTIFICATION @"RELOAD_TABLEVIEW_NOTIFICATION"
#define REFRESH_TABLEVIEW_NOTIFICATION @"REFRESH_TABLEVIEW_NOTIFICATION"

#define SIZE 128.0

#define HOME_LEFTBTN_TOUCH                    @"HOME_LEFTBTN_TOUCH"
#define HOME_RIGHTBTN_TOUCH                   @"HOME_RIGHTBTN_TOUCH"

#define LEFT_BTN_TOUCH                        @"LEFT_BTN_TOUCH"
#define BACK_TO_MAIN_VIEW                       @"BACK_TO_MAIN_VIEW"
#define BACK_TO_LOGIN_VIEW                       @"BACK_TO_LOGIN_VIEW"

#define DID_LOGIN                             @"DID_LOGIN"
#define CLOSE_SIDE_VIEW                             @"CLOSE_SIDE_VIEW"
#define SEARCH                                @"SEARCH"

#define MAIN_COLOR_PINK      [UIColor colorWithRed:240.0/255.0 green:66.0/255.0 blue:42.0/255.0 alpha:1]
#define MAIN_COLOR_LIGHT_GRAY      [UIColor colorWithRed:239.0/255.0 green:239.0/255.0 blue:239.0/255.0 alpha:1]
#define MAIN_COLOR_GRAY      [UIColor lightGrayColor]

//#define DEBUG                                 1
//#define SCROLL_UPDATE_DISTANCE                 40

#define LOGOUT                                @"LOGOUT"

#define MAP_SHOW_DISTANCE_FOR_PLACE         0.005

#define LISTING_RADIUS              0.3


#define ITEM_TYPE_PRODUCT      @"product"
#define ITEM_TYPE_NEWS      @"news"
#define ITEM_TYPE_VIDEO      @"video"
#define ITEM_TYPE_PHOTO      @"photo"
#define ITEM_TYPE_PLAYLIST      @"playlist"

#define USER_TYPE_SELLER        @"seller"

#define kClassUser                 @"_User"

#define kUserFullName           @"fullName"
#define kUserUserName           @"username"
#define kUserFirstName           @"firstName"
#define kUserLastName           @"lastName"
//#define kUserSpecData           @"specData"
#define kUserEmail           @"email"
#define kUserProfilePhoto           @"profilePhoto"
#define kUserBackgroundPhoto           @"backgroundPhoto"
#define kUserUserType           @"userType"
#define kUserUserStatus           @"userStatus"
#define kUserItemCount           @"itemCount"
#define kUserSiteLink           @"siteLink"

#define kClassItem                 @"JItem"

#define kItemUserID                 @"user"
#define kItemItemName                 @"item_name"
#define kItemDescription                 @"description"
#define kItemPhotos                 @"photos"
#define kItemVideo                 @"video"
#define kItemTopBottom                 @"topBottom"

#define kItemShippingOption                 @"shippingOption"
#define kItemShippingPeriod                 @"shippingPeriod"
#define kItemRetailPrice                 @"retailPrice"
#define kItemListingPrice                 @"listingprice"
#define kItemShouldShow                 @"shoudShow"
#define kItemLikesCount                 @"likesCount"
#define kItemItemType                 @"itemType"




#define kClassFollow                 @"JFollows"
#define kClassLike                 @"JLikes"

#define kClassNotification                 @"JNotification"
#define kClassPurchase                 @"JPurchase"
#define kClassWatchedItem                 @"JWatchedItem"



#define kClassListing @"JListing"
#define kListingClassType        @"classType"
#define kListingPlaceName          @"placeName"
#define kListingPlaceGeopoint           @"lnglat"
#define kListingGenderPreference    @"genderPref"
#define kListingPrice @"price"
#define kListingPayPreference @"payPref"
#define kListingComments      @"comments"
#define kListingPhoto          @"photo"
#define kListingStatus          @"status"
#define kListingPartnerId          @"partner"

#define kListingExpireDate          @"expire_date"
#define kListingEventDate          @"event_date"
#define kListingMaxAttendeeCount          @"maxAttendeeCount"


#define kListingStatusOpen  @"open"
#define kListingStatusClosed @"closed"
#define kListingStatusExpired @"expired"
#define kListingStatusCancelled @"cancelled"

#define kClassChatHistory @"JMessageHistory"
#define kChatHistoryListingID @"listing"
#define kChatHistoryListingPosterID @"listingPoster"
#define kChatHistoryLastMessage @"lastMessage"
#define kChatHistoryRoomID @"roomID"

#define kChatHistoryUnreadCountUser @"unreadCountUser"
#define kChatHistoryUnreadCountPoster @"unreadCountPoster"

#define kClassMessages @"JMessages"
#define kMessagesRoomID @"roomID"
#define kMessagesMessage @"message"
#define kMessagesType @"type"





#define kUserId                 @"user"
#define kUpdatedAt                 @"updatedAt"
#define kCreatedAt                 @"createdAt"

#define FONT_NAME_AAUX_PRO @"Aaux Pro"
#define FONT_NAME_AAUX_PROREGULAR @"Aaux ProRegular"
#define FONT_NAME_AAUX_PROBOLD @"Aaux ProBold"
#define FONT_NAME_LULO_CLEAN @"Lulo Clean"



#define SIZE_INFO          @"sizeInfo"
#define SIZE_TOPS          @"TOPS"
#define SIZE_BOTTOMS          @"BOTTOMS"

#define SIZE_PAGE_TOPS          @"SIZE_PAGE_TOPS"
#define SIZE_PAGE_BOTTOMS          @"SIZE_PAGE_BOTTOMS"
#define SIZE_PAGE_BOTH          @"SIZE_PAGE_BOTH"
#define SIZE_PAGE_MY_SIZE          @"SIZE_PAGE_MY_SIZE"


typedef void(^J_IN_PROGRESS_CALL_BACK_BLOCK)(float progress);
typedef void(^J_DID_COMPLETE_CALL_BACK_BLOCK)(NSString *obj);//NSObject *obj




#define NOTIF_CLASS_LISTING_COUNT_UPDATED      @"NOTIF_CLASS_LISTING_COUNT_UPDATED"

#define NOTIF_MESSAGE_COUNT_UPDATED      @"NOTIF_MESSAGE_COUNT_UPDATED"
#define NOTIF_REMOVE_LISTING      @"NOTIF_REMOVE_LISTING"
#define NOTIF_DISCOVER_CLICKED_AGAIN      @"NOTIF_DISCOVER_CLICKED_AGAIN"

#define IS_IPHONE5 ( (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone && [UIScreen mainScreen].bounds.size.height == 568) ? YES : NO )
#define IS_IPHONE (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)

#define SCREEN_HEIGHT [UIScreen mainScreen].bounds.size.height
#define SCREEN_WIDTH [UIScreen mainScreen].bounds.size.width


#define kTempMoviePath		([NSTemporaryDirectory() stringByAppendingPathComponent:@"temp.mov"])
#define kTempMovieURL		([NSURL fileURLWithPath:kTempMoviePath])


#define CURRENT_USER_NSDEFAULT @"current_user"

#define SOUND_CLOUD_AUDIO_URL                       @"https://api.soundcloud.com/tracks/%@/stream?client_id="SOUND_CLOUD_ID


#endif
