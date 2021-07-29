//
//  JSingleViewController.m
//  Zold
//
//  Created by Khatib H. on 7/05/14.
//  Copyright (c) 2014 Khatib Mobile. All rights reserved.
//

#import "JSingleViewController.h"
#import "JAmazonS3ClientManager.h"
#import "JExtraWebViewViewController.h"

@interface JSingleViewController ()

@end

@implementation JSingleViewController


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    mBtnBuy.layer.borderColor = [MAIN_COLOR_PINK CGColor];
    mBtnBuy.layer.borderWidth = 1;
    
    [self setupCheckoutPopup];
    [self initView];
    
//    if(self.mItem)
//    {
//        [self initView];
//        [JItem checkItemWithWithID:self.mItem.objectId completionBlock:^(JItem *itemLoaded) {
//            if(itemLoaded)
//            {
//                self.mItem=itemLoaded;
//                [self initView];
//            }
//            else
//            {
//                UIAlertView *mAlertView=[[UIAlertView alloc] initWithTitle:APP_NAME message:@"Failed loading item" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles: nil];
//                [mAlertView show];
//                [self.navigationController popViewControllerAnimated:YES];
//            }
//        }];
//        
//    }
//    else
//    {
//        [JItem checkItemWithWithID:self.mItemToLoad completionBlock:^(JItem *itemLoaded) {
//            if(itemLoaded)
//            {
//                self.mItem=itemLoaded;
//                [self initView];
//            }
//            else
//            {
//                UIAlertView *mAlertView=[[UIAlertView alloc] initWithTitle:APP_NAME message:@"Failed loading item" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles: nil];
//                [mAlertView show];
//                [self.navigationController popViewControllerAnimated:YES];
//            }
//        }];
//    }

}

