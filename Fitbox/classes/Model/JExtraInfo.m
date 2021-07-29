//
//  JExtraInfo.m
//  Zold
//
//  Created by Khatib H. on 8/27/14.
//  
//

#import "JExtraInfo.h"

//
//@implementation JNews
//
//@synthesize newsTitleSecond, newsTitle,photos,content, publishDate, authorName;
//
//
//@end

@implementation JPurchaseInfo

@synthesize userId, itemId, purchaseCost, shipAddress, shipCity, shipZipcode,shipState,shipPhone,shipFullName,transactionNo;

@end

@implementation JAddressInfo

-(NSDictionary*)toDictionary
{
    return @{@"shipFirstName":_shipFirstName, @"shipLastName":_shipLastName, @"shipAddress":_shipAddress, @"shipAddressExtra":_shipAddressExtra,  @"shipCity":_shipCity, @"shipState":_shipState, @"shipZipcode":_shipZipcode, @"shipPhone":_shipPhone};
}
-(void)setWithDictionary:(NSDictionary*)dict
{
    _shipFirstName = [dict objectForKey:@"shipFirstName"];
    _shipLastName = [dict objectForKey:@"shipLastName"];
    _shipAddress = [dict objectForKey:@"shipAddress"];
    _shipAddressExtra = [dict objectForKey:@"shipAddressExtra"];
    _shipCity = [dict objectForKey:@"shipCity"];
    _shipState = [dict objectForKey:@"shipState"];
    _shipZipcode = [dict objectForKey:@"shipZipcode"];
    _shipPhone = [dict objectForKey:@"shipPhone"];
}

@end

@implementation JCreditCardInfo

-(NSString*)creditCardInfoAbbreviation
{
    if (_cardNumber) {
        return [NSString stringWithFormat:@"%@ %@", _cardBankName, [_cardNumber substringFromIndex:_cardNumber.length - 4]];
    }
    return @"Not Set";
}

-(NSDictionary*)toDictionary
{
    return @{@"cardNumber":_cardNumber, @"cardCVC":_cardCVC, @"cardExpireMonth":_cardExpireMonth, @"cardExpireYear":_cardExpireYear, @"cardBankName":_cardBankName};
}

-(void)setWithDictionary:(NSDictionary*)dict
{
    _cardNumber = [dict objectForKey:@"cardNumber"];
    _cardCVC = [dict objectForKey:@"cardCVC"];
    _cardExpireMonth = [dict objectForKey:@"cardExpireMonth"];
    _cardExpireYear = [dict objectForKey:@"cardExpireYear"];
//    _cardBillingZipCode = [dict objectForKey:@"cardBillingZipCode"];
    _cardBankName = [dict objectForKey:@"cardBankName"];
}


@end

@implementation ContactsData
@end

@implementation JOrder
@end


@implementation JSoundCloudPlayListInfo

-(id)init
{
    if (self = [super init]) {
        _playlistTracks = [[NSMutableArray alloc] init];
    }
    return self;
}

-(void)setWithDictionary:(NSDictionary*)dict
{
    _playlistId = [NSString stringWithFormat:@"%@",[dict objectForKey:@"id"]];
    if ([dict objectForKey:@"artwork_url"] && [JUtils checkIfValueExists:[dict objectForKey:@"artwork_url"]]) {
//        _playlistImage = [dict objectForKey:@"artwork_url"];
        _playlistImage = [[dict objectForKey:@"artwork_url"] stringByReplacingOccurrencesOfString:@"-large." withString:@"-t500x500."];
    }
    if ([dict objectForKey:@"description"] && [JUtils checkIfValueExists:[dict objectForKey:@"description"]]) {
        _playlistDescription = [dict objectForKey:@"description"];
    }
    _playlistTitle = [dict objectForKey:@"title"];
    _playlistTracksCount = [[dict objectForKey:@"track_count"] intValue];
    
    if (_playlistTracksCount > 0) {
        NSArray *tracks = [dict objectForKey:@"tracks"];
        [_playlistTracks removeAllObjects];
        for (int i=0; i<[tracks count]; i++) {
            JSoundCloudTrackInfo *trackInfo = [[JSoundCloudTrackInfo alloc] init];
            [trackInfo setWithDictionary:[tracks objectAtIndex:i]];
            [_playlistTracks addObject:trackInfo];
        }
        _playlistTracksCount = [_playlistTracks count];
    }
}

@end


@implementation JSoundCloudTrackInfo

-(void)setWithDictionary:(NSDictionary*)dict
{
    _trackDuration = [[dict objectForKey:@"duration"] intValue];
    _trackId = [dict objectForKey:@"id"];
    
    if ([dict objectForKey:@"artwork_url"] && [JUtils checkIfValueExists:[dict objectForKey:@"artwork_url"]]) {
        _trackThumb = [[dict objectForKey:@"artwork_url"] stringByReplacingOccurrencesOfString:@"-large." withString:@"-t500x500."];
    }
    _trackStream = [dict objectForKey:@"stream_url"];
    _trackTitle = [dict objectForKey:@"title"];
    
    NSDictionary *userInfo = [dict objectForKey:@"user"];
    _trackArtist = [userInfo objectForKey:@"username"];
}

@end
