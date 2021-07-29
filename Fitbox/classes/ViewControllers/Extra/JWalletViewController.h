//
//  JWalletViewController.h
//  Zold
//
//  Created by Khatib H. on 8/24/14.
//  
//

#import <UIKit/UIKit.h>
#import <PassKit/PassKit.h>
#import "Stripe.h"


@protocol JWalletViewControllerDelegate

@optional;
-(void) JWalletViewControllerCardChosen:(JCreditCardInfo*)cardInfo;
-(void) JWalletViewControllerCancel;
@end


@interface JWalletViewController : UIViewController<UINavigationControllerDelegate, STPPaymentCardTextFieldDelegate, UITextFieldDelegate>
{
    IBOutlet UIScrollView *mScrollView;
    NSDictionary *mDictionary;
    IBOutlet UIView *mViewCredits;

    
    BOOL pending;
}



//@property (nonatomic, retain) JPurchaseInfo* mPurchase;
@property (nonatomic, strong) IBOutlet UIImageView          *mImgProfilePhotoTopRight;

@property STPPaymentCardTextField* paymentTextField;
//@property IBOutlet STPFormTextField* cardNumberField;
//@property IBOutlet STPFormTextField* cardExpiryField;
//@property IBOutlet STPFormTextField* cardCVCField;
//@property IBOutlet UIImageView* placeholderView;
//@property (readonly) PTKCard* card;
//@property (nonatomic, retain) IBOutlet UITextField *mTxtPostalCode;

@property (nonatomic, assign) id<JWalletViewControllerDelegate> delegate;
@end
