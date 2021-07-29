//
//  JConfirmationViewController.h
//  Zold
//
//  Created by Khatib H. on 8/25/14.
//  
//

#import <UIKit/UIKit.h>

@interface JConfirmationViewController : UIViewController
{
    IBOutlet UIScrollView *mScrollView;
    
    IBOutlet UILabel *mLblThanks;
    IBOutlet UILabel *mLblShippingNumber;
    
    IBOutlet UILabel *mLblShippingFullName;
    IBOutlet UILabel *mLblShippingAddress;
    IBOutlet UILabel *mLblShippingCityState;
    IBOutlet UILabel *mLblShippingZipCode;
}
//@property (nonatomic, retain) JPurchaseInfo* mPurchase;

@property (nonatomic, strong) IBOutlet UIImageView          *mImgProfilePhotoTopRight;

@end
