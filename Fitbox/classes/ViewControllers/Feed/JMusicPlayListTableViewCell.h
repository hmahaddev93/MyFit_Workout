//
//  JMusicPlayListTableViewCell.h
//  Fitbox
//
//  Created by Khatib H. on 11/23/15.
//  
//

#import <UIKit/UIKit.h>

@interface JMusicPlayListTableViewCell : UITableViewCell
@property (nonatomic, strong) IBOutlet UILabel *mLblTitle;
@property (nonatomic, strong) IBOutlet UILabel *mLblDesc;
@property (nonatomic, strong) IBOutlet UIView *mViewRedBar;
@property (nonatomic, strong) IBOutlet NSLayoutConstraint *mConstraintRedWidth;
@property (nonatomic, strong) IBOutlet UIImageView *mImgThumb;
-(void)setInfo:(JSoundCloudPlayListInfo*)info;
@end
