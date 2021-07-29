//
//  JLoginViewController.m
//  Fitbox
//
//  Created by Khatib H. on 11/8/15.
//  
//

#import "JLoginViewController.h"
#import "JSignupViewController.h"
//#import <Pushwoosh/PushNotificationManager.h>

@interface JLoginViewController ()

@end

@implementation JLoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
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

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear: animated];
    
    [ [ NSNotificationCenter defaultCenter ] addObserver : self selector : @selector( onShowKeyBoard : ) name : UIKeyboardWillShowNotification object : nil ];
    [ [ NSNotificationCenter defaultCenter ] addObserver : self selector : @selector( onHideKeyBoard : ) name : UIKeyboardWillHideNotification object : nil ];
}

-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    
}

-(IBAction)onBtnBack:(id)sender
{
    [self.navigationController popViewControllerAnimated:true];
//    [self.navigationController popToViewController:self animated:YES];
}


#pragma mark -
#pragma mark - Load From CoreData

- (void)onActionShowHome: (NSNotification *)notification
{
    [self.view endEditing:YES];
    if ([[Engine gShoppingCart] count]>0)
    {
        [Engine saveInfoToUserDefault];
    }
    [JUser actionAfterLogin];
    [self performSegueWithIdentifier:@"showTabController" sender:nil];

}




#pragma mark -
#pragma mark - Touch Event

- (IBAction)onTouchBtnLogin: (id)sender
{
    [JUtils showLoadingIndicator:self.navigationController.view message:@"Signing in..."];
    [APIClient signInWithUsername:[mTxtLoginUsername.text lowercaseString] password:mTxtLoginPassword.text success:^(JUser *user) {
//        [[PushNotificationManager pushManager] setUserId:user._id];
        [JUtils hideLoadingIndicator:self.navigationController.view];
        [self onActionShowHome:nil];
    } failure:^(NSString *errorMessage) {
        [JUtils hideLoadingIndicator:self.navigationController.view];
        [JUtils showMessageAlert:errorMessage];
    }];
}
-(void)showSignupView
{
    UIStoryboard* storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    JSignupViewController* viewController = [storyboard instantiateViewControllerWithIdentifier:@"JSignupViewController"];
    [self.navigationController pushViewController:viewController animated:true];
}

- (IBAction)onTouchBtnShowSignup: (id)sender
{
//    [self.navigationController popViewControllerAnimated:false];
    
    [self showSignupView];
}

- (IBAction)onTouchBtnForgotPassword:(id)sender
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Forgot Password" message:@"Please enter email address associated with your account" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Reset",nil];
    alert.alertViewStyle=UIAlertViewStylePlainTextInput;
    [alert textFieldAtIndex:0].keyboardType = UIKeyboardTypeEmailAddress;
    [alert show];
    //    [self sendResetPasswordRequest];
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(buttonIndex==1)
    {
        if([[[alertView textFieldAtIndex:0] text] isEqualToString:@""])
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"Please enter a valid email" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
            [alert show];
            return;
            
        }
        [JUtils showLoadingIndicator:self.navigationController.view message:@"Requesting new password..."];
        [APIClient forgotPasswordForEmail:[[alertView textFieldAtIndex:0] text] success:^(NSString *response) {
            [JUtils hideLoadingIndicator:self.navigationController.view];
            [JUtils showMessageAlert:response];
        } failure:^(NSString *errorMessage) {
            [JUtils hideLoadingIndicator:self.navigationController.view];
            [JUtils showMessageAlert:errorMessage];
        }];
    }
}


#pragma mark -
#pragma mark - UITextField Delegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    
    if (textField == mTxtLoginUsername) {
        [mTxtLoginPassword becomeFirstResponder];
    }
    else
    {
        [textField resignFirstResponder];
    }
    
    return YES;
}

#pragma mark - Key Board ;
- (void)onShowKeyBoard: (NSNotification *)notification
{
//    [mLoginScroll setContentSize:CGSizeMake(320,self.view.frame.size.height+120)];
    [mLoginScroll setContentInset:UIEdgeInsetsMake(0, 0, 250, 0)];
}

- (void)onHideKeyBoard: (NSNotification *)notification
{
    [mLoginScroll setContentInset:UIEdgeInsetsMake(0, 0, 0, 0)];
//    [mLoginScroll setContentSize:CGSizeMake(320,470)];
}

@end
