//
//  JShippingAddressViewController.m
//  Fitbox
//
//  Created by Khatib H. on 11/11/15.
//  
//

#import "JShippingAddressViewController.h"

@interface JShippingAddressViewController ()
{
    StateSelectorView *mStateView;
}

@end

@implementation JShippingAddressViewController

@synthesize delegate;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    if (_mAddress) {
        [self initTextFieldsWithAddress:_mAddress];
    }

    NSArray* nibArray = [ [ NSBundle mainBundle ] loadNibNamed : @"StateSelectorView" owner: nil options: nil];
    mStateView = ( StateSelectorView * )[ nibArray objectAtIndex : 0];
    mStateView.delegate = self;
    [mStateView setFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
    NSLog(@"Width: %d   HEIGHT: %d", (int)SCREEN_WIDTH, (int)SCREEN_HEIGHT);
    [self.view addSubview: mStateView];
    [self showPicker:mStateView show:NO animated:NO];
    
    if (self.mAddress) {
        [self initTextFieldsWithAddress:self.mAddress];
    }
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(onShowKeyBoard :) name: UIKeyboardWillShowNotification object: nil];
    [[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(onHideKeyBoard :) name: UIKeyboardWillHideNotification object: nil];
}

-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear: animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
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


-(void)initTextFieldsWithAddress:(JAddressInfo*)info
{
    self.mTxtShipFirstName.text = info.shipFirstName;
    self.mTxtShipLastName.text = info.shipLastName;
    self.mTxtShipAddress.text = info.shipAddress;
    self.mTxtShipAddressExtra.text = info.shipAddressExtra;
    self.mTxtShipCity.text = info.shipCity;
    self.mTxtShipPhone.text = info.shipPhone;
    self.mTxtShipState.text = info.shipState;
    self.mTxtShipZipCode.text = info.shipZipcode;
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

-(IBAction)onTouchBtnBack:(id)sender
{
    if ([(id)delegate respondsToSelector: @selector(JShippingAddressViewControllerCancel)])
    {
        [delegate JShippingAddressViewControllerCancel];
    }
    
//    [self.navigationController popViewControllerAnimated:YES];
}

-(IBAction)onTouchBtnStateSelector:(id)sender
{
    [self.view endEditing:true];
    [self showPicker:mStateView show:true animated:true];
}
-(IBAction)onTouchBtnSaveAddress:(id)sender
{
    
    if ([self.mTxtShipFirstName.text isEqualToString:@""] || [self.mTxtShipLastName.text isEqualToString:@""] || [self.mTxtShipAddress.text isEqualToString:@""] || [self.mTxtShipCity.text isEqualToString:@""] || [self.mTxtShipState.text isEqualToString:@""] || [self.mTxtShipPhone.text isEqualToString:@""])
    {
        [self.navigationController.view makeToast:@"Fill out all the required address" duration:2.0 position:CSToastPositionTop];
        return;
    }
    
    JAddressInfo *info = [[JAddressInfo alloc] init];
    info.shipFirstName = self.mTxtShipFirstName.text;
    info.shipLastName = self.mTxtShipLastName.text;
    info.shipAddress = self.mTxtShipAddress.text;
    info.shipAddressExtra = self.mTxtShipAddressExtra.text;
    info.shipCity = self.mTxtShipCity.text;
    info.shipPhone = self.mTxtShipPhone.text;
    info.shipState = self.mTxtShipState.text;
    info.shipZipcode = self.mTxtShipZipCode.text;
    
    if ([(id)delegate respondsToSelector: @selector(JShippingAddressViewControllerAddressChosen:)])
    {
        [delegate JShippingAddressViewControllerAddressChosen: info];
    }
}



#pragma mark - State Selector Delegate

-(void)StateSelectorViewCancel
{
    [self showPicker:mStateView show:false animated:true];
}
-(void)StateSelectorViewDone:(NSString *)strStateName
{
    self.mTxtShipState.text = strStateName;
    [self showPicker:mStateView show:false animated:true];
}


#pragma mark - Key Board ;
- (void)onShowKeyBoard: (NSNotification *)notification
{
    [_mScrollView setContentInset:UIEdgeInsetsMake(0, 0, 260, 0)];
    //    [mScrollView setContentSize:CGSizeMake(320,696)];
    //    [mScrollView setContentOffset:CGPointMake(0, 80) animated:YES];
}

- (void)onHideKeyBoard: (NSNotification *)notification
{
    [_mScrollView setContentInset:UIEdgeInsetsMake(0, 0, 0, 0)];
    //    [mScrollView setContentSize:CGSizeMake(320,mScrollView.frame.size.height)];
}


#pragma mark - Text Field Delegate

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField == _mTxtShipFirstName) {
        [_mTxtShipLastName becomeFirstResponder];
    }
    else if (textField == _mTxtShipLastName)
    {
        [_mTxtShipAddress becomeFirstResponder];
    }
    else if (textField == _mTxtShipAddress)
    {
        [_mTxtShipAddressExtra becomeFirstResponder];
    }
    else if (textField == _mTxtShipAddressExtra)
    {
        [_mTxtShipCity becomeFirstResponder];
    }
    else if (textField == _mTxtShipCity)
    {
        [_mTxtShipZipCode becomeFirstResponder];
    }
    else if (textField == _mTxtShipZipCode)
    {
        [_mTxtShipPhone becomeFirstResponder];
    }
    else
    {
        [self.view endEditing:true];
    }
    return false;
}

@end
