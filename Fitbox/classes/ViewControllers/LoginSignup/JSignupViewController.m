//
//  JSignupViewController.m
//  Fitbox
//
//  Created by Khatib H. on 11/8/15.
//  
//

#import "JSignupViewController.h"

@interface JSignupViewController ()

@end

@implementation JSignupViewController

@synthesize delegate;


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.navigationController setNavigationBarHidden:true animated:false];

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
    
    [Engine setGStatusForPush:NO];
}

-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

-(IBAction)onBtnBack:(id)sender
{
    if ([(id)delegate respondsToSelector:@selector(JSignupViewControllerCancel)]) {
        [delegate JSignupViewControllerCancel];
        return;
    }
    [self.navigationController popViewControllerAnimated:true];
}


#pragma mark -
#pragma mark - Load From CoreData

- (void)onActionShowHome: (NSNotification *)notification
{
    [self.view endEditing:YES];
    
//    [JUser actionAfterLogin];
    
    if ([(id)delegate respondsToSelector:@selector(JSignupViewControllerSuccess)]) {
        [delegate JSignupViewControllerSuccess];
        return;
    }
    [self performSegueWithIdentifier:@"showTabController" sender:nil];
}



#pragma mark -
#pragma mark - Touch Event



- (IBAction)onTouchBtnSignup: (id)sender
{
    
    if(![JUtils validateEmail:mTxtSignupEmail.text])
    {
        [JUtils showMessageAlert:@"Please double check the email you entered and try again!"];
        return;
    }
    if(![JUtils validateUsername:mTxtSignupUsername.text])
    {
        [JUtils showMessageAlert:@"Invalid username. Username shouldn't contain any spaces or special characterers!"];
        return;
    }
    if([mTxtSignupPassword.text isEqualToString:@""])
    {
        [JUtils showMessageAlert:@"Password can not be empty!"];
        return;
    }
    
    
    if(![mTxtSignupPassword.text isEqualToString:mTxtSignupConfirm.text])
    {
        [JUtils showMessageAlert:@"Password doesn't match!"];
        return;
    }
    
    [JUtils showLoadingIndicator:self.navigationController.view message:@"Registering..."];
    
    [APIClient signUpWithUserName:[mTxtSignupUsername.text lowercaseString] email:[mTxtSignupEmail.text lowercaseString] password:mTxtSignupPassword.text success:^(JUser *user) {
        [JUtils hideLoadingIndicator:self.navigationController.view];
        [JUser actionAfterLogin];
        if ([[Engine gShoppingCart] count]>0)
        {
            [Engine saveInfoToUserDefault];
        }
        [self onActionShowHome:nil];
    } failure:^(NSString *errorMessage) {
        [JUtils hideLoadingIndicator:self.navigationController.view];
        [JUtils showMessageAlert:errorMessage];
    }];
}

- (void)onActionLogout: (NSNotification *)notification
{
    [self.navigationController popToRootViewControllerAnimated: YES];
}


#pragma mark -
#pragma mark - UITextField Delegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField == mTxtSignupUsername) {
        [mTxtSignupEmail becomeFirstResponder];
    }
    else if (textField == mTxtSignupEmail)
    {
        [mTxtSignupPassword becomeFirstResponder];
    }
    else if (textField == mTxtSignupPassword)
    {
        [mTxtSignupConfirm becomeFirstResponder];
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
//    [mSignupScroll setContentSize:CGSizeMake(320,self.view.frame.size.height+216)];
    [mSignupScroll setContentInset:UIEdgeInsetsMake(0, 0, 250, 0)];
}

- (void)onHideKeyBoard: (NSNotification *)notification
{
    [mSignupScroll setContentInset:UIEdgeInsetsMake(0, 0, 0, 0)];
//    [mSignupScroll setContentSize:CGSizeMake(320,470)];
}



@end
