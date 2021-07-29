//
//  JClassListingTableViewCell.h
//  Fitbox
//
//  Created by Khatib H. on 2/20/16.
//  
//

#import <UIKit/UIKit.h>

@interface JClassListingTableViewCell : UITableViewCell
{
    IBOutlet UIImageView *mImgUserPhoto;
    IBOutlet UILabel *mLblUsername;
    IBOutlet UILabel *mLblClassType;
    IBOutlet UILabel *mLblPlaceName;
    IBOutlet UILabel *mLblGenderPreference;
    IBOutlet UILabel *mLblPrice;
}

@property (nonatomic, retain) JListing *mListing;
@property (nonatomic, retain) JUser *mPerson;
@property (nonatomic) int rowNumber;

-(void)setInfo:(JListing*)info;

@end
