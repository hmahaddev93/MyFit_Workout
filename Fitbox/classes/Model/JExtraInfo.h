//
//  JExtraInfo.h
//  Zold
//
//  Created by Khatib H. on 8/27/14.
//  
//

#import <Foundation/Foundation.h>


//@interface JNews : JObject
//
//@property (nonatomic, retain) NSString *newsTitle;
//@property (nonatomic, retain) NSString *newsTitleSecond;
//@property (nonatomic, retain) NSString *content;
//@property (nonatomic, retain) NSString *authorName;
//@property (nonatomic, retain) NSDate *publishDate;
//@property (nonatomic, retain) NSArray *photos;
//
//@end

@interface JPurchaseInfo: NSObject

@property (nonatomic, retain) NSString *userId;
@property (nonatomic, retain) NSString *itemId;

@property (nonatomic, retain) NSNumber *purchaseCost;
@property (nonatomic, retain) NSString *transactionNo;
//@property (nonatomic, retain) NSString *transactionCardId;


@property (nonatomic, retain) NSString *shipFullName;
@property (nonatomic, retain) NSString *shipAddress;
@property (nonatomic, retain) NSString *shipCity;
@property (nonatomic, retain) NSString *shipState;
@property (nonatomic, retain) NSString *shipZipcode;
@property (nonatomic, retain) NSString *shipPhone;


@end

@interface JAddressInfo: NSObject

@property (nonatomic, retain) NSString *shipFirstName;
@property (nonatomic, retain) NSString *shipLastName;
@property (nonatomic, retain) NSString *shipAddress;
@property (nonatomic, retain) NSString *shipAddressExtra;
@property (nonatomic, retain) NSString *shipCity;
@property (nonatomic, retain) NSString *shipState;
@property (nonatomic, retain) NSString *shipZipcode;
@property (nonatomic, retain) NSString *shipPhone;

-(NSDictionary*)toDictionary;
-(void)setWithDictionary:(NSDictionary*)dict;

@end

@interface JCreditCardInfo: NSObject
@property (nonatomic, retain) NSString *cardNumber;
@property (nonatomic, retain) NSString *cardCVC;
@property (nonatomic, retain) NSString *cardExpireMonth;
@property (nonatomic, retain) NSString *cardExpireYear;
//@property (nonatomic, retain) NSString *cardBillingZipCode;
@property (nonatomic, retain) NSString *cardBankName;

-(NSDictionary*)toDictionary;
-(void)setWithDictionary:(NSDictionary*)dict;

-(NSString*)creditCardInfoAbbreviation;
@end

@interface ContactsData: NSObject

@property (nonatomic, retain) NSString *firstNames;
@property (nonatomic, retain) NSString *lastNames;
@property (nonatomic, retain) UIImage *image;
@property (nonatomic, retain) NSString *phoneNumber;
@property (nonatomic, retain) NSString *email;

@end

@interface JOrder: NSObject

//@property (nonatomic, strong)   NSString *itemSize;
@property (nonatomic, strong)   NSString *itemSizeTop;
@property (nonatomic, strong)   NSString *itemSizeBottom;
@property (nonatomic, strong)   JItem *itemObject;
@property (nonatomic)           float itemCost;

@end


@interface JSoundCloudPlayListInfo: NSObject

@property (nonatomic, strong)   NSString *playlistId;
@property (nonatomic, strong)   NSString *playlistTitle;
@property (nonatomic, strong)   NSString *playlistImage;
@property (nonatomic, strong)   NSString *playlistDescription;

@property (nonatomic, strong)   NSMutableArray *playlistTracks;

@property (nonatomic)   int playlistTracksCount;

-(void)setWithDictionary:(NSDictionary*)dict;

@end

@interface JSoundCloudTrackInfo: NSObject

@property (nonatomic, strong)   NSString *trackId;
@property (nonatomic, strong)   NSString *trackThumb;
@property (nonatomic, strong)   NSString *trackStream;
@property (nonatomic, strong)   NSString *trackArtist;
@property (nonatomic, strong)   NSString *trackTitle;
@property (nonatomic)   int trackDuration;

-(void)setWithDictionary:(NSDictionary*)dict;

@end


