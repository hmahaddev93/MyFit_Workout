//
//  JMainViewController.m
//  Zold
//
//  Created by Khatib H. on 7/25/14.
//  
//

#import "JMainViewController.h"
#import "MDCSwipeToChoose.h"

#import "JSingleViewController.h"
#import "JItemCollectionViewCell.h"
#import "JAmazonS3ClientManager.h"
#import "JWalletViewController.h"
#import "JContactsViewController.h"
#import "SVPullToRefresh.h"
#import "JNewsViewController.h"
#import "JDownloadQueueManager.h"
#import "JMusicPlayerViewController.h"
#import "JPushMethods.h"
#import <MapKit/MapKit.h>
#import "JMessageViewController.h"

#define PAGE_ITEM_COUNT         20

#define minScale 0.3

#define SELECTED_COLOR  [UIColor colorWithRed:238.0/255.0 green:119.0/255.0 blue:61.0/255.0 alpha:1.0]

#define SWIPE_STATUS_NONE 0
#define SWIPE_STATUS_LEFT 1
#define SWIPE_STATUS_RIGHT 2
#define SWIPE_STATUS_SAME 3
@interface JMainViewController ()

@end

@implementation JMainViewController

@synthesize mArrData;

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    mArrData=[[NSMutableArray alloc] init];
    
    isLoading=0;
    
    self.frontCardView=nil;
    self.backCardView=nil;
    self.thirdView = nil;
    
    self.navigationItem.rightBarButtonItem.badgeValue = @"";
    self.navigationItem.leftBarButtonItem.badgeValue = @"";

    
    mViewSwipe = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
//    mViewSwipe.backgroundColor = [UIColor blueColor];
    
    UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
    [mViewSwipe addGestureRecognizer:panGesture];
    mViewSwipe.layer.masksToBounds = false;
    [self.view addSubview:mViewSwipe];
    
    mBtnNextArrow.hidden = true;
    mBtnPrevArrow.hidden = true;
    [APIClient checkListingCount];
    
    lastRequestDateInApp = 0;

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateShoppingCartBadge) name:SHOPPING_CART_NOTIFICATION object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateListingCount) name:NOTIF_CLASS_LISTING_COUNT_UPDATED object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(goBackToFirstItem) name:NOTIF_DISCOVER_CLICKED_AGAIN object:nil];


}

-(void)updateShoppingCartBadge
{
    if ([[Engine gShoppingCart] count]>0) {
        self.navigationItem.rightBarButtonItem.badgeValue = [NSString stringWithFormat:@"%d", (int)[[Engine gShoppingCart] count]];
    }
    else
    {
        self.navigationItem.rightBarButtonItem.badgeValue = @"";
    }
}

-(void)goBackToFirstItem
{
    if ([mArrData count] > 0) {
        if (mCurIndex > 0) {
            mCurIndex= 0;
            [self initSwipeView:SWIPE_STATUS_NONE];
            curView.transform=CGAffineTransformMakeScale(minScale, minScale);
            //Animated the Front View
            [UIView animateWithDuration:0.5 animations:^{
                curView.transform=CGAffineTransformIdentity;
            } completion:^(BOOL finished) {
                
            }];
        }
    }
}
-(void)updateListingCount
{
    if ([Engine gClassListingCount]>0) {
        self.navigationItem.leftBarButtonItem.badgeValue = [NSString stringWithFormat:@"%d", [Engine gClassListingCount]];
//        self.navigationItem.leftBarButtonItem.badgeBGColor = [UIColor blackColor];
    }
    else
    {
        self.navigationItem.leftBarButtonItem.badgeValue = @"";
    }
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:SHOPPING_CART_NOTIFICATION object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIF_CLASS_LISTING_COUNT_UPDATED object:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self updateShoppingCartBadge];
    [self updateListingCount];

    NSDate *currentTime = [NSDate date];
    int curTimeInUnix = (int)[currentTime timeIntervalSince1970];
    if(([mArrData count]==0)&&(self.frontCardView == nil))
    {
//        mPage=0;
        lastRequestDateInApp = curTimeInUnix;
        [self getItemsFromParse:0 currentPage:0];
    }
    else
    {
        NSLog(@"Main Home Page ViewWillAppear");
        if ((curTimeInUnix - lastRequestDateInApp) > 60*30 )
        {// IF last request was older than one 30 minms
            lastRequestDateInApp = curTimeInUnix;
            [self checkAndGetNewItems];
        }
    }
    [self.navigationController setNavigationBarHidden:false animated:animated];
