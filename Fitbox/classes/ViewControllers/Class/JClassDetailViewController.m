//
//  JClassDetailViewController.m
//  Fitbox
//
//  Created by Khatib H. on 2/18/16.
//  
//

#import "JClassDetailViewController.h"
#import "JAmazonS3ClientManager.h"
#import "JMessageViewController.h"
#import "JSelectLocationViewController.h"
#import "JPushMethods.h"

#define ACCEPT_LISTING_MESSAGE @"Id like workout!"
@interface JClassDetailViewController ()<JSelectLocationViewControllerDelegate>
{
    IBOutlet UIImageView *mImgPhoto;
    IBOutlet UILabel *mLblUsername;
    IBOutlet UILabel *mLblClassType;
    IBOutlet UIButton *mBtnPlaceName;
    IBOutlet UILabel *mLblGenderPreference;
    IBOutlet UILabel *mLblComments;
    IBOutlet UILabel *mLblPrice;
    
    IBOutlet UILabel *mLblLocation;
    
    IBOutlet NSLayoutConstraint *mHeightConstraint;

    JMessageHistory *mMessageHistory;
    NSString *roomID;
}


@end

@implementation JClassDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self initView];
    [self updateUnreadMessageCount];
    [APIClient checkNewMessages];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateUnreadMessageCount) name:NOTIF_MESSAGE_COUNT_UPDATED object:nil];
}
-(void)updateUnreadMessageCount
{
    if ([Engine gNewMessageCount]>0) {
        self.navigationItem.rightBarButtonItem.badgeValue = [NSString stringWithFormat:@"%d", [Engine gNewMessageCount]];
    }
    else
    {
        self.navigationItem.rightBarButtonItem.badgeValue = @"";
        //        self.navigationItem.rightBarButtonItem.badgeBGColor = [UIColor clearColor];
    }
}
-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIF_MESSAGE_COUNT_UPDATED object:nil];
}

-(void)initView
{
    [mImgPhoto setImageWithURL:[[JAmazonS3ClientManager defaultManager] cdnUrlForItemPhoto:_mListing.photo]];

    
    _mPerson = _mListing.user;
    
    if (_mPerson) {
        mLblUsername.text = _mPerson.username;
    }
    else
    {
        // TODO-We need ton mvbcn
//        [JUtils showLoadingIndicator:self.view message:@"Loading user info.."];
//        [JPerson loadPersonWithWithID:[_mListing objectForKey:kUserId] completionBlock:^(PFObject *object) {
//            [JUtils hideLoadingIndicator:self.view];
//            if(object)
//            {
//                _mPerson = object;
//                mLblUsername.text = [_mPerson objectForKey:kUserUserName];
//            }
//            else
//            {
//                [self.navigationController.view makeToast:@"Failed to load user information" duration:1.0 position:CSToastPositionTop];
//                [self.navigationController popToRootViewControllerAnimated:true];
//            }
//        }];
    }
    
    mLblClassType.text = _mListing.classType;
    
//    [mBtnPlaceName setTitle:[_mListing objectForKey:kListingPlaceName] forState:UIControlStateNormal];
    mLblLocation.text = _mListing.placeName;
    
    NSString *genderPrefString = @"M/F";
    if ([_mListing.genderPref isEqualToString:@"M"]) {
        genderPrefString = @"M";
    }
    else if([_mListing.genderPref isEqualToString:@"F"]) {
        genderPrefString = @"F";
    }
    mLblGenderPreference.text = genderPrefString;
    
    mLblComments.text = _mListing.comments;
//    NSString *comments = [_mListing objectForKey:kListingComments];
    CGSize sz = [mLblComments sizeThatFits:CGSizeMake(mLblComments.frame.size.width, 100000)];
//    [mL]
    
    mHeightConstraint.constant = sz.height + SCREEN_WIDTH + 10 + 65 + 10 + 10 + 60 + 10;
    
    if ([_mListing.payPref boolValue]) {
        mLblPrice.text = @"FREE";
    }
    else
    {
        mLblPrice.text = [NSString stringWithFormat:@"$%.2f", [_mListing.price doubleValue]];
    }
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
    if ([segue.identifier isEqualToString:@"showMessageView"]) {
        JMessageViewController *messageView = (JMessageViewController*)segue.destinationViewController;
        messageView.mListing = _mListing;
        messageView.mPerson = _mPerson;
    }
}