-(void)setupCheckoutPopup
{
    NSArray* nibArray = [ [ NSBundle mainBundle ] loadNibNamed : @"JCheckoutPopup" owner: nil options: nil];
    self.mCheckoutPopup = ( JCheckoutPopup * )[ nibArray objectAtIndex : 0];
    self.mCheckoutPopup .delegate = self;
    [self.mCheckoutPopup  setFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
    
    NSLog(@"Width: %d   HEIGHT: %d", (int)SCREEN_WIDTH, (int)SCREEN_HEIGHT);
    
    [self.view addSubview: self.mCheckoutPopup ];
    [self showPicker:self.mCheckoutPopup  show:NO animated:NO];
    
    self.mCheckoutPopup.mItem = self.mItem;
    self.mCheckoutPopup.mAddressInfo = [Engine gAddress];
    self.mCheckoutPopup.mCreditCardInfo = [Engine gCreditCard];
    [self.mCheckoutPopup initCheckoutPopup];

}


- (void)viewDidUnload
{
    [super viewDidUnload];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}


- (void)initView
{
    
    [[mPhotoScrollView subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    for(int i=0;i<[self.mItem.photos count];i++)
    {
        UIImageView* mImageView=[[UIImageView alloc] initWithFrame:CGRectMake(i*SCREEN_WIDTH, 0 , SCREEN_WIDTH, mPhotoScrollView.frame.size.height)];
        mImageView.contentMode=UIViewContentModeScaleAspectFill;
        [mImageView setImageWithURL:[[JAmazonS3ClientManager defaultManager] cdnUrlForItemPhoto:[self.mItem.photos objectAtIndex:i]]];
        mImageView.layer.masksToBounds=YES;
        mImageView.tag=i+700;
        [mPhotoScrollView addSubview:mImageView];
    }
    
    if (self.mItem.video) {
        UIImageView* mImageView=[[UIImageView alloc] initWithFrame:CGRectMake(([self.mItem.photos count])*SCREEN_WIDTH, 0 , SCREEN_WIDTH, mPhotoScrollView.frame.size.height)];
        mImageView.contentMode=UIViewContentModeScaleAspectFill;
        [mImageView setImageWithURL:[[JAmazonS3ClientManager defaultManager] cdnUrlForItemVideoThumb:self.mItem.video]];
        mImageView.layer.masksToBounds=YES;
        mImageView.tag=[self.mItem.photos count]+0+700;
        [mPhotoScrollView addSubview:mImageView];
        
        
        UIButton *mBtn=[[UIButton alloc] initWithFrame:CGRectMake(mPhotoScrollView.frame.size.width*([self.mItem.photos count])+(mPhotoScrollView.frame.size.width-54)/2.0,(mPhotoScrollView.frame.size.height-54)/2.0, 54, 54)];
        [mBtn setImage:[UIImage imageNamed:@"BtnPlay"] forState:UIControlStateNormal];
        //        mBtn.tag=PLAY_BUTTON_TAG_START+i;
        [mBtn addTarget:self action:@selector(onTouchBtnPlay:) forControlEvents:UIControlEventTouchUpInside];
        [mPhotoScrollView addSubview:mBtn];
    }
    
    [mPhotoScrollView setContentSize:CGSizeMake(([self.mItem.photos count]+(self.mItem.video!=nil))*320, mPhotoScrollView.frame.size.height)];
    
    mPhotoPageControl.numberOfPages=[self.mItem.photos count]+(self.mItem.video !=nil);
    mPhotoPageControl.currentPage=0;
    [mPhotoScrollView scrollRectToVisible:CGRectMake(0, 0, mPhotoScrollView.frame.size.width, mPhotoScrollView.frame.size.height) animated:NO];
    mLblTitle.text=[self.mItem.item_name uppercaseString];
    
//    mLblPrice.text=[NSString stringWithFormat:@"$ %.2f",[self.mItem.listingprice floatValue]];
    [mBtnBuy setTitle:[NSString stringWithFormat:@"BUY NOW $%.2f",[self.mItem.listingprice floatValue]] forState:UIControlStateNormal];
    
    CGSize sz;
    sz=[mLblTitle.text boundingRectWithSize:CGSizeMake(100000, 20) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:mLblTitle.font} context:nil].size;
    if (sz.width > 290) {
        sz.width = 290;
    }
    mConstraintTitleTopLineWidth.constant = sz.width;

    mLblDescription.text=self.mItem.desc;
    
    sz=[mLblDescription.text boundingRectWithSize:CGSizeMake(mLblDescription.frame.size.width, 100000) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:mLblDescription.font} context:nil].size;
//    [mDescriptionView setFrame:CGRectMake(mDescriptionView.frame.origin.x, mDarkYellowView.frame.origin.y+mDarkYellowView.frame.size.height+15, mDescriptionView.frame.size.width, mLblDescription.frame.origin.y+sz.height+5)];
//    [mLblDescription setFrame:CGRectMake(mLblDescription.frame.origin.x, mLblDescription.frame.origin.y, mLblDescription.frame.size.width, sz.height+2)];
    
//    [mActionView setFrame:CGRectMake(mActionView.frame.origin.x, mDescriptionView.frame.origin.y+mDescriptionView.frame.size.height+15, mActionView.frame.size.width, mActionView.frame.size.height)];
    
//    [mScrollView setContentSize:CGSizeMake(mScrollView.frame.size.width, mActionView.frame.size.height+mActionView.frame.origin.y)];
    
    mConstraintScrollContentHeight.constant = mDescriptionView.frame.origin.y + sz.height + 80;
    
    NSLog(@"%f",mDescriptionView.frame.size.height+mDescriptionView.frame.origin.y);
    
    if ([[Engine likeItems] containsObject:self.mItem._id]) {
        mBtnLike.selected=YES;
    }
    else
    {
        mBtnLike.selected=NO;
    }

    [self getOwnerInfo];
}

-(void)getOwnerInfo
{
    _mPerson = self.mItem.user;
    
    if (_mPerson) {
    }
    else
    {
        // TODO: Need to
//        [JPerson loadPersonWithWithID:[self.mItem objectForKey:kItemUserID] completionBlock:^(PFObject *object) {
//            if (object) {
//                _mPerson = object;
//            }
//        }];
    }
}

- (void)showPicker:(UIView *)picker show:(BOOL)bShow animated:(BOOL)bAnimated
{
    if (bAnimated) {
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:0.5f];
    }
    
    if (bShow) {
        
        picker.frame = CGRectMake(0, self.view.frame.size.height - picker.frame.size.height, picker.frame.size.width, picker.frame.size.height);
        
        [self.view bringSubviewToFront:picker];
    }
    else {
        picker.frame = CGRectMake(0, self.view.frame.size.height, picker.frame.size.width, picker.frame.size.height);
    }
    
    if (bAnimated) {
        [UIView commitAnimations];
    }
}


