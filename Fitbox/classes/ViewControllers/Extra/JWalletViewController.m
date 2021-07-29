//
//  JWalletViewController.m
//  Zold
//
//  Created by Khatib H. on 8/24/14.
//  
//

#import "JWalletViewController.h"
#import "JConfirmationViewController.h"
#import "CardIO.h"
//#import "Stripe+ApplePay.h"
//#import "PKPayment+STPTestKeys.h"
#import <AddressBook/AddressBook.h>
#import "JAmazonS3ClientManager.h"


@interface JWalletViewController () <UITextFieldDelegate> {
@private
    BOOL isInitialState;
    BOOL isValidState;
}

//
//- (void)setupCardNumberField;
//- (void)setupCardExpiryField;
//- (void)setupCardCVCField;
//
//- (void)setPlaceholderToCVC;
//- (void)setPlaceholderToCardType;
//
//- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)replacementString;
//- (BOOL)cardNumberFieldShouldChangeCharactersInRange: (NSRange)range replacementString:(NSString *)replacementString;
//- (BOOL)cardExpiryShouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)replacementString;
//- (BOOL)cardCVCShouldChangeCharactersInRange: (NSRange)range replacementString:(NSString *)replacementString;
//
//- (void)checkValid;
//- (void)textFieldIsValid:(UITextField *)textField;
//- (void)textFieldIsInvalid:(UITextField *)textField withErrors:(BOOL)errors;

@end

@implementation JWalletViewController

@synthesize delegate;



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
//    mDictionary=[[JUser currentUserSingleton] creditDataDecrypted];
//    [self setupCardNumberField];
//    [self setupCardCVCField];
//    [self setupCardExpiryField];

    [self setupCardField];
    
//    self.cardCVCField = self.paymentTextField.cvcField;
//    self.cardNumberField = self.paymentTextField.numberField;
//    self.cardExpiryField = self.paymentTextField.expirationField;
    
//    [mViewCredits addSubview:cardCVCField];
//    [mViewCredits addSubview:cardExpiryField];
//    [mViewCredits addSubview:cardNumberField];

//    [CardIOPaymentViewController preload];
    
    
//    PKPaymentRequest *paymentRequest = [Stripe paymentRequestWithMerchantIdentifier:@"merchant.com.lowekeymedia.zold"];
//    JItem *item=[[Engine gFeedDict] objectForKey:self.mPurchase.itemId];
//    NSString *label=item.item_name;
//    NSDecimalNumber *amount=[NSDecimalNumber decimalNumberWithString:[NSString stringWithFormat:@"%.2f",[self.mPurchase.purchaseCost floatValue]]];
//    
//    
//    paymentRequest.paymentSummaryItems=[[NSArray alloc] initWithObjects:[PKPaymentSummaryItem summaryItemWithLabel:label amount:amount], nil];
//    
//    paymentRequest.requiredShippingAddressFields = PKAddressFieldPhone | PKAddressFieldPostalAddress;
    
    [self.navigationItem.rightBarButtonItem setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys: [UIFont fontWithName:FONT_NAME_AAUX_PROREGULAR size:12], NSFontAttributeName, nil] forState:UIControlStateNormal];
    [self.navigationItem.leftBarButtonItem setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys: [UIFont fontWithName:FONT_NAME_AAUX_PROREGULAR size:12], NSFontAttributeName, nil] forState:UIControlStateNormal];
//    [[UIBarButtonItem appearance] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys: [UIFont fontWithName:FONT_NAME_AAUX_PROREGULAR size:12], NSFontAttributeName, nil] forState:UIControlStateNormal];
//    [self initTopRightProfilePhoto];
}

-(void)initView
{
    
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    [ [ NSNotificationCenter defaultCenter ] addObserver : self selector : @selector( onShowKeyBoard : ) name : UIKeyboardWillShowNotification object : nil ];
    [ [ NSNotificationCenter defaultCenter ] addObserver : self selector : @selector( onHideKeyBoard : ) name : UIKeyboardWillHideNotification object : nil ];

}
-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}
-(void)initTopRightProfilePhoto
{
    if ([[JUser  me] isAuthorized]) {
        _mImgProfilePhotoTopRight.hidden = false;
        NSString *profilePhoto = [JUser me].profilePhoto;
        _mImgProfilePhotoTopRight.image = [UIImage imageNamed:@"app_icon"];
        if (profilePhoto && ![profilePhoto isEqualToString:@""]) {
            [_mImgProfilePhotoTopRight setImageWithURL:[[JAmazonS3ClientManager defaultManager] cdnUrlForProfilePhotoThumb:profilePhoto]];
        }
    }
    else
    {
        _mImgProfilePhotoTopRight.image = [UIImage imageNamed:@"app_icon"];
    }
}