//    [self initTopRightProfilePhoto];
}
-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
//    [self updateShoppingCartBadge];
//    dispatch_async(dispatch_get_main_queue(), ^{
//        [self updateShoppingCartBadge];
//    });
}
-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear: animated];
    if(self.frontCardView)
    {
        if (self.frontCardView.avPlayer) {
            [self.frontCardView.avPlayer pause];
            self.frontCardView.mBtnPlay.hidden = false;
        }
    }
}

-(void)initTopRightProfilePhoto
{
    if ([[JUser me] isAuthorized]) {
        _mImgProfilePhotoTopRight.hidden = false;
        NSString *profilePhoto = [JUser me].profilePhoto;
        _mImgProfilePhotoTopRight.image = [UIImage imageNamed:@"app_icon"];
        if (profilePhoto && ![profilePhoto isEqualToString:@""]) {
            [_mImgProfilePhotoTopRight setImageWithURL:[[JAmazonS3ClientManager defaultManager] cdnUrlForProfilePhotoThumb:profilePhoto]];
        }
    }
    else
    {
        _mImgProfilePhotoTopRight.hidden = true;
    }
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([segue.identifier isEqualToString:@"showSingleProduct"])
    {
        JSingleViewController *mView = (JSingleViewController*)segue.destinationViewController;
        mView.mItem = sender;
    }
    else if ([segue.identifier isEqualToString:@"showSingleNews"])
    {
        JNewsViewController *mView = (JNewsViewController*)segue.destinationViewController;
        mView.mCInfo = sender;
    }
    else if ([segue.identifier isEqualToString:@"showSinglePlaylist"]) {
        JMusicPlayerViewController *mController = (JMusicPlayerViewController*)segue.destinationViewController;
        mController.mPlaylistId = sender;
    }
    else if ([segue.identifier isEqualToString:@"showMessageView"]) {
        JMessageViewController *messageView = (JMessageViewController*)segue.destinationViewController;
        JListing *mListing = (JListing*)sender;
        messageView.mListing = mListing;
        messageView.mPerson = mListing.user;
    }
}

#pragma mark - Calling Parse SDK

-(void)getItemsFromParse:(int)currentTab currentPage:(int)currentPage
{
    if (isLoading) {
        return;
    }
    isLoading = true;
    mViewMessageNoMoreItem.hidden = true;
    mViewMessageContainer.hidden = false;
    [mLblMessageInfo setText:@"Loading.."];
    
    if(self.frontCardView)
    {
        if (self.frontCardView.avPlayer) {
            [self.frontCardView.avPlayer pause];
            self.frontCardView.avPlayer = nil;
        }
        [self.frontCardView removeFromSuperview];
        self.frontCardView=nil;
    }
    
    if(self.backCardView)
    {
        [self.backCardView removeFromSuperview];
        self.backCardView=nil;
    }
    if(self.thirdView)
    {
        [self.thirdView removeFromSuperview];
        self.thirdView=nil;
    }
    
    [APIClient getHomepageItems:^(NSMutableArray *items, int lastRequest) {
        isLoading = false;
        
        lastRequestDate = lastRequest;
        
        if(currentPage==0)
        {
            [mArrData removeAllObjects];
        }
        
        for (int i=0; i<[items count]; i++) {
            JItem *mObject=[items objectAtIndex:i];
            if ([mObject isKindOfClass:[JItem class]]) {
                if ([mObject.itemType isEqualToString:ITEM_TYPE_VIDEO]) {
                    NSString *videoId = mObject.video;
                    if(videoId && ![videoId isEqualToString:@""])
                    {
                        if (![JUtils videoDownloaded:videoId]) {
                            [[JDownloadQueueManager defaultManager] requestNewDownload:videoId];
                        }
                    }
                }
            }
            [mArrData addObject:mObject];
        }
        
        if([mArrData count]==0)
        {
            [mLblMessageInfo setText:@"No items found"];
            mViewMessageContainer.hidden = false;
        }
        else
        {
            mViewMessageContainer.hidden = true;
            [mLblMessageInfo setText:@""];
            [self initSwipeView: SWIPE_STATUS_NONE];
        }
    } failure:^(NSString *errorMessage) {
        
    }];
}

