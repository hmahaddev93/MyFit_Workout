//
//  JProfileViewController.m
//  Zold
//
//  Created by Khatib H. on 7/05/14.
//  Copyright (c) 2014 Khatib Mobile. All rights reserved.
//


#import "JProfileViewController.h"
#import "JExtraWebViewViewController.h"
#import "JAmazonS3ClientManager.h"

@interface JProfileViewController ()

@end

@implementation JProfileViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationItem.rightBarButtonItem.badgeValue = @"";

    self.navigationItem.leftBarButtonItem.badgeValue = @"";
//    [self updateShoppingCartBadge];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateShoppingCartBadge) name:SHOPPING_CART_NOTIFICATION object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateListingCount) name:NOTIF_CLASS_LISTING_COUNT_UPDATED object:nil];
}

-(void)updateShoppingCartBadge
{
    if ([[Engine gShoppingCart] count]>0) {
        self.navigationItem.rightBarButtonItem.badgeValue = [NSString stringWithFormat:@"%d", (int)[[Engine gShoppingCart] count]];
//        self.navigationItem.rightBarButtonItem.badgeBGColor = [UIColor redColor];
//        self.navigationItem.rightBarButtonItem.badgeTextColor = [UIColor whiteColor];
//        self.navigationItem.rightBarButtonItem.badge.layer.masksToBounds = true;
//        self.navigationItem.rightBarButtonItem.badge.layer.cornerRadius =  self.navigationItem.rightBarButtonItem.badge.frame.size.width / 2.0;
        //        self.navigationItem.rightBarButtonItem.b
    }
    else
    {
        self.navigationItem.rightBarButtonItem.badgeValue = @"";
//        self.navigationItem.rightBarButtonItem.badgeBGColor = [UIColor clearColor];
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

- (void)viewDidUnload
{
    [super viewDidUnload];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
//    [self initTopRightProfilePhoto];
    [self updateShoppingCartBadge];
    [self updateListingCount];

    
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
    if ([segue.identifier isEqualToString:@"showExtraWebView"]) {
        NSDictionary *dict = (NSDictionary*)sender;
        JExtraWebViewViewController *mView = segue.destinationViewController;
        mView.mFileName = [dict objectForKey:@"file"];
        mView.mTitle = [dict objectForKey:@"title"];
        mView.contentSourceType = [dict objectForKey:@"contentSourceType"];
    }
    else if ([segue.identifier isEqualToString:@"showSizeSelector"])
    {
        JSizeSelectorViewController *controller = (JSizeSelectorViewController*)segue.destinationViewController;
        controller.mPageType = SIZE_PAGE_MY_SIZE;
        controller.mSizeTops = [[Engine gSizeInfo] objectForKey:SIZE_TOPS];
        controller.mSizeBottom = [[Engine gSizeInfo] objectForKey:SIZE_BOTTOMS];
        controller.delegate = self;
    }
    else if ([segue.identifier isEqualToString:@""])
    {
        
    }
}

//
//-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
//{
//    if(buttonIndex==0)//Camera
//    {
//        [[JUser currentUserSingleton] favoritePost:postToAction owner:[JUser currentUserSingleton].objectId];
//    }
//    else if(buttonIndex==1)//Photo Album
//    {
//        [[JUser currentUserSingleton] flagPost:postToAction owner:[JUser currentUserSingleton].objectId];
//    }
//}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


#pragma mark - Touch Event


- (IBAction)onTouchBtnLeftView: (id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)onTouchBtnRightView: (id)sender
{
    [[NSNotificationCenter defaultCenter] postNotificationName: HOME_RIGHTBTN_TOUCH object: nil];
}

-(IBAction)onTouchBtnEditProfile:(id)sender
{
    [self performSegueWithIdentifier:@"showEditProfile" sender:nil];
}



- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 5;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section ==0) {
        return 2;
    }
    else if(section == 1)
    {
        return 2;
    }
    else if (section == 2)
    {
        return 5;
    }
    return 1;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 28;
}

-(UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
//    UIView *mLabelContainer = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 28)];

    UILabel *mLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 0, SCREEN_WIDTH, 28)];
    mLabel.backgroundColor = MAIN_COLOR_LIGHT_GRAY;
    mLabel.textAlignment = NSTextAlignmentCenter;
    mLabel.font = [UIFont fontWithName:@"Aaux ProRegular" size:10];
    if (section == 0) {
        mLabel.text = @"Profile";
    }
    else if (section == 1)
    {
        mLabel.text = @"Preferences";
    }
    else if (section == 2)
    {
        mLabel.text = @"Support";
    }
    else if (section == 3)
    {
        mLabel.text = @"Social";
    }
    return mLabel;
}
#pragma tableview delegate

#pragma mark - Table view delegate


- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell* cell = [ tableView dequeueReusableCellWithIdentifier : @"ProfileTableViewCell" ] ;
    UILabel *mLblTitle = [cell viewWithTag:100];
    mLblTitle.textColor = [UIColor blackColor];
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            mLblTitle.text = @"My Account";
        }
        else
        {
            mLblTitle.text = @"My Likes";
        }
    }
    else if (indexPath.section == 1) {
        if (indexPath.row == 0) {
            mLblTitle.text = @"Size";
        }
        else
        {
            mLblTitle.text = @"Payment Methods";
        }
    }
    else if (indexPath.section == 2)
    {
        if (indexPath.row == 0)
        {
            mLblTitle.text = @"Returns";
        }
        else if (indexPath.row == 1)
        {
            mLblTitle.text = @"Contact Service";
        }
        else if(indexPath.row == 2)
        {
            mLblTitle.text = @"Privacy Policy";
        }
        else if(indexPath.row == 3)
        {
            mLblTitle.text = @"Terms of Service";
        }
        else if(indexPath.row == 4)
        {
            mLblTitle.text = @"Skip or Cancel Membership";
        }
    }
    else if (indexPath.section == 3)
    {
//        if (indexPath.row == 0) {
//            mLblTitle.text = @"Invite Friends";
//        }
//        else
//        {
            mLblTitle.text = @"Fitlife";
//        }
    }
    else if (indexPath.section == 4)
    {
        mLblTitle.textColor = [UIColor redColor];
        mLblTitle.text = @"Logout";
    }
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            [self performSegueWithIdentifier:@"showEditProfile" sender:nil];
        }
        else
        {
            [self performSegueWithIdentifier:@"showMyLikes" sender:nil];
        }
    }
    else if (indexPath.section == 1) {
        if (indexPath.row == 0) {
            [self performSegueWithIdentifier:@"showSizeSelector" sender:nil];
        }
        else
        {
            [self performSegueWithIdentifier:@"showPaymentMethods" sender:nil];
        }
    }
    else if (indexPath.section == 2)
    {
        if (indexPath.row == 0) {
            [self performSegueWithIdentifier:@"showExtraWebView" sender:@{@"title":@"RETURNS", @"file":@"http://www.iwantfitbox.com/pages/shipping-and-returns", @"contentSourceType":@"web"}];
        }
        else if (indexPath.row == 1) {
            [self performSegueWithIdentifier:@"showExtraWebView" sender:@{@"title":@"CONTACT SERVICE", @"file":@"http://www.iwantfitbox.com/pages/contact-us", @"contentSourceType":@"web"}];
        }
        else if(indexPath.row == 2)
        {
            [self performSegueWithIdentifier:@"showExtraWebView" sender:@{@"title":@"PRIVACY POLICY", @"file":@"http://www.iwantfitbox.com/pages/privacy-policy", @"contentSourceType":@"web"}];
        }
        else  if(indexPath.row == 3)
        {
            [self performSegueWithIdentifier:@"showExtraWebView" sender:@{@"title":@"TERMS OF SERVICE", @"file":@"http://www.iwantfitbox.com/pages/terms-of-service", @"contentSourceType":@"web"}];
        }
        else  if(indexPath.row == 4)
        {
            [self performSegueWithIdentifier:@"showCancelMembership" sender:nil];
//            [self performSegueWithIdentifier:@"showExtraWebView" sender:@{@"title":@"About", @"file":@"about"}];
        }
    }
    else if (indexPath.section == 3) {
//        if (indexPath.row == 0) {
//            [self performSegueWithIdentifier:@"showContacts" sender:nil];
//        }
//        else
//        {
            [self performSegueWithIdentifier:@"showFitlife" sender:nil];
//        }
    }
    else if (indexPath.section == 4)
    {//Logout
        [[Engine likeItems] removeAllObjects];
        [[Engine gShoppingCart] removeAllObjects];
        [Engine setGAddress:nil];
        [Engine setGCreditCard:nil];

        [[JUser me] logout];
        [Engine setGNewMessageCount:0];
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_MESSAGE_COUNT_UPDATED object:nil];
        [JUtils hideLoadingIndicator:self.navigationController.view];

        [[NSNotificationCenter defaultCenter] postNotificationName:BACK_TO_LOGIN_VIEW object:nil];
        
        
        
    }

}

-(void)JSizeSelectorViewControllerCancel
{
    
}
-(void)JSizeSelectorViewControllerSizeSelected:(NSString *)sizeTop sizeBottom:(NSString *)sizeBottom
{
    [[Engine gSizeInfo] setObject:sizeTop forKey:SIZE_TOPS];
    [[Engine gSizeInfo] setObject:sizeBottom forKey:SIZE_BOTTOMS];
    [Engine saveInfoToUserDefault];
}

@end
