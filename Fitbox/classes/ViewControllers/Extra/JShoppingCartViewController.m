//
//  JShoppingCartViewController.m
//  Fitbox
//
//  Created by Khatib H. on 11/12/15.
//  
//

#import "JShoppingCartViewController.h"

#define SHIPPING_COST 8.95

@interface JShoppingCartViewController ()
{
    BOOL pending;
}

@end

@implementation JShoppingCartViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _mArrData = [Engine gShoppingCart];
    _mTView.tableFooterView = _mViewSummary;
    pending = false;
    
    [self calculateOrderSummary];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

-(IBAction)onBtnBack:(id)sender
{
    [self.navigationController popViewControllerAnimated:true];
}

-(IBAction)onTouchBtnCheckout:(id)sender
{
    if ([_mArrData count]==0) {
        [self.navigationController.view makeToast:@"No items in shopping cart!" duration:1.5 position:CSToastPositionTop];
    }
    else
    {
        [self createToken];
    }
}

-(void)calculateOrderSummary
{
    float totalPrice = 0;
    for (int i=0; i<[_mArrData count]; i++) {
        JOrder *order = [_mArrData objectAtIndex:i];
        totalPrice += order.itemCost;
    }
    if ([_mArrData count] == 0) {
        _mLblShippingPrice.text = @"$0.00";
    }
    else
    {
        _mLblShippingPrice.text =[NSString stringWithFormat:@"$%.2f", SHIPPING_COST];
        totalPrice = totalPrice + SHIPPING_COST;
    }
    _mLblTotalPrice.text = [NSString stringWithFormat:@"$%.2f", totalPrice];
}


#pragma tableview delegate

#pragma mark - Table view delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [_mArrData count];
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    //    if((mIsSearch)&&([[Engine mIsFavourite] isEqualToString:@"1"])
    return 1;//[_mArrData count];
}

-(UIView*)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    return nil;
}
- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    JShoppingCartTableViewCell* cell = [ tableView dequeueReusableCellWithIdentifier : @"JShoppingCartTableViewCell" ] ;
    cell.delegate=self;

    JOrder *order = [_mArrData objectAtIndex:indexPath.section];
    [cell initCellWithOrder:order];
    return cell;
}


#pragma mark - JShoppingCartTableViewCell Delegate

-(void)JShoppingCartTableViewCellRemoveOrder:(JOrder *)order
{
    [_mArrData removeObject:order];
    [self calculateOrderSummary];
    [_mTView reloadData];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:SHOPPING_CART_NOTIFICATION object:nil];
}




#pragma mark - Payment

- (void)createToken
{
    if (pending) return;
    
    
//    PTKCard *card = self.card;
    JCreditCardInfo *cardInfo = [Engine gCreditCard];
    STPCard *scard = [[STPCard alloc] init];
    
    scard.number = cardInfo.cardNumber;
    scard.expMonth = [cardInfo.cardExpireMonth integerValue];
    scard.expYear = [cardInfo.cardExpireYear integerValue];
    scard.cvc = cardInfo.cardCVC;
//    scard.addressZip=card.addressZip;
    
    pending=YES;
    
    [JUtils showLoadingIndicator: self.navigationController.view message:@"Checking out..."];
//    [Stripe createTokenWithCard:scard completion:^(STPToken *token, NSError *error) {
//        NSLog(@"Token: %@   Error: %@", token, error);
//        if(error)
//        {
//            pending=false;
//            [JUtils showMessageAlert:[NSString stringWithFormat:@"Error: %@", [error localizedDescription]]];
//            [JUtils hideLoadingIndicator:self.navigationController.view];
//            //            [mProgress hide:YES];
//        }
//        else
//        {
//            [self sendChargeToParse:token completion:nil];
//        }
//        
//    }];
    
    [[STPAPIClient sharedClient] createTokenWithCard:scard completion:^(STPToken * _Nullable token, NSError * _Nullable error) {
        NSLog(@"Token: %@   Error: %@", token, error);
        if(error)
        {
            pending=false;
            [JUtils showMessageAlert:[NSString stringWithFormat:@"Error: %@", [error localizedDescription]]];
            [JUtils hideLoadingIndicator:self.navigationController.view];
            //            [mProgress hide:YES];
        }
        else
        {
            [self sendChargeToParse:token completion:nil];
        }
    }];
    

    
}


