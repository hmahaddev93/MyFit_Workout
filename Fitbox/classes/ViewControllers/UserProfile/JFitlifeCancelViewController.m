//
//  JFitlifeCancelViewController.m
//  Fitbox
//
//  Created by Khatib H. on 11/22/15.
//  
//

#import "JFitlifeCancelViewController.h"

@interface JFitlifeCancelViewController ()
{
    IBOutlet UIButton *mBtnSkipMonth;
    IBOutlet UIButton *mBtnCancel;
}

@end

@implementation JFitlifeCancelViewController

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


-(IBAction)onTouchBtnBack:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

-(IBAction)onTouchBtnSkipOrCancel:(id)sender
{
    //submissions@iwantfitbox.com
    if ([MFMailComposeViewController canSendMail]) {
        
        MFMailComposeViewController * emailController = [[MFMailComposeViewController alloc] init];
        emailController.mailComposeDelegate = self;

        UIButton *btn = (UIButton*)sender;
        if (btn == mBtnSkipMonth)
        {
            [emailController setSubject:@"Fitlife membership Skip Month"];
            NSString *mailBody=[NSString stringWithFormat:@"I would like to skip Fitlife Membership for a month. \n My information is as following. \n Full name: %@ \n Email:%@\n username: %@. Thanks.", [JUser me].fullName, [JUser me].email, [JUser me].username];
            [emailController setMessageBody:mailBody isHTML:NO];
        }
        else
        {
            [emailController setSubject:@"Fitlife Membership Cancel"];
            NSString *mailBody=[NSString stringWithFormat:@"I would like to cancel Fitlife Membership. \n My information is as following. \n Full name: %@ \n Email:%@\n username: %@. Thanks.", [JUser me].fullName, [JUser me].email, [JUser me].username];
            [emailController setMessageBody:mailBody isHTML:NO];
        }
        [emailController setToRecipients:[NSArray arrayWithObjects:@"submissions@iwantfitbox.com", nil]];
        
        [self presentViewController:emailController animated:YES completion:nil];
        //        [self presentModalViewController:emailController animated:YES];
    }
    // Show error if no mail account is active
    else {
        UIAlertView * alertView = [[UIAlertView alloc] initWithTitle:APP_NAME message:@"You must have a mail account in order to send an email" delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", @"OK") otherButtonTitles:nil];
        [alertView show];
    }
}


// The mail compose view controller delegate method
- (void)mailComposeController:(MFMailComposeViewController *)controller
          didFinishWithResult:(MFMailComposeResult)result
                        error:(NSError *)error
{
    [self dismissViewControllerAnimated:YES completion:nil];
    //    [self dismissModalViewControllerAnimated:YES];
}

@end