-(void)checkAndGetNewItems
{
    
    [APIClient getHomepageItemsNew:lastRequestDate success:^(NSMutableArray *items, NSMutableArray *listings, int lastRequestDate1) {
        lastRequestDate = lastRequestDate1;
        if ([items count] > 0 || [listings count] > 0) {
            NSMutableArray *onlyNewItems = [NSMutableArray new];
            NSMutableArray *onlyNewListings = [NSMutableArray new];

            NSMutableArray *itemIds = [NSMutableArray new];
            NSMutableArray *listingIds = [NSMutableArray new];
            
            for (int i=0; i<[mArrData count]; i++) {
                if ([[mArrData objectAtIndex:i] isKindOfClass:[JItem class]]) {
                    JItem *itm = [mArrData objectAtIndex:i];
                    [itemIds addObject:itm._id];
                }
                else if([[mArrData objectAtIndex:i] isKindOfClass:[JListing class]])
                {
                    JListing *lst = [mArrData objectAtIndex:i];
                    [listingIds addObject:lst._id];
                }
            }
            
            for (int i=0; i<[items count]; i++) {
                JItem *itm = [items objectAtIndex:i];
                if (![itemIds containsObject:itm._id]) {
                    [onlyNewItems addObject:itm];
                }
            }

            for (int i=0; i<[listings count]; i++) {
                JListing *itm = [listings objectAtIndex:i];
                if (![listingIds containsObject:itm._id]) {
                    [onlyNewListings addObject:itm];
                }
            }
            
            
            for (int i=0; i<[onlyNewItems count]; i++) {
                JItem *itm = [onlyNewItems objectAtIndex:i];
                [mArrData insertObject:itm atIndex: [listingIds count]];
            }
            
            for (int i=0; i<[onlyNewListings count]; i++) {
                JListing *itm = [onlyNewListings objectAtIndex:i];
                [mArrData insertObject:itm atIndex: 0];
            }
            

            if(mCurIndex < [listingIds count])
            {// Which means right now showing listing
                mCurIndex = mCurIndex + (int)[onlyNewListings count];
            }
            else
            {
                mCurIndex = mCurIndex + (int)[onlyNewItems count] + (int)[onlyNewListings count];
            }
            
            // Let's check before and after item. See if they are changed.
            if ((curView.mListing == [mArrData objectAtIndex:mCurIndex]) || (curView.mItem == [mArrData objectAtIndex:mCurIndex])) {
            }
            else{
                NSLog(@"SOMETHING IS VERY WRONG HERE");
            }
            
            if (((mCurIndex > 0) && !prevView) || (prevView && (mCurIndex > 0) && ((prevView.mItem != [mArrData objectAtIndex:mCurIndex-1]) && (prevView.mListing != [mArrData objectAtIndex:mCurIndex-1]))))
            {
                //Two cases. One is when there was no preview, but because of adding of new listing or item, current index is incrased.
                // or because of adding new stuff, previous item changed.
                if (prevView) {
                    [prevView removeFromSuperview];
                    prevView = nil;
                }
                
                prevView = [self createViewWithFrame:[self prevCardViewFrame] indx:mCurIndex - 1];
                [mViewSwipe addSubview:prevView];
            }
            
            
            if (((mCurIndex < ([mArrData count] - 1)) && !nextView) || (nextView && (mCurIndex < ([mArrData count] - 1)) && ((nextView.mItem != [mArrData objectAtIndex:mCurIndex+1]) && (nextView.mListing != [mArrData objectAtIndex:mCurIndex+1]))))
            {
                // ITEM CHANGED
                //                [prevView set]
                if (nextView) {
                    [nextView removeFromSuperview];
                    nextView = nil;
                }
                
                nextView = [self createViewWithFrame:[self nextCardViewFrame] indx:mCurIndex + 1];
                [mViewSwipe addSubview:nextView];
            }
        }
    } failure:^(NSString *errorMessage) {
        
    }];
    
//    [APIClient getHomepageItems:^(NSMutableArray *items) {
//        isLoading = false;
//        
//        for (int i=0; i<[items count]; i++) {
//            JItem *mObject=[items objectAtIndex:i];
//            if ([mObject.itemType isEqualToString:ITEM_TYPE_VIDEO]) {
//                NSString *videoId = mObject.video;
//                if(videoId && ![videoId isEqualToString:@""])
//                {
//                    if (![JUtils videoDownloaded:videoId]) {
//                        [[JDownloadQueueManager defaultManager] requestNewDownload:videoId];
//                    }
//                }
//            }
//            [mArrData addObject:mObject];
//        }
//        
//        if([mArrData count]==0)
//        {
//            [mLblMessageInfo setText:@"No items found"];
//            mViewMessageContainer.hidden = false;
//        }
//        else
//        {
//            mViewMessageContainer.hidden = true;
//            [mLblMessageInfo setText:@""];
//            [self initSwipeView: SWIPE_STATUS_NONE];
//        }
//    } failure:^(NSString *errorMessage) {
//        
//    }];
}