-(IBAction)onTouchBtnCancel:(id)sender
{
    [self.view endEditing:YES];
    if ([(id)delegate respondsToSelector:@selector(JWalletViewControllerCancel)]) {
        [delegate JWalletViewControllerCancel];
    }
    else
    {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

-(NSString*)getBrandFromCard:(STPCard*)card
{
    if (card.brand == STPCardBrandAmex)
    {
        return @"Amex";
    }
    else if(card.brand == STPCardBrandDinersClub)
    {
        return @"Diners Club";
    }
    else if(card.brand == STPCardBrandVisa)
    {
        return @"Visa";
    }
    else if(card.brand == STPCardBrandMasterCard)
    {
        return @"Master Card";
    }
    else if(card.brand == STPCardBrandDiscover)
    {
        return @"Discover";
    }
    else if(card.brand == STPCardBrandJCB)
    {
        return @"JCB";
    }
    return @"Unknown";
}

-(IBAction)onTouchBtnDone:(id)sender
{
    if(![self.paymentTextField isValid])
    {
        [JUtils showMessageAlert:@"Credit Card Information is not Valid!"];
        return;
    }
    [self.view endEditing:YES];
    
    JCreditCardInfo *mInfo = [[JCreditCardInfo alloc] init];
    
    mInfo.cardNumber = self.paymentTextField.cardNumber;
    mInfo.cardCVC = self.paymentTextField.cvc;
    mInfo.cardExpireMonth = [NSString stringWithFormat:@"%d", (int)self.paymentTextField.expirationMonth];
    mInfo.cardExpireYear = [NSString stringWithFormat:@"%d", (int)self.paymentTextField.expirationYear];
    mInfo.cardBankName = [self getBrandFromCard:self.paymentTextField.card];
    
    if ([(id)delegate respondsToSelector:@selector(JWalletViewControllerCardChosen:)]) {
        [delegate JWalletViewControllerCardChosen: mInfo];
    }
    else
    {
        [Engine setGCreditCard: mInfo];
        [self.navigationController popViewControllerAnimated:YES];
    }
}
//
//- (void)createToken
//{
//    if (pending) return;
//    
//    
//    PTKCard *card = self.card;
//    
//    STPCard *scard = [[STPCard alloc] init];
//    
//    scard.number = card.number;
//    scard.expMonth = card.expMonth;
//    scard.expYear = card.expYear;
//    scard.cvc = card.cvc;
//    scard.addressZip=card.addressZip;
//    
//    pending=YES;
//    
//    [Stripe createTokenWithCard:scard completion:^(STPToken *token, NSError *error) {
//        NSLog(@"Token: %@   Error: %@", token, error);
//        if(error)
//        {
//            pending=false;
//            [JUtils showMessageAlert:[NSString stringWithFormat:@"Error: %@", [error localizedDescription]]];
//            [JUtils hideLoadingIndicator:self.navigationController.view];
////            [mProgress hide:YES];
//        }
//        else
//        {
//            [self sendChargeToParse:token completion:nil];
//        }
//        
//    }];
//    
//}
//
//
//-(void)sendChargeToParse:(STPToken*)token completion:(void (^)(PKPaymentAuthorizationStatus))completion
//{
//
//    NSDictionary *chargeParams = @{
//                                   @"token": token.tokenId,
//                                   @"currency": @"usd",
//                                   @"amount": self.mPurchase.purchaseCost, // this is in dollar (i.e. $10)
//                                   @"item":self.mPurchase.itemId,
//                                   @"shipFullName": self.mPurchase.shipFullName,
//                                   @"shipAddress": self.mPurchase.shipAddress,
//                                   @"shipCity": self.mPurchase.shipCity,
//                                   @"shipState": self.mPurchase.shipState,
//                                   @"shipZipcode": self.mPurchase.shipZipcode,
//                                   @"shipPhone": self.mPurchase.shipPhone,
//                                   };
//    
//    
//    // This passes the token off to our payment backend, which will then actually complete charging the card using your account's
//    [PFCloud callFunctionInBackground:@"charge" withParameters:chargeParams block:^(id object, NSError *error) {
//        [JUtils hideLoadingIndicator:self.navigationController.view];
//        pending=false;
//        if (error) {
//            [JUtils showMessageAlert:[NSString stringWithFormat:@"Error: %@",[error localizedDescription]]];
//            if(completion)
//            {
//                completion(PKPaymentAuthorizationStatusFailure);
//            }
//            return;
//        }
//
//        [PFCloud callFunctionInBackground:@"sendPurchaseEmailToAdmin" withParameters:chargeParams block:^(id object, NSError *error1) {
//            NSLog(@"Cloud Code Response %@   Error: %@",object,error1);
//        }];
//        if(completion)
//        {
//            completion(PKPaymentAuthorizationStatusSuccess);
//        }
//        
//        [self performSegueWithIdentifier:@"showConfirm" sender:self.mPurchase];
//    }];
//}
//



- (void)setupCardField
{
    self.paymentTextField = [[STPPaymentCardTextField alloc] initWithFrame:CGRectMake(15,20,SCREEN_WIDTH - 30,40)];
    //    cardNumberField.textColor = [UIColor blackColor];
    [mViewCredits addSubview:self.paymentTextField];
}

//- (void)stateCardCVC
//{
//    [cardCVCField becomeFirstResponder];
//}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return NO;
}

- (void)onShowKeyBoard: (NSNotification *)notification
{
    [mScrollView setContentInset:UIEdgeInsetsMake(0, 0, 250, 0)];
}

- (void)onHideKeyBoard: (NSNotification *)notification
{
    [mScrollView setContentInset:UIEdgeInsetsMake(0, 0, 0, 0)];
}

@end
