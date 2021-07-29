//
//  JLoginViewController.h
//  Fitbox
//
//  Created by Khatib H. on 11/8/15.
//  
//

#import <UIKit/UIKit.h>

@interface JLoginViewController : UIViewController<UITextFieldDelegate,UIScrollViewDelegate>
{
    /********Login View**********/
    
    IBOutlet UIView             *mLoginView;
    IBOutlet UIScrollView       *mLoginScroll;
    
    IBOutlet UITextField        *mTxtLoginUsername;
    IBOutlet UITextField        *mTxtLoginPassword;
}

@end