//    
//-(NSString*)getSizeStringFromIndex:(NSString*)indexStr
//{
//    int indexInt=[indexStr intValue];
//
//    if(indexInt<SIZE_GENERIC_TAG+20)
//    {
//        return [[Engine gSizePostConfig].usGenericSizeArray objectAtIndex:indexInt-SIZE_GENERIC_TAG];
//    }
//    else if (indexInt<SIZE_NECK_TAG+20)
//    {
//        return [[Engine gSizePostConfig].usNeckSizeArray objectAtIndex:indexInt-SIZE_NECK_TAG];
//    }
//    else if (indexInt<SIZE_WAIST_TAG+20)
//    {
//        return [[Engine gSizePostConfig].usWaistSizeArray objectAtIndex:indexInt-SIZE_WAIST_TAG];
//    }
//    else
//    {
//        return [[Engine gSizePostConfig].usShoesSizeArray objectAtIndex:indexInt-SIZE_SHOE_TAG];
//    }
//}
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


#pragma mark -
#pragma mark - Touch Event

- (IBAction)onTouchBtnBack: (id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)onTouchBtnFavoritePost:(id)sender {
    if(![[JUser me] isAuthorized])
    {
        [Engine showAlertViewForLogin];
        return;
    }
    
    mBtnLike.selected=!mBtnLike.selected;
    [APIClient likeItem:self.mItem isLike:mBtnLike.selected success:^(JItem *item) {
        
    } failure:^(NSString *errorMessage) {
        [JUtils showMessageAlert:errorMessage];
    }];
}
//-(IBAction)onTouchBtnAddToCart:(id)sender
//{
//    if(![PFUser currentUser])
//    {
//        [Engine showAlertViewForLogin];
//        return;
//    }
////    [self showPicker:self.mCheckoutPopup show:true animated:true];
////    if(![[Engine gShoppingCart] containsObject:self.mItem])
////    {
//        [[Engine gShoppingCart] addObject:self.mItem];
////    }
//}


// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    
    // Pass the selected object to the new view controller.
    if ([segue.identifier isEqualToString:@"showExtraWebView"]) {
        NSDictionary *dict = (NSDictionary*)sender;
        JExtraWebViewViewController *mView = segue.destinationViewController;
        mView.mFileName = [dict objectForKey:@"file"];
        mView.mTitle = [dict objectForKey:@"title"];
        mView.contentSourceType = [dict objectForKey:@"contentSourceType"];
    }
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if ([alertView.title isEqualToString:@"Would you like to signup?"]) {
        if (buttonIndex == 0)
        {//Not Right now
            [self showOrderPopup];
        }
        else if(buttonIndex == 1)
        {
            UIStoryboard* storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            JSignupViewController* viewController = [storyboard instantiateViewControllerWithIdentifier:@"JSignupViewController"];
            viewController.delegate = self;
            
            UINavigationController *mViewController = [[UINavigationController alloc] initWithRootViewController:viewController];
            
            [self.navigationController presentViewController:mViewController animated:true completion:^{
                
            }];
        }
    }
}

- (IBAction)onTouchBtnBuy:(id)sender {
    if ([[Engine gShoppingCart] count] == 0) {
        if (![[JUser me] isAuthorized]) {
            UIAlertView *mAlertView = [[UIAlertView alloc] initWithTitle:@"Would you like to signup?" message:nil delegate:self cancelButtonTitle:@"Not right now" otherButtonTitles:@"Yes", nil];
            [mAlertView show];
            return;
        }
    }
    [self showOrderPopup];
}

- (IBAction)onTouchBtnSubscribe:(id)sender {
    //http://www.iwantfitbox.com/pages/subscribe
    [self performSegueWithIdentifier:@"showExtraWebView" sender:@{@"title":@"SUBSCRIBE", @"file":@"http://www.iwantfitbox.com/pages/subscribe", @"contentSourceType":@"web"}];

}

