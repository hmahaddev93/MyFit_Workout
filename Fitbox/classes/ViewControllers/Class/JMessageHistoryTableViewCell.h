//
//  JMessageHistoryTableViewCell.h
//  Fitbox
//
//  Created by Khatib H. on 2/23/16.
//  
//

#import <UIKit/UIKit.h>
#import "CustomBadge.h"

@interface JMessageHistoryTableViewCell : UITableViewCell
{
    IBOutlet UIImageView *mImgUserPhoto;
    IBOutlet UILabel *mLblUsername;
    IBOutlet UILabel *mLblLastMessage;
    IBOutlet UILabel *mLblMessageDate;
    
    IBOutlet UIView *mViewBadge;
    IBOutlet UILabel *mLblBadge;
}

@property (nonatomic, retain) JMessageHistory *mMessageHistory;
@property (nonatomic, retain) JUser *mPerson;

-(void)setInfo:(JMessageHistory*)info;

@end
