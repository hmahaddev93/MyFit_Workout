//
//  JSignupViewController.h
//  Fitbox
//
//  Created by Khatib H. on 11/8/15.
//  
//

#import <UIKit/UIKit.h>

@protocol JSignupViewControllerDelegate

-(void)JSignupViewControllerCancel;
-(void)JSignupViewControllerSuccess;

@end

@interface JSignupViewController : UIViewController<UITextFieldDelegate,UIScrollViewDelegate>
{
    
    /**********Signup View*********/
    IBOutlet UIView *mSignUpView;
    IBOutlet UIScrollView *mSignupScroll;
    IBOutlet UITextField        *mTxtSignupEmail;
    IBOutlet UITextField        *mTxtSignupPassword;
    IBOutlet UITextField        *mTxtSignupConfirm;
    IBOutlet UITextField        *mTxtSignupUsername;
    
}

@property (strong, nonatomic) NSString *mFileNameToUpload;
@property (nonatomic, assign) id<JSignupViewControllerDelegate> delegate;
@end
