//
//  JNewsViewController.h
//  Zold
//
//  Created by Khatib H. on 8/22/14.
//  
//

#import <UIKit/UIKit.h>

@interface JNewsViewController : UIViewController<UITextViewDelegate>
{
    IBOutlet UILabel *mLblTitle;
//    IBOutlet UILabel *mLblContent;
    IBOutlet UITextView *mTxtContent;
    IBOutlet UILabel *mLblAuthor;

    IBOutlet UIImageView *mImgPhoto;
    IBOutlet UIScrollView *mScrollView;
    IBOutlet UIScrollView *mScrollViewImage;
    IBOutlet UIPageControl *mPgControl;
    
    IBOutlet NSLayoutConstraint *mConstraintScrollContentHeight;
}
@property (nonatomic, retain) JItem                      *mCInfo;
@property (nonatomic, retain) JUser                      *mPerson;
@end