-(void)showOrderPopup
{
    self.mOrder = nil;
    self.mOrder = [[JOrder alloc] init];
    
    self.mOrder.itemSizeTop = [[Engine gSizeInfo] objectForKey:SIZE_TOPS];
    self.mOrder.itemSizeBottom = [[Engine gSizeInfo] objectForKey:SIZE_BOTTOMS];
    self.mOrder.itemObject = self.mItem;
    
    self.mCheckoutPopup.mOrderInfo = self.mOrder;
    [self.mCheckoutPopup initCheckoutPopup];
    [self showPicker:self.mCheckoutPopup show:true animated:true];
}

//-(BOOL)isTops
//{
//    if ([self.mItem.topBottom isEqualToString:SIZE_TOPS]) {
//        return true;
//    }
//    return false;
//}


-(IBAction)onTouchBtnShare:(id)sender
{
//    if(![PFUser currentUser])
//    {
//        [Engine showAlertViewForLogin];
//        return;
//    }
    [self shareItemInfo:self.mItem];
}

-(void)shareItemInfo:(JItem *)feedInfo{
    NSString *textToShare = [NSString stringWithFormat:@"Check this out! %@  www.iwantfitbox.com", [self.mItem.item_name uppercaseString]];
    
    CGFloat offset1 = mScrollView.contentOffset.y;
    CGFloat offset2 = mPhotoScrollView.contentOffset.x;
    mScrollView.contentOffset= CGPointMake(mScrollView.contentOffset.x, 0);
    mPhotoScrollView.contentOffset = CGPointMake(0, mPhotoScrollView.contentOffset.y);
    UIImage *image=[JUtils imageWithView:mScrollView];

    mScrollView.contentOffset= CGPointMake(mScrollView.contentOffset.x, offset1);
    mPhotoScrollView.contentOffset = CGPointMake(offset2, mPhotoScrollView.contentOffset.y);
    NSArray *objectsToShare = @[textToShare, image];
    
    UIActivityViewController *activityVC = [[UIActivityViewController alloc] initWithActivityItems:objectsToShare applicationActivities:nil];
    
    NSMutableArray *excludeActivities = [[NSMutableArray alloc] initWithObjects:UIActivityTypeAirDrop,
                                         UIActivityTypePrint,UIActivityTypePostToTencentWeibo, UIActivityTypePostToWeibo,
                                         UIActivityTypeSaveToCameraRoll,
                                         UIActivityTypeAddToReadingList,
                                         UIActivityTypePostToFlickr,
                                         UIActivityTypePostToVimeo, UIActivityTypeCopyToPasteboard, nil];

    
    activityVC.excludedActivityTypes = excludeActivities;

    
    [self presentViewController:activityVC animated:YES completion:nil];
}

-(IBAction)onPageControllerChanged:(id)sender
{
    [mPhotoScrollView scrollRectToVisible:CGRectMake(mPhotoPageControl.currentPage*320, 0, mScrollView.frame.size.width, mScrollView.frame.size.height) animated:YES];
//    [self initPlayButtons];
}

-(void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView
{
    
}

-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if(scrollView==mPhotoScrollView)
    {
        mPhotoPageControl.currentPage=mPhotoScrollView.contentOffset.x/320;
//        [self initPlayButtons];
    }
}



#pragma mark - Video Player Part