-(IBAction) handlePan:(UIPanGestureRecognizer*)recognizer
{
    if ([self.mArrData count]==0) {
        return;
    }
    CGPoint translation = [recognizer translationInView:self.view];
    recognizer.view.center = CGPointMake(recognizer.view.center.x + translation.x,
                                         recognizer.view.center.y);
    [recognizer setTranslation:CGPointZero inView:self.view];
    
    float movedX=recognizer.view.center.x-recognizer.view.frame.size.width/2;
    
    
    if(movedX>0)
    {
        prevView.transform=CGAffineTransformMakeScale(0.3+(1-0.3)*(movedX/SCREEN_WIDTH), 0.3+(1-0.3)*(movedX/SCREEN_WIDTH));
        curView.transform=CGAffineTransformMakeScale(1-(1-0.3)*(movedX/SCREEN_WIDTH), 1-(1-0.3)*(movedX/SCREEN_WIDTH));
        nextView.transform=CGAffineTransformMakeScale(0.3, 0.3);
    }
    else
    {
        float newMovedX=0-movedX;
        nextView.transform=CGAffineTransformMakeScale(0.3+(1-0.3)*(newMovedX/SCREEN_WIDTH), 0.3+(1-0.3)*(newMovedX/SCREEN_WIDTH));
        curView.transform=CGAffineTransformMakeScale(1-(1-0.3)*(newMovedX/SCREEN_WIDTH), 1-(1-0.3)*(newMovedX/SCREEN_WIDTH));
        prevView.transform=CGAffineTransformMakeScale(0.3, 0.3);
    }
    if (recognizer.state == UIGestureRecognizerStateBegan)
    {
        mBtnPrevArrow.hidden = true;
        mBtnNextArrow.hidden = true;
    }
    
    if (recognizer.state == UIGestureRecognizerStateEnded)
    {
        // 1
        CGPoint velocity = [recognizer velocityInView:self.view];//.velocityInView(self.view)
        float magnitude = sqrt((velocity.x * velocity.x) + (velocity.y * velocity.y));
        float slideMultiplier = magnitude / 200;
        
        // 2
        float slideFactor = 0.1 * slideMultiplier;     //Increase for more of a slide
        // 3
        CGPoint finalPoint = CGPointMake(recognizer.view.center.x + (velocity.x * slideFactor),
                                   recognizer.view.center.y);
        // 4
        if(finalPoint.x>SCREEN_WIDTH)
        {
            if(mCurIndex==0)
            {
                finalPoint.x=SCREEN_WIDTH/2;
            }
            else
            {
                mCurIndex=mCurIndex-1;
                finalPoint.x=SCREEN_WIDTH*3/2;
            }
        }
        else if(finalPoint.x<0){
            if(mCurIndex==mArrData.count-1)
            {
                finalPoint.x=SCREEN_WIDTH/2;
            }
            else
            {
                mCurIndex=mCurIndex+1;
                finalPoint.x=0-SCREEN_WIDTH/2;
            }
        }
        else
        {
            finalPoint.x=SCREEN_WIDTH/2;
        }
        __block int newState = SWIPE_STATUS_SAME;
        [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
            recognizer.view.center = finalPoint;
            
            if(finalPoint.x<0)
            {
                prevView.transform=CGAffineTransformMakeScale(0.3, 0.3);
                curView.transform=CGAffineTransformMakeScale(0.3, 0.3);
                nextView.transform=CGAffineTransformMakeScale(1, 1);
                newState = SWIPE_STATUS_RIGHT;
            }
            else if(finalPoint.x>SCREEN_WIDTH)
            {
                prevView.transform=CGAffineTransformMakeScale(1, 1);
                curView.transform=CGAffineTransformMakeScale(0.3, 0.3);
                nextView.transform=CGAffineTransformMakeScale(0.3, 0.3);
                newState = SWIPE_STATUS_LEFT;
            }
            else
            {
                prevView.transform=CGAffineTransformMakeScale(0.3, 0.3);
                curView.transform=CGAffineTransformMakeScale(1, 1);
                nextView.transform=CGAffineTransformMakeScale(0.3, 0.3);
            }
        } completion:^(BOOL finished) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self initSwipeView: newState];
            });
        }];
        // 5
    }
}


