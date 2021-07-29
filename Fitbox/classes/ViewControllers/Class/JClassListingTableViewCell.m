//
//  JClassListingTableViewCell.m
//  Fitbox
//
//  Created by Khatib H. on 2/20/16.
//  
//

#import "JClassListingTableViewCell.h"
#import "JAmazonS3ClientManager.h"

@implementation JClassListingTableViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)setInfo:(JListing *)info
{
    _mListing = info;
    
    [self initView];
}

-(void)initView
{
    

    _mPerson = _mListing.user;
    
    mImgUserPhoto.image = nil;
    
    if (_rowNumber % 2 == 0) {
        self.contentView.backgroundColor = [UIColor whiteColor];
        mImgUserPhoto.image = [UIImage imageNamed:@"iconPerson56"];
    }
    else
    {
        self.contentView.backgroundColor = MAIN_COLOR_LIGHT_GRAY;
        mImgUserPhoto.image = [UIImage imageNamed:@"iconPerson56_White"];
    }

    
    if (_mPerson) {
        mLblUsername.text = _mPerson.username;
        NSLog(@"User Photo: %@", _mPerson.profilePhoto);
        if (_mPerson.profilePhoto && (![_mPerson.profilePhoto isEqualToString:@""])) {
            [mImgUserPhoto setImageWithURL:[[JAmazonS3ClientManager defaultManager] cdnUrlForProfilePhoto:_mPerson.profilePhoto]];
        }
    }
    else
    {
        // TODO:Need  to make sure it does not fallin here
//        [JPerson loadPersonWithWithID:[_mListing objectForKey:kUserId] completionBlock:^(PFObject *object) {
//            if(object)
//            {
//                _mPerson = object;
//                mLblUsername.text = [_mPerson objectForKey:kUserUserName];
//                [mImgUserPhoto setImageWithURL:[[JAmazonS3ClientManager defaultManager] cdnUrlForProfilePhoto:[_mPerson objectForKey:kUserProfilePhoto]]];
//            }
//        }];
    }
    
    mLblClassType.text = _mListing.classType;
    
    mLblPlaceName.text = [_mListing.placeName uppercaseString];
    
    NSString *genderPrefString = @"M/F";
    if ([_mListing.genderPref isEqualToString:@"M"]) {
        genderPrefString = @"M";
    }
    else if([_mListing.genderPref isEqualToString:@"F"]) {
        genderPrefString = @"F";
    }
    
    mLblGenderPreference.text = genderPrefString;

    if ([_mListing.payPref boolValue]) {
        mLblPrice.text = @"FREE";
    }
    else
    {
        mLblPrice.text = [NSString stringWithFormat:@"$%.2f", [_mListing.price doubleValue]];
    }
}

@end
