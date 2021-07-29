//
//  JContactTableViewCell.h
//  Zold
//
//  Created by Khatib H. on 7/10/14.
//  
//

#import <UIKit/UIKit.h>

@protocol JContactTableViewCellDelegate

@optional;
-(void) switchChanged: (NSObject *) feedInfo switchValue:(BOOL)switchValue;
@end

@interface JContactTableViewCell : UITableViewCell
//@property (nonatomic, retain) IBOutlet UIImageView *mImgView;
@property (nonatomic, retain) IBOutlet UILabel *mLblFullName;
@property (nonatomic, retain) NSObject *mInfo;
@property (nonatomic, assign) id<JContactTableViewCellDelegate>   delegate;
@end
