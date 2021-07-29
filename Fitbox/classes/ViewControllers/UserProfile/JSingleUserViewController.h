//
//  JSingleUserViewController.h
//  Zold
//
//  Created by Khatib H. on 8/18/14.
//  
//

#import <UIKit/UIKit.h>

@interface JSingleUserViewController : UIViewController
{
    IBOutlet UITableView *mTView;

    IBOutlet UIView             *mViewHeader;
    IBOutlet UIImageView        *mImgBrand;
    IBOutlet UILabel            *mLblBrand;
    
    NSMutableArray *mArrData;
}

@property (nonatomic, retain) JUser           *mPerson;

@end