-(void)onTouchBtnPlay:(id)sender
{
    
//    UIButton* btn=(UIButton*)sender;
//    btn.hidden=YES;
//    
//    if (mAVPlayer != nil)
//    {
//        [mViewVideo.layer.sublayers makeObjectsPerformSelector:@selector(removeFromSuperlayer)];
//        mAVPlayer = nil;
//    }
//    [mPhotoScrollView bringSubviewToFront:mViewVideo];
//    [mPhotoScrollView addSubview:mViewVideo];
//    mViewVideo.tag=btn.tag+200;
//    mViewVideo.hidden=NO;
//    mViewVideo.frame=CGRectMake((btn.tag-PLAY_BUTTON_TAG_START+[self.mItem.photos count])*mPhotoScrollView.frame.size.width,0, mPhotoScrollView.frame.size.width, mPhotoScrollView.frame.size.height);
//    
//    UIImageView *imgView = [[UIImageView alloc] initWithFrame: CGRectMake(0, 0, mViewVideo.frame.size.width, mViewVideo.frame.size.height)];
//    
//    
//    
//    [imgView setImageWithURL:[[JAmazonS3ClientManager defaultManager] cdnUrlForItemVideoThumb:[self.mItem.videos objectAtIndex:btn.tag-PLAY_BUTTON_TAG_START]]];
//    [mViewVideo.layer addSublayer: imgView.layer];
//    
//    AVURLAsset* asset = [AVURLAsset URLAssetWithURL: [[JAmazonS3ClientManager defaultManager] cdnUrlForItemVideo:[self.mItem.videos objectAtIndex:btn.tag-PLAY_BUTTON_TAG_START]] options:nil];
//    AVPlayerItem* item = [AVPlayerItem playerItemWithAsset:asset];
//    mAVPlayer = [AVPlayer playerWithPlayerItem:item];
//    mAVPlayer.actionAtItemEnd = AVPlayerActionAtItemEndNone;
//    
//    [[NSNotificationCenter defaultCenter] addObserver:self
//                                             selector:@selector(playerItemDidReachEnd:)
//                                                 name:AVPlayerItemDidPlayToEndTimeNotification
//                                               object:[mAVPlayer currentItem]];
//    
//    AVPlayerLayer* lay = [AVPlayerLayer playerLayerWithPlayer: mAVPlayer];
//    
//    lay.frame = mViewVideo.bounds;
//    lay.videoGravity = AVLayerVideoGravityResize;
//    [mViewVideo.layer addSublayer:lay];
//    [mAVPlayer play];
}

//-(void)playerItemDidReachEnd:(id)sender
//{
//    [self initPlayButtons];
//}

//-(void)initPlayButtons
//{
//    if(mViewVideo.tag!=0)
//    {
//        UIView *mView=[mPhotoScrollView viewWithTag:mViewVideo.tag-200];
//        if(mView)
//        {
//            mView.hidden=NO;
//        }
//        [mViewVideo.layer.sublayers makeObjectsPerformSelector:@selector(removeFromSuperlayer)];
//        mViewVideo.hidden=YES;
//        mAVPlayer=nil;
//        mViewVideo.tag=0;
//    }
//}


#pragma mark - Popup View Delegate

-(void)openWalletPage:(JPurchaseInfo *)purchaseInfo
{
}



#pragma mark - JCheckout Popup Delegate
-(void)JCheckoutPopupAddToCart
{
    if (([_mCheckoutPopup.mOrderInfo.itemObject hasTop] && !_mCheckoutPopup.mOrderInfo.itemSizeTop) || ([_mCheckoutPopup.mOrderInfo.itemObject hasBottom] && !_mCheckoutPopup.mOrderInfo.itemSizeBottom)) {
        [self.navigationController.view makeToast:@"Size not set" duration:1.5 position:CSToastPositionTop];
    }
    else if(!_mCheckoutPopup.mAddressInfo)
    {
        [self.navigationController.view makeToast:@"Address not set" duration:1.5 position:CSToastPositionTop];
    }
    else if(!_mCheckoutPopup.mCreditCardInfo)
    {
        [self.navigationController.view makeToast:@"Credit card info not set" duration:1.5 position:CSToastPositionTop];
    }
    else
    {
        self.mOrder.itemObject = self.mItem;
        self.mOrder.itemCost = [self.mItem.listingprice floatValue];
        [[Engine gShoppingCart] addObject:self.mOrder];
        [self showPicker:self.mCheckoutPopup show:false animated:true];
        
        
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Would you like to Checkout or Continue shopping?" message:nil preferredStyle:UIAlertControllerStyleAlert];
        [alertController addAction:[UIAlertAction actionWithTitle:@"Keep Shopping" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            
        }]];
        [alertController addAction:[UIAlertAction actionWithTitle:@"Checkout Now" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [self performSegueWithIdentifier:@"segueShoppingCart" sender:nil];
        }]];
        [self presentViewController:alertController animated:true completion:nil];
        [self.navigationController.view makeToast:@"Item added into shopping cart!" duration:1.5 position:CSToastPositionTop];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:SHOPPING_CART_NOTIFICATION object:nil];
    }
}

-(void)JCheckoutPopupCancel
{
    [self showPicker:self.mCheckoutPopup show:false animated:true];
}