- (JItemSwipeView *)createViewWithFrame:(CGRect)frame indx:(int)indx
{
//    if ([mArrData count] == 0) {
//        return nil;
//    }
//    
//    MDCSwipeToChooseViewOptions *options = [MDCSwipeToChooseViewOptions new];
//    options.delegate = self;
//    options.threshold = 80.f;
//    options.onPan = ^(MDCPanState *state){
//        
//        if (self.backCardView)
//        {
//            CGRect frame = [self backCardViewFrame];
//            self.backCardView.frame = CGRectMake(frame.origin.x - (state.thresholdRatio * 5.f),
//                                                 frame.origin.y + (state.thresholdRatio * 5.f),
//                                                 CGRectGetWidth(frame),
//                                                 CGRectGetHeight(frame));//+state.thresholdRatio*12);
//        }
//        
//        
//        if (self.thirdView) {
//            CGRect frame1 = [self thirdCardViewFrame];
//            self.thirdView.frame = CGRectMake(frame1.origin.x - (state.thresholdRatio * 5.f),
//                                              frame1.origin.y + (state.thresholdRatio * 5.f),
//                                              CGRectGetWidth(frame1),
//                                              CGRectGetHeight(frame1));//+state.thresholdRatio*12);
//        }
//    };
    
    
    JItemSwipeView *personView = [[JItemSwipeView alloc] initWithFrame:frame
                                                                  item:[mArrData objectAtIndex:indx]
                                                               options:nil];
    
    personView.delegate=self;
//    [mArrData removeObjectAtIndex:0];
//    personView.userInteractionEnabled = false;
    return personView;
}

-(void)setCurrentViewToOriginal
{
    curView.transform = CGAffineTransformIdentity;
    curView.frame = [self frontCardViewFrame];
    
    CGPoint finalPoint = CGPointMake(SCREEN_WIDTH/2, mViewSwipe.center.y);
    mViewSwipe.center = finalPoint;

}

