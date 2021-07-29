//
//  JMainViewController.h
//  Zold
//
//  Created by Khatib H. on 7/25/14.
//  
//

#import <UIKit/UIKit.h>

#import "JItemSwipeView.h"
#import "MDCSwipeToChooseDelegate.h"
#import <MessageUI/MessageUI.h>

@interface JMainViewController : UIViewController<UIScrollViewDelegate,MDCSwipeToChooseDelegate,JItemSwipeViewDelegate, UITextFieldDelegate>
{
    
    JItem           *mCurrentItem;
    
    IBOutlet UILabel  *mLblMessageInfo;
    IBOutlet UIView   *mViewMessageContainer;
    IBOutlet UIView     *mViewMessageNoMoreItem;
    int isLoading;
    
    IBOutlet UIButton *mBtnNextArrow;
    IBOutlet UIButton *mBtnPrevArrow;
    
    IBOutlet UIView *mViewSwipe;
    JItemSwipeView* prevView;
    JItemSwipeView* curView;
    JItemSwipeView* nextView;
    int mCurIndex;
    
    
    int lastRequestDate;
    int lastRequestDateInApp;
}

@property (nonatomic, strong) IBOutlet UIImageView          *mImgProfilePhotoTopRight;

@property (nonatomic, retain) JItemSwipeView                      *frontCardView;
@property (nonatomic, retain) JItemSwipeView                      *backCardView;
@property (nonatomic, retain) JItemSwipeView                      *thirdView;

@property (nonatomic, retain) NSMutableArray *mArrData;
@end