-(void)sendChargeToParse:(STPToken*)token completion:(void (^)(PKPaymentAuthorizationStatus))completion
{
    NSArray *orders = [Engine gShoppingCart];
    float totalCost = 0.0;
    NSMutableArray *mItemIds=[[NSMutableArray alloc] init];
    NSMutableArray *mItemSizes=[[NSMutableArray alloc] init];
    NSMutableString *mString = [[NSMutableString alloc] init];
    for (int i=0; i<[orders count]; i++) {
        JOrder *order = [orders objectAtIndex:i];
        [mItemIds addObject:order.itemObject._id];
        if([order.itemObject hasTopBottom])
        {
            [mItemSizes addObject:[NSString stringWithFormat:@"TOP - %@, BOTTOM - %@", order.itemSizeTop, order.itemSizeBottom]];
        }
        else if([order.itemObject hasTop])
        {
            [mItemSizes addObject:[NSString stringWithFormat:@"TOP - %@", order.itemSizeTop]];
        }
        else
        {
            [mItemSizes addObject:[NSString stringWithFormat:@"BOTTOM - %@", order.itemSizeBottom]];
        }
        
        [mString appendString:[NSString stringWithFormat:@"%@ - $%.2fUSD<br/>", order.itemObject.item_name, order.itemCost]];
        totalCost += order.itemCost;
        
    }
    [mString appendString:[NSString stringWithFormat:@"%@ - $%.2fUSD<br/>", @"Shipping Cost", SHIPPING_COST]];
    totalCost += SHIPPING_COST;
    
    NSString *paymentMode=@"live";
    if ([[Stripe defaultPublishableKey] isEqualToString:STRIPE_PUBLISHABLE_KEY_TEST]) {
        paymentMode=@"test";
    }
    NSMutableDictionary *chargeParams = [[NSMutableDictionary alloc] initWithDictionary:@{
                                   @"stripe_token": token.tokenId,
                                   @"currency": @"usd",
                                   @"amount": [NSNumber numberWithFloat:totalCost], // this is in dollar (i.e. $10)
                                   @"items":mItemIds,
                                   @"itemSizes":mItemSizes,
                                   @"itemCount": [NSNumber numberWithInteger:[orders count]],
                                   @"shipFirstName": [Engine gAddress].shipFirstName,
                                   @"shipLastName": [Engine gAddress].shipLastName,
                                   @"shipAddress": [Engine gAddress].shipAddress,
                                   @"shipAddressExtra": [Engine gAddress].shipAddressExtra,
                                   @"shipCity": [Engine gAddress].shipCity,
                                   @"shipState": [Engine gAddress].shipState,
                                   @"shipZipcode": [Engine gAddress].shipZipcode,
                                   @"shipPhone": [Engine gAddress].shipPhone,
                                   @"itemInfo": mString,
                                   @"payment_mode":paymentMode
                                   }];
    
    if ([[JUser me] isAuthorized]) {
        [chargeParams setObject:[JUser me].email forKey:@"userEmail"];
    }
    
    // This passes the token off to our payment backend, which will then actually complete charging the card using your account's
    
    [APIClient charge:chargeParams success:^(NSString *message) {
        [JUtils hideLoadingIndicator:self.navigationController.view];
        pending=false;
        
        if(completion)
        {
            completion(PKPaymentAuthorizationStatusSuccess);
        }
        
        [self performSegueWithIdentifier:@"showConfirm" sender:chargeParams];
    } failure:^(NSString *errorMessage) {
        [JUtils hideLoadingIndicator:self.navigationController.view];
        pending=false;
        [JUtils showMessageAlert:[NSString stringWithFormat:@"%@",errorMessage]];
        if(completion)
        {
            completion(PKPaymentAuthorizationStatusFailure);
        }
    }];
}

@end
