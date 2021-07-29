//
//  JItemSwipeView.h
//  Zold
//
//  Created by Khatib H. on 8/14/14.
//  
//

#import <UIKit/UIKit.h>
#import "MDCSwipeToChoose.h"
#import <AVFoundation/AVFoundation.h>

@class JItemSwipeView;

@protocol JItemSwipeViewDelegate

@optional;
-(void) showItemInfo: (JItem *) feedInfo;
-(void) shareItemInfo: (JItem *) feedInfo;
-(void) onZoldClicked: (JItem *) feedInfo;
-(void) onRSVP: (JListing *) listing swipeView:(JItemSwipeView*)swipeView;
-(void) openMap: (JListing *) listing;
@end

@interface JItemSwipeView : MDCSwipeToChooseView
{
    UIButton       *mBtnLike;
    UIButton       *mBtnInfo;
    UIButton       *mBtnShare;


    UIView          *mViewBottomContainer;
    UILabel        *mLblItemTitle;
    UILabel        *mLblPrice;
    UIScrollView *scrollViewAttendees;
    
}

@property (nonatomic, assign) id<JItemSwipeViewDelegate>   delegate;
@property (nonatomic, retain) JItem                      *mItem;
@property (nonatomic, retain) JListing                      *mListing;
@property (nonatomic, retain) UIImageView    *mPhotoView;
@property (nonatomic, strong)     AVPlayer *avPlayer;
@property (nonatomic, strong) UIButton       *mBtnPlay;

- (instancetype)initWithFrame:(CGRect)frame
                       item:(NSObject *)item
                      options:(MDCSwipeToChooseViewOptions *)options;
-(void)updateListingAttendees:(JListing*)item;
//- (void)setInfo: (PFObject *)info;

@end
