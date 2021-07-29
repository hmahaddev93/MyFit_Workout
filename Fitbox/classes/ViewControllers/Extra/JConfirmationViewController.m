//
//  JConfirmationViewController.m
//  Zold
//
//  Created by Khatib H. on 8/25/14.
//  
//

#import "JConfirmationViewController.h"
#import "ViewController.h"
#import "JAmazonS3ClientManager.h"

@interface JConfirmationViewController ()

@end

@implementation JConfirmationViewController

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
    // Do any additional setup after loading the view from its nib.
//    [self initTopRightProfilePhoto];
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

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    JAddressInfo *address = [Engine gAddress];
    mLblShippingAddress.text=[NSString stringWithFormat:@"%@ %@", address.shipAddress, address.shipAddressExtra];
    mLblShippingCityState.text=[NSString stringWithFormat:@"%@, %@",address.shipCity, address.shipState];
    mLblShippingFullName.text=[NSString stringWithFormat:@"%@ %@", address.shipFirstName, address.shipLastName];
    mLblShippingZipCode.text=address.shipZipcode;
//    mLblShippingNumber.text=[NSString stringWithFormat:@"%d ITEM SHIPPING TO:", [[Engine gShoppingCart] count]];
    mLblShippingNumber.text=[NSString stringWithFormat:@"%d ITEM SHIPPING TO:", (int)[[Engine gShoppingCart] count]];
    
    if ([[JUser me] isAuthorized]) {
        mLblThanks.text=[NSString stringWithFormat:@"THANK YOU, %@!", [[JUser me].fullName uppercaseString]];
    }
    else
    {
        mLblThanks.text=[NSString stringWithFormat:@"THANK YOU, %@!", [address.shipFirstName uppercaseString]];
    }
}

#pragma mark - Touch Event

-(IBAction)onTouchBtnContinueShopping:(id)sender
{
//    [Engine setIsBackAction:NO];
//    JViewController *mView=[JViewController sharedController];
//    [self.navigationController popToViewController:mView.mJASidePanel animated:YES];
    [[Engine gShoppingCart] removeAllObjects];
    [[NSNotificationCenter defaultCenter] postNotificationName:SHOPPING_CART_NOTIFICATION object:nil];
    [self.navigationController popToRootViewControllerAnimated:true];
    [[NSNotificationCenter defaultCenter] postNotificationName: BACK_TO_MAIN_VIEW object: sender];
}
@end