-(IBAction)onBtnBack:(id)sender
{
    [self.navigationController popViewControllerAnimated:true];
}

-(IBAction)onTouchBtnLocation:(id)sender
{
    
    UIStoryboard* storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    
    JSelectLocationViewController *mLocationView = [storyboard instantiateViewControllerWithIdentifier:@"JSelectLocationViewController"];
    mLocationView.delegate = self;
    mLocationView.isSelectLocation = false;
    
    mLocationView.mLat = [_mListing.lnglat objectAtIndex:1];
    mLocationView.mLng = [_mListing.lnglat objectAtIndex:0];
    
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:mLocationView];
    
    [self presentViewController:navigationController animated:true completion:^{
        
    }];
}

-(IBAction)onBtnAccept:(id)sender
{
    if(_mListing.signupURL && ![_mListing.signupURL isEqualToString:@""])
    {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:_mListing.signupURL]];
        return;
    }
    
    
    if (![[JUser me] isAuthorized]) {
        [Engine showAlertViewForLogin];
        return;
    }
    if ([_mListing.user._id isEqualToString:[JUser me]._id]) {
        [self.navigationController.view makeToast:@"You can't RSVP your own posting!" duration:1.5 position:CSToastPositionTop];
        return;
    }

    if ([_mListing.status isEqualToString:kListingStatusOpen]) {
        [JUtils showLoadingIndicator:self.navigationController.view message:@"RSVP...."];
        [APIClient  acceptListing:_mListing._id success:^(JListing *item, JMessageHistory *messageHistory) {
            [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_REMOVE_LISTING object: _mListing];
            [JUtils hideLoadingIndicator:self.navigationController.view];
            [JPushMethods acceptListing:_mListing];
            [self acceptCompleteAndGotoMessage];
        } failure:^(NSString *errorMessage) {
            [JUtils hideLoadingIndicator:self.navigationController.view];
            [self.navigationController.view makeToast:errorMessage duration:1.5 position:CSToastPositionTop];
        }];
    }
    else
    {
        [self.navigationController.view makeToast:@"Listing is not open!" duration:1.5 position:CSToastPositionTop];
    }
}

-(void)acceptCompleteAndGotoMessage
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.navigationController.view makeToast:@"RSVP request have been posted!" duration:1.5 position:CSToastPositionTop];
        [self performSegueWithIdentifier:@"showMessageView" sender:_mPerson];
    });
}

-(BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender
{
    if (![[JUser me] isAuthorized]) {
        if ([identifier isEqualToString:@"showMessageHistory"]) {
            [Engine showAlertViewForLogin];
            return false;
        }
    }
    return true;
}
-(IBAction)onBtnMessage:(id)sender
{
    if (![[JUser me] isAuthorized]) {
        [Engine showAlertViewForLogin];
        return;
    }
    if ([_mListing.user._id isEqualToString:[JUser me]._id]) {
        [self.navigationController.view makeToast:@"You can't send a message to yourself!" duration:1.5 position:CSToastPositionTop];
        return;
    }    
    [self performSegueWithIdentifier:@"showMessageView" sender:_mPerson];
}


-(void)JSelectLocationViewControllerDelegateCancel
{
    [self dismissViewControllerAnimated:true completion:^{
        
    }];
}

-(void)JSelectLocationViewControllerDelegateLocationSelected:(double)lat lng:(double)lng
{
    [self dismissViewControllerAnimated:true completion:^{
        
    }];
}


@end