-(void)JCheckoutPopupSelectPayment
{
    UIStoryboard* storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    JWalletViewController* viewController = [storyboard instantiateViewControllerWithIdentifier:@"JWalletViewController"];
    viewController.delegate = self;
    
    UINavigationController *mViewController = [[UINavigationController alloc] initWithRootViewController:viewController];
    
    [self.navigationController presentViewController:mViewController animated:true completion:^{
        
    }];
}

-(void)JCheckoutPopupSelectSize
{
    UIStoryboard* storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    JSizeSelectorViewController* viewController = [storyboard instantiateViewControllerWithIdentifier:@"JSizeSelectorViewController"];
    viewController.delegate = self;
    
    if ([self.mItem hasTop] && [self.mItem hasBottom]) {
        viewController.mPageType = SIZE_PAGE_BOTH;
        viewController.mSizeBottom = self.mOrder.itemSizeBottom;
        viewController.mSizeTops = self.mOrder.itemSizeTop;
    }
    else if ([self.mItem hasTop]) {
        viewController.mPageType = SIZE_PAGE_TOPS;
        viewController.mSizeTops = self.mOrder.itemSizeTop;
    }
    else
    {//Then Bottom Only
        viewController.mPageType = SIZE_PAGE_BOTTOMS;
        viewController.mSizeBottom = self.mOrder.itemSizeBottom;
    }
    
    UINavigationController *mViewController = [[UINavigationController alloc] initWithRootViewController:viewController];
    
    [self.navigationController presentViewController:mViewController animated:true completion:^{
        
    }];
    
}

-(void)JCheckoutPopuSelectShippingAddress
{
    UIStoryboard* storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    JShippingAddressViewController* viewController = [storyboard instantiateViewControllerWithIdentifier:@"JShippingAddressViewController"];
    viewController.delegate = self;
    viewController.mAddress = self.mCheckoutPopup.mAddressInfo;
    
    UINavigationController *mViewController = [[UINavigationController alloc] initWithRootViewController:viewController];
    
    [self.navigationController presentViewController:mViewController animated:true completion:^{
        
    }];
}

#pragma mark Wallet Delegate

-(void)JWalletViewControllerCardChosen:(JCreditCardInfo *)cardInfo
{
    self.mCheckoutPopup.mCreditCardInfo = cardInfo;
    [Engine setGCreditCard: cardInfo];
    [Engine saveInfoToUserDefault];

    [self.mCheckoutPopup initCheckoutPopup];

    [self.navigationController dismissViewControllerAnimated:true completion:^{
        
    }];
}
-(void)JWalletViewControllerCancel
{
    [self.navigationController dismissViewControllerAnimated:true completion:^{
        
    }];
}

#pragma mark - Address View Delegate

-(void)JShippingAddressViewControllerCancel
{
    [self.navigationController dismissViewControllerAnimated:true completion:^{
        
    }];
}
-(void)JShippingAddressViewControllerAddressChosen:(JAddressInfo *)address
{
    self.mCheckoutPopup.mAddressInfo = address;
    [Engine setGAddress: address];
    [Engine saveInfoToUserDefault];
    [self.mCheckoutPopup initCheckoutPopup];
    [self.navigationController dismissViewControllerAnimated:true completion:^{
        
    }];
}

#pragma mark - Size Selector Delegate

-(void)JSizeSelectorViewControllerCancel
{
    [self.navigationController dismissViewControllerAnimated:true completion:^{
        
    }];
}
-(void)JSizeSelectorViewControllerSizeSelected:(NSString *)sizeTop sizeBottom:(NSString *)sizeBottom
{
    if ([self.mItem hasTop]) {
        self.mOrder.itemSizeTop = sizeTop;
    }
    
    if([self.mItem hasBottom])
    {
        self.mOrder.itemSizeBottom = sizeBottom;
    }
    
//    self.mCheckoutPopup. = sizeSelected;
    [self.mCheckoutPopup initCheckoutPopup];
    [self.navigationController dismissViewControllerAnimated:true completion:^{
        
    }];
}

#pragma mark - Signup ViewController Delegate

-(void)JSignupViewControllerCancel
{
    [self.navigationController dismissViewControllerAnimated:true completion:^{
        
    }];
}

-(void)JSignupViewControllerSuccess
{
    [self.navigationController dismissViewControllerAnimated:true completion:^{
        [self showOrderPopup];
    }];
}
@end