-(void) initSwipeView:(int)swipeStatus
{
//    NSArray *subViews = mViewSwipe.subviews;
//    for (UIView *subView in subViews) {
//        [subView removeFromSuperview];
//    }
    if (swipeStatus == SWIPE_STATUS_LEFT)
    {
        [nextView removeFromSuperview];
        nextView = nil;
        nextView = curView;
        curView = prevView;
        prevView = nil;
    }
    else if (swipeStatus == SWIPE_STATUS_RIGHT)
    {
        [prevView removeFromSuperview];
        prevView = nil;
        prevView = curView;
        curView = nextView;
        nextView = nil;
    }
    else if (swipeStatus == SWIPE_STATUS_NONE)
    {
        [curView removeFromSuperview];
        [prevView removeFromSuperview];
        [nextView removeFromSuperview];
        curView = nil;
        prevView = nil;
        nextView = nil;
    }
//    curView = nil;
//    prevView = nil;
//    nextView = nil;
//    prevView = UIImageView(frame: CGRectMake(-self.view.frame.size.width, 20, SCREEN_WIDTH, SCREEN_WIDTH))
    if(mCurIndex>0)
    {
        if (!prevView) {
            prevView = [self createViewWithFrame:[self prevCardViewFrame] indx:mCurIndex - 1];
            [mViewSwipe addSubview:prevView];
        }
        else
        {
            prevView.transform = CGAffineTransformIdentity;
            prevView.frame = [self prevCardViewFrame];
        }
        prevView.transform=CGAffineTransformMakeScale(minScale, minScale);
    }
    
    if(mCurIndex<(mArrData.count-1))
    {
        if (!nextView) {
            nextView = [self createViewWithFrame:[self nextCardViewFrame] indx:mCurIndex + 1];
            [mViewSwipe addSubview:nextView];
        }
        else
        {
            nextView.transform = CGAffineTransformIdentity;
            nextView.frame = [self nextCardViewFrame];
        }
        nextView.transform=CGAffineTransformMakeScale(minScale, minScale);
    }
    

    if (!curView) {
        curView = [self createViewWithFrame:[self frontCardViewFrame] indx:mCurIndex];
        [mViewSwipe addSubview:curView];
    }
    else
    {
//        [self performSelector:@selector(setCurrentViewToOriginal) withObject:nil afterDelay:2.0];
        curView.transform = CGAffineTransformIdentity;
        curView.frame = [self frontCardViewFrame];
//        curView.transform = CGAffineTransformIdentity;
    }
    
    CGPoint finalPoint = CGPointMake(SCREEN_WIDTH/2, mViewSwipe.center.y);
    mViewSwipe.center = finalPoint;
    
    
    if (mCurIndex == 0) {
        mBtnPrevArrow.hidden = true;
        mBtnNextArrow.hidden = false;
    }
    else if (mCurIndex == mArrData.count - 1)
    {
        mBtnNextArrow.hidden = true;
        mBtnPrevArrow.hidden = false;
    }
    else
    {
        mBtnNextArrow.hidden = false;
        mBtnPrevArrow.hidden = false;
    }
//    mBtnLiked.selected = mArrDataLiked.containsObject(mArrData.objectAtIndex(mCurIndex))
}
//
//#pragma mark - MDCSwipeToChooseDelegate Protocol Methods
//
//// This is called when a user didn't fully swipe left or right.
//- (void)viewDidCancelSwipe:(UIView *)view {
//    NSLog(@"You couldn't decide on %@", [mCurrentItem objectForKey:kItemItemName]);
//}
//
//// This is called then a user swipes the view fully left or right.
//- (void)view:(UIView *)view wasChosenWithDirection:(MDCSwipeDirection)direction {
//    // MDCSwipeToChooseView shows "NOPE" on swipes to the left,
//    // and "LIKED" on swipes to the right.
//    if([PFUser currentUser])
//    {
////        if (direction == MDCSwipeDirectionLeft) {
////            NSLog(@"You noped %@.", [mCurrentItem objectForKey:kItemItemName]);
////            [[JUser currentUserSingleton] dontshowPost:mCurrentItem owner:[mCurrentItem objectForKey:kItemUserID]];
////        } else {
////            NSLog(@"You liked %@.", [mCurrentItem objectForKey:kItemItemName]);
////            [[JUser currentUserSingleton] likePost:mCurrentItem owner:[mCurrentItem objectForKey:kItemUserID]];
////        }
//    }
//    
//    if (self.frontCardView) {
//        if (self.frontCardView.avPlayer) {
//            [self.frontCardView.avPlayer pause];
//            self.frontCardView.avPlayer = nil;
//        }
//    }
//    self.frontCardView = self.backCardView;
//    self.frontCardView.userInteractionEnabled = true;
//    
//    self.backCardView = self.thirdView;
//    if ((self.thirdView = [self popPersonViewWithFrame:[self frontCardViewFrame]]))//backCardViewFrame
//    {
//        self.thirdView.frame=[self thirdCardViewFrame];
//
//        // Fade the back card into view.
//        self.thirdView.alpha = 0.f;
//        self.thirdView.userInteractionEnabled = false;
//        [self.view insertSubview:self.thirdView belowSubview:self.backCardView];
//        [UIView animateWithDuration:0.5
//                              delay:0.0
//                            options:UIViewAnimationOptionCurveEaseInOut
//                         animations:^{
//                             self.thirdView.alpha = 1.f;
//                         } completion:nil];
//    }
//    
//    if (!self.frontCardView) {
//        mViewMessageNoMoreItem.hidden = false;
//        mViewMessageNoMoreItem.alpha = 0;
//        [UIView animateWithDuration:0.3 animations:^{
//            mViewMessageNoMoreItem.alpha = 1;
//        } completion:^(BOOL finished) {
//            
//        }];
//    }
//}
//
//#pragma mark - Internal Methods
//
//- (void)setFrontCardView:(JItemSwipeView *)frontCardView {
//    // Keep track of the person currently being chosen.
//    // Quick and dirty, just for the purposes of this sample app.
//    _frontCardView = frontCardView;
//    mCurrentItem = frontCardView.mCInfo;
//}
//
//
//
//- (JItemSwipeView *)popPersonViewWithFrame:(CGRect)frame {
//    if ([mArrData count] == 0) {
//        return nil;
//    }
//    
//    MDCSwipeToChooseViewOptions *options = [MDCSwipeToChooseViewOptions new];
//    options.delegate = self;
//    options.threshold = 80.f;
//    options.onPan = ^(MDCPanState *state){
//        
//        if (self.backCardView)
//        {
//            CGRect frame = [self backCardViewFrame];
//            self.backCardView.frame = CGRectMake(frame.origin.x - (state.thresholdRatio * 5.f),
//                                                 frame.origin.y + (state.thresholdRatio * 5.f),
//                                                 CGRectGetWidth(frame),
//                                                 CGRectGetHeight(frame));//+state.thresholdRatio*12);
//        }
//
//        
//        if (self.thirdView) {
//            CGRect frame1 = [self thirdCardViewFrame];
//            self.thirdView.frame = CGRectMake(frame1.origin.x - (state.thresholdRatio * 5.f),
//                                              frame1.origin.y + (state.thresholdRatio * 5.f),
//                                              CGRectGetWidth(frame1),
//                                              CGRectGetHeight(frame1));//+state.thresholdRatio*12);
//        }
//    };
//    
//    
//    JItemSwipeView *personView = [[JItemSwipeView alloc] initWithFrame:frame
//                                                                    item:[mArrData objectAtIndex:0]
//                                                                   options:options];
//    
//    personView.delegate=self;
//    [mArrData removeObjectAtIndex:0];
//    return personView;
//}

