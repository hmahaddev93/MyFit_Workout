//
//  JSingleViewController.h
//  Zold
//
//  Created by Khatib H. on 7/05/14.
//  Copyright (c) 2014 Khatib Mobile. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JCheckoutPopup.h"
#import "JShippingAddressViewController.h"
#import "JSizeSelectorViewController.h"
#import "JWalletViewController.h"
#import "JSignupViewController.h"

@class AVPlayer;

//#import "HPGrowingTextView.h"
@interface JSingleViewController : UIViewController<JCheckoutPopupDelegate, JShippingAddressViewControllerDelegate, JSizeSelectorViewControllerDelegate, JWalletViewControllerDelegate, UIAlertViewDelegate, JSignupViewControllerDelegate>
{
    IBOutlet UIScrollView* mScrollView;

    IBOutlet UIScrollView         *mPhotoScrollView;
    IBOutlet UIPageControl        *mPhotoPageControl;
    
    IBOutlet UIView         *mDescriptionView;
    IBOutlet UILabel        *mLblTitle;
    IBOutlet UILabel        *mLblPrice;
    IBOutlet UILabel        *mLblDescription;
    
    IBOutlet UIButton       *mBtnLike;
    IBOutlet UIButton       *mBtnBuy;
//    //Media View
//    AVPlayer                    *mAVPlayer;
//    IBOutlet UIView *mViewVideo;
    
    IBOutlet NSLayoutConstraint *mConstraintScrollContentHeight;
    IBOutlet NSLayoutConstraint *mConstraintTitleTopLineWidth;
}

@property (nonatomic, strong) JCheckoutPopup *mCheckoutPopup;

@property (nonatomic, strong) JItem *mItem;
@property (nonatomic, strong) NSString *mItemToLoad;
@property (nonatomic, strong) JUser *mPerson;

@property (nonatomic, strong) JOrder *mOrder;

@end
