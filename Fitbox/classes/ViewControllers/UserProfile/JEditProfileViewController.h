//
//  JEditProfileViewController.h
//  Zold
//
//  Created by Khatib H. on 13/10/14.
//  
//

#import <UIKit/UIKit.h>

@interface JEditProfileViewController : UIViewController<UITextFieldDelegate, UIImagePickerControllerDelegate, UIActionSheetDelegate, UINavigationControllerDelegate>
{
    IBOutlet UIScrollView *mScrollView;

    IBOutlet UITextField *mTxtFirstName;
    IBOutlet UITextField *mTxtLastName;
    IBOutlet UITextField *mTxtEmail;

    IBOutlet UITextField *mTxtOriginalPassword;
    IBOutlet UITextField *mTxtNewPassword;
    IBOutlet UITextField *mTxtNewPasswordConfirm;
    

    IBOutlet UIImageView *mPhoto;
    IBOutlet UIButton *mBtnProfile;
    IBOutlet UIActivityIndicatorView *mIndicatorProfile;

}

@property (nonatomic, retain) NSString* mFileNameToUpload;
@property (nonatomic, retain) UIImage *mImageBig;
@property (nonatomic, retain) UIImage *mImageSmall;

@end