#pragma mark View Contruction
- (CGRect)prevCardViewFrame {
    CGFloat horizontalPadding = 20.f;
    CGFloat topPadding = 64.0+18.0;
    return CGRectMake(horizontalPadding - SCREEN_WIDTH,
                      topPadding,
                      SCREEN_WIDTH - horizontalPadding * 2,//CGRectGetWidth(self.view.frame) - (horizontalPadding * 2),
                      SCREEN_HEIGHT - 64 - 49 - 18.0 - 8);//385 // - 60 292+49

}

- (CGRect)nextCardViewFrame {
    CGFloat horizontalPadding = 20.f;
    CGFloat topPadding = 64.0+18.0;
    return CGRectMake(SCREEN_WIDTH + horizontalPadding,
                      topPadding,
                      SCREEN_WIDTH - horizontalPadding * 2,//CGRectGetWidth(self.view.frame) - (horizontalPadding * 2),
                      SCREEN_HEIGHT - 64 - 49 - 18.0 - 8);//385 // - 60 292+49
    
}

- (CGRect)frontCardViewFrame {
//    CGFloat horizontalPadding = 14.f;
//    CGFloat topPadding = 130.f;
//    CGFloat bottomPadding = 200.f;
    
//    if(IS_IPHONE5)
//    {
        CGFloat horizontalPadding = 20.f;
        CGFloat topPadding = 64.0+18.0;
        return CGRectMake(horizontalPadding,
                          topPadding,
                          SCREEN_WIDTH - horizontalPadding * 2,//CGRectGetWidth(self.view.frame) - (horizontalPadding * 2),
                          SCREEN_HEIGHT - 64 - 49 - 18.0 - 8);//385 // - 60 292+49
//    }
//    else
//    {
//        CGFloat horizontalPadding = 14.f;
//        CGFloat topPadding = 64.0 + 26.0;
//        return CGRectMake(horizontalPadding,
//                          topPadding,
//                          292,//CGRectGetWidth(self.view.frame) - (horizontalPadding * 2),
//                          SCREEN_HEIGHT - 64 - 49 - 50.0);//
//
//    }
}
//
//- (CGRect)backCardViewFrame {
//    CGRect frontFrame = [self frontCardViewFrame];
////    return frontFrame;
//    return CGRectMake(frontFrame.origin.x+5,
//                      frontFrame.origin.y - 5.f,
//                      CGRectGetWidth(frontFrame),
//                      CGRectGetHeight(frontFrame));
//}
//
//- (CGRect)thirdCardViewFrame {
//    CGRect frontFrame = [self frontCardViewFrame];
//    //    return frontFrame;
//    return CGRectMake(frontFrame.origin.x+10,
//                      frontFrame.origin.y - 10.f,
//                      CGRectGetWidth(frontFrame),
//                      CGRectGetHeight(frontFrame));
//}


#pragma mark - Item Swipe View Delegate
-(void)showItemInfo:(JItem *)feedInfo
{
    
    if ([feedInfo.itemType isEqualToString:ITEM_TYPE_NEWS]) {
        [self performSegueWithIdentifier:@"showSingleNews" sender:feedInfo];
    }
    else if ([feedInfo.itemType isEqualToString:ITEM_TYPE_PRODUCT])
    {
        [self performSegueWithIdentifier:@"showSingleProduct" sender:feedInfo];
    }
    else if ([feedInfo.itemType isEqualToString:ITEM_TYPE_PLAYLIST])
    {
        [self performSegueWithIdentifier:@"showSinglePlaylist" sender:feedInfo.video];
    }
}

-(void)shareItemInfo:(JItem *)feedInfo{
    NSString *textToShare = [NSString stringWithFormat:@"Check this out! %@  www.iwantfitbox.com", [feedInfo.item_name uppercaseString]];

    CGFloat cornerRadius = curView.layer.cornerRadius;
    curView.layer.cornerRadius = 0;
    UIImage *image= [JUtils imageWithView:curView];
    curView.layer.cornerRadius = cornerRadius;
    
    
    NSArray *objectsToShare = @[textToShare, image];
    
    UIActivityViewController *activityVC = [[UIActivityViewController alloc] initWithActivityItems:objectsToShare applicationActivities:nil];
    
    NSArray *excludeActivities = @[UIActivityTypeAirDrop,
                                   UIActivityTypePrint,
                                   UIActivityTypeAssignToContact,
                                   UIActivityTypeSaveToCameraRoll,
                                   UIActivityTypeAddToReadingList,
                                   UIActivityTypePostToFlickr,
                                   UIActivityTypePostToVimeo, UIActivityTypeCopyToPasteboard];
    
    activityVC.excludedActivityTypes = excludeActivities;
    
    [self presentViewController:activityVC animated:YES completion:nil];
}
-(void)onRSVP:(JListing *)listing swipeView:(JItemSwipeView *)swipeView
{
    if(listing.signupURL && ![listing.signupURL isEqualToString:@""])
    {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:listing.signupURL]];
        return;
    }
    
    if (![[JUser me] isAuthorized]) {
        [Engine showAlertViewForLogin];
        return;
    }
    if ([listing.user._id isEqualToString:[JUser me]._id]) {
        [self.navigationController.view makeToast:@"You can't RSVP your own posting!" duration:1.5 position:CSToastPositionTop];
        return;
    }
    
    if ([listing.status isEqualToString:kListingStatusOpen]) {
        for (int i=0; i<listing.attendees.count; i++) {
            JUser *user = [listing.attendees objectAtIndex:i];
            if ([user._id isEqualToString:[JUser me]._id]) {
                [self.navigationController.view makeToast:@"You already done RSVP the listing" duration:1.5 position:CSToastPositionTop];
                return;
            }
        }
        [JUtils showLoadingIndicator:self.navigationController.view message:@"RSVP..."];
        [APIClient  acceptListing:listing._id success:^(JListing *item, JMessageHistory *messageHistory) {
            [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_REMOVE_LISTING object: listing];
            [JUtils hideLoadingIndicator:self.navigationController.view];
            [JPushMethods acceptListing:listing];
//            [swipeView updateListingAttendees:item];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.navigationController.view makeToast:@"RSVP request have been posted!" duration:1.5 position:CSToastPositionTop];
                [self performSegueWithIdentifier:@"showMessageView" sender:item];
            });
        } failure:^(NSString *errorMessage) {
            [JUtils hideLoadingIndicator:self.navigationController.view];
            [self.navigationController.view makeToast:errorMessage duration:1.5 position:CSToastPositionTop];
        }];
    }
    else
    {
        [self.navigationController.view makeToast:@"Listing is closed" duration:1.5 position:CSToastPositionTop];
    }
}
-(void)openMap:(JListing *)listing
{
    CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake([[listing.lnglat objectAtIndex:1] doubleValue],[[listing.lnglat objectAtIndex:0] doubleValue]);
    MKMapItem *mapItem = [[MKMapItem alloc] initWithPlacemark:[[MKPlacemark alloc] initWithCoordinate:coordinate addressDictionary:nil]];
    mapItem.name = listing.placeName;
    [mapItem openInMapsWithLaunchOptions:@{MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving}];
}
#pragma mark Control Events

//// Programmatically "nopes" the front card view.
//- (IBAction)onTouchBtnNope:(id)sender {
//    [self.frontCardView mdc_swipe:MDCSwipeDirectionLeft];
//}
//
//// Programmatically "likes" the front card view.
//- (IBAction)onTouchBtnLike:(id)sender {
//    [self.frontCardView mdc_swipe:MDCSwipeDirectionRight];
//}
//
//
//-(IBAction)onTouchBtnAddToCart:(id)sender
//{
//    if(!mCurrentItem)
//    {
//        return;
//    }
//    if(![[Engine gShoppingCart] containsObject:mCurrentItem])
//    {
//        [[Engine gShoppingCart] addObject:mCurrentItem];
//    }
//}



@end
