//
//  JContactsViewController.m
//  Zold
//
//  Created by Khatib H. on 7/10/14.
//  
//

#import "JContactsViewController.h"
#import "JContactTableViewCell.h"
#import <AddressBook/AddressBook.h>
#import <AddressBookUI/AddressBookUI.h>
#import "JAmazonS3ClientManager.h"

@interface JContactsViewController ()

@end

@implementation JContactsViewController
@synthesize sectionArray;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.mContactsSelected=[[NSMutableArray alloc] init];
    sectionArray = [[NSMutableArray alloc] init];
    
//    [self getAllContacts];

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


-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
//    if (!self.mContactsArr) {
//        [self.mContactsSelected removeAllObjects];
//        [self getAllContacts];
//    }
}


-(NSArray *)getAllContacts
{
    self.mContactsArr=[[NSMutableArray alloc] init];
    CFErrorRef *error = nil;
    
    
    ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, error);
    
    __block BOOL accessGranted = NO;
    dispatch_semaphore_t sema = dispatch_semaphore_create(0);
    ABAddressBookRequestAccessWithCompletion(addressBook, ^(bool granted, CFErrorRef error) {
        accessGranted = granted;
        dispatch_semaphore_signal(sema);
    });
    dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);
    

    
    if (accessGranted) {
        
//#ifdef DEBUG
//        NSLog(@"Fetching contact info ----> ");
//#endif
        
        
        ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, error);
//        ABAddressBookCopyArrayOfAllSources(<#ABAddressBookRef addressBook#>)
//        ABRecordRef source = ABAddressBookCopyArrayOfAllSources(addressBook);
//        CFArrayRef allPeople = ABAddressBookCopyArrayOfAllPeopleInSourceWithSortOrdering(addressBook, source, kABPersonSortByFirstName);
        NSArray *allContacts = (__bridge_transfer NSArray*)ABAddressBookCopyArrayOfAllPeople(addressBook);
//        CFIndex nPeople = ABAddressBookGetPersonCount(addressBook);
//        NSMutableArray* items = [NSMutableArray arrayWithCapacity:nPeople];
        NSMutableArray *mUnusedArr = [[NSMutableArray alloc] init];
        
        for (int i = 0; i < [allContacts count]; i++)
        {
            ContactsData *contacts = [ContactsData new];
            
            ABRecordRef person = (__bridge ABRecordRef)(allContacts[i]);
            
            //get First Name and Last Name
            
            contacts.firstNames = (__bridge NSString*)ABRecordCopyValue(person, kABPersonFirstNameProperty);
            
            contacts.lastNames =  (__bridge NSString*)ABRecordCopyValue(person, kABPersonLastNameProperty);
            
            if (!contacts.firstNames) {
                contacts.firstNames = @"";
            }
            if (!contacts.lastNames) {
                contacts.lastNames = @"";
            }
            
            if([contacts.firstNames isEqualToString:@""])
            {
                if([contacts.lastNames isEqualToString:@""])
                {
                    NSString *str=(__bridge NSString*)ABRecordCopyValue(person, kABPersonOrganizationProperty);
                    if(str && (![str isEqualToString:@""]))
                    {
                        contacts.firstNames = str;
                    }
                }
                else
                {
                    contacts.firstNames = contacts.lastNames;
                    contacts.lastNames = @"";
                }
            }
            
            
            // get contacts picture, if pic doesn't exists, show standart one
            
//            NSData  *imgData = (__bridge NSData *)ABPersonCopyImageData(person);
//            contacts.image = [UIImage imageWithData:imgData];
//            if (!contacts.image) {
//                contacts.image = [UIImage imageNamed:@"NOIMG.png"];
//            }
            //get Phone Numbers
            
            NSMutableArray *phoneNumbers = [[NSMutableArray alloc] init];
            
            ABMultiValueRef multiPhones = ABRecordCopyValue(person, kABPersonPhoneProperty);
            
            for(CFIndex i=0;i<ABMultiValueGetCount(multiPhones);i++) {
                
                CFStringRef phoneNumberRef = ABMultiValueCopyValueAtIndex(multiPhones, i);
                NSString *phoneNumber = (__bridge NSString *) phoneNumberRef;
                [phoneNumbers addObject:phoneNumber];
                
                //NSLog(@"All numbers %@", phoneNumbers);
                
            }
            
            
//            [contacts setNumbers:phoneNumbers];
            
            //get Contact email
            
//            NSMutableArray *contactEmails = [NSMutableArray new];
//            ABMultiValueRef multiEmails = ABRecordCopyValue(person, kABPersonEmailProperty);
//            
//            for (CFIndex i=0; i<ABMultiValueGetCount(multiEmails); i++) {
//                CFStringRef contactEmailRef = ABMultiValueCopyValueAtIndex(multiEmails, i);
//                NSString *contactEmail = (__bridge NSString *)contactEmailRef;
//                
//                [contactEmails addObject:contactEmail];
//                // NSLog(@"All emails are:%@", contactEmails);
//                
//            }
            
//            [contacts setEmails:contactEmails];
//            if([contactEmails count]>0)
//            {
//                contacts.email=[contactEmails objectAtIndex:0];
//            }
//            else
//            {
//                contacts.email=@"";
//            }
            if([phoneNumbers count]>0)
            {
                contacts.phoneNumber=[phoneNumbers objectAtIndex:0];
                if([contacts.firstNames isEqualToString:@""])
                {
                    contacts.firstNames=contacts.phoneNumber;
                }
                [self.mContactsArr addObject:contacts];
            }
            else
            {
                if([mUnusedArr count]<20)
                {
                    [mUnusedArr addObject:[NSString stringWithFormat:@"%@   --  %d", contacts.firstNames, (int)ABMultiValueGetCount(multiPhones)]];
                }
            }
            
//
//#ifdef DEBUG
//            //NSLog(@"Person is: %@", contacts.firstNames);
//            //NSLog(@"Phones are: %@", contacts.numbers);
//            //NSLog(@"Email is:%@", contacts.emails);
//#endif
        }
        
//        self.mReport = [NSString stringWithFormat:@"All Contacts: %d    All People Contacts: %d \n Contacts With Phone Number: %d \n\n%@", (int)nPeople,(int)allContacts.count, (int)self.mContactsArr.count, mUnusedArr];
        [self createSectionList:self.mContactsArr];
//        [self.mTView reloadData];
        return self.mContactsArr;
        
    } else {
//#ifdef DEBUG
//        NSLog(@"Cannot fetch Contacts :( ");        
//#endif
        return nil;
    }
}




-(IBAction)onTouchBtnBack:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}


-(IBAction)onTouchBtnDone:(id)sender
{
    if([self.mContactsSelected count]==0)
    {
        [self onTouchBtnBack:sender];
        return;
    }
    if([MFMessageComposeViewController canSendText])
    {
        MFMessageComposeViewController* composer = [[MFMessageComposeViewController alloc] init];
        composer.messageComposeDelegate = self;
        [composer setSubject:@"Check out Fitbox App"];
        [composer setBody:@"Download Fitbox App from https://itunes.apple.com/us/app/zold/id901506042 to do shop"];
        
        NSMutableArray *mArr=[[NSMutableArray alloc] init];
        for (int i=0; i<[self.mContactsSelected count]; i++) {
            ContactsData *mData=[self.mContactsSelected objectAtIndex:i];
            [mArr addObject:mData.phoneNumber];
        }
        [composer setRecipients:mArr];
        
        
        // These checks basically make sure it's an MMS capable device with iOS7
//        if([MFMessageComposeViewController respondsToSelector:@selector(canSendAttachments)] && [MFMessageComposeViewController canSendAttachments])
//        {
//            NSData* attachment = UIImageJPEGRepresentation(mRevealedView.mBlurViewOriginal.image, 0.8);
//            
//            NSString* uti = (NSString*)kUTTypeMessage;
//            [composer addAttachmentData:attachment typeIdentifier:uti filename:@"meme.jpg"];
//        }
        
        [self presentViewController:composer animated:YES completion:nil];
        //        [self presentedViewController:composer an]
//        [self hideShareView];
    }
    else
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle: APP_NAME message: @"SMS is not enabled on your device. Please check your settings." delegate: self cancelButtonTitle: @"Ok" otherButtonTitles: nil];
        [alertView show];
    }
}

- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result
{
    NSString* message;
    // Notifies users about errors associated with the interface
    switch (result)
    {
        case MessageComposeResultCancelled:
            message = @"Result: canceled";
            [controller dismissViewControllerAnimated:NO completion:nil];
            return;
            break;
        case MessageComposeResultSent:
            message = @"Mail was sent";
            break;
        case MessageComposeResultFailed:
            message = @"Result: failed";
            break;
        default:
            message = @"Result: not sent";
            break;
    }
    //	UIAlertView* alert = [[UIAlertView alloc] initWithTitle:message message:nil delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
    //	alert.tag = ALERT_TAG_SENDEMAIL;
    //	[alert show];
    //[alert release];
    [JUtils showMessageAlert:message];
    [controller dismissViewControllerAnimated:NO completion:nil];
    [self onTouchBtnBack:nil];
    //    [controller dismissModalViewControllerAnimated:YES];
    
}


//Create Section List
#define ALPHA @"ABCDEFGHIJKLMNOPQRSTUVWXYZ"

#define ALPHA_ARRAY [NSArray arrayWithObjects: @"A", @"B", @"C", @"D", @"E", @"F", @"G", @"H", @"I", @"J", @"K", @"L", @"M", @"N", @"O", @"P", @"Q", @"R", @"S", @"T", @"U", @"V", @"W", @"X", @"Y", @"Z", @"#", nil]
// Build a section/row list from the alphabetically ordered word list
- (void) createSectionList: (id) wordArray
{
    // Build an array with 26 sub-array sections
//    return;
    sectionArray = [[NSMutableArray alloc] init];
    for (int i = 0; i <= 26; i++)
        [sectionArray addObject:[[NSMutableArray alloc] init]];
    
    // Add each word to its alphabetical section
    
    ContactsData* word;
    for (word in wordArray)
    {
        if ([word.firstNames length] == 0) continue;
        
        // determine which letter starts the name
        //        NSLog(@"FullName: %@",[word valueForKey:@"fullname"]);
        NSRange range = [ALPHA rangeOfString:[[word.firstNames substringToIndex:1] uppercaseString]];
        
        if (range.location > 25)
            range.location = 26;
        // Add the name to the proper array
        [[sectionArray objectAtIndex:range.location] addObject:word];
    }
    
    NSMutableArray *willRemoveArr = [[NSMutableArray alloc] init];
    for (NSMutableArray *arr in sectionArray)
    {
        if ([arr count] < 1)
        {
            [willRemoveArr addObject: arr];
        }
    }
    
    for (NSMutableArray *arr in willRemoveArr)
    {
        [sectionArray removeObject: arr];
    }
    
    [self.mTView reloadData];
    
//    [self sendReport];
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [sectionArray count];
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    //    if((mIsSearch)&&([[Engine mIsFavourite] isEqualToString:@"1"])
    return [[sectionArray objectAtIndex:section] count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 58;
}
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 35;
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView* view = [[UIView alloc] initWithFrame: CGRectMake(0, 0, 320, 35)];
    [view setBackgroundColor: [UIColor whiteColor]];
    UIImageView* imageView = [[UIImageView alloc] initWithFrame: CGRectMake(0, 0, view.frame.size.width, view.frame.size.height)];
    [view addSubview: imageView];
    UILabel* lbl = [[UILabel alloc] initWithFrame: CGRectMake(10, 0, 300, 35)];
    lbl.font=[UIFont systemFontOfSize:12];
    [lbl setBackgroundColor: [UIColor clearColor]];
    [lbl setTextColor: [UIColor lightGrayColor]];
    
    NSMutableArray *arr = [sectionArray objectAtIndex: section];
    
        ContactsData *info = [arr objectAtIndex: 0];
        NSRange range = [ALPHA rangeOfString:[[info.firstNames substringToIndex:1] uppercaseString]];
        
        if (range.location > 25)
        {
            [lbl setText: @"#"];
        }
        else
        {
            [lbl setText: [NSString stringWithFormat:@"%@",
                           [[info.firstNames substringToIndex:1] uppercaseString]]];
        }
        
    [view addSubview: lbl];
    
    return view ;
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView
{
    return ALPHA_ARRAY;
}


//-(void)sendReport
//{
//    if ([MFMailComposeViewController canSendMail]) {
//        
//        MFMailComposeViewController * emailController = [[MFMailComposeViewController alloc] init];
//        emailController.mailComposeDelegate = self;
//        
//        [emailController setSubject:@"Support"];
//        UIDevice* device=[UIDevice currentDevice];
//        NSString *mailBody=[NSString stringWithFormat:@"%@\n\n------------------\nDevice Information.\n OS Version:%@ Device Model:%@ App Version:%@\n------------------\n",self.mReport, [device systemVersion],[device model],[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"]];
//        [emailController setMessageBody:mailBody isHTML:NO];
//        [emailController setToRecipients:[NSArray arrayWithObjects:@"support@zoldapp.com", nil]];
//        
//        [self presentViewController:emailController animated:YES completion:nil];
//        //        [self presentModalViewController:emailController animated:YES];
//    }
//    // Show error if no mail account is active
//    else {
//        UIAlertView * alertView = [[UIAlertView alloc] initWithTitle:APP_NAME message:@"You must have a mail account in order to send an email" delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", @"OK") otherButtonTitles:nil];
//        [alertView show];
//    }
//}

// The mail compose view controller delegate method
- (void)mailComposeController:(MFMailComposeViewController *)controller
          didFinishWithResult:(MFMailComposeResult)result
                        error:(NSError *)error
{
    [self dismissViewControllerAnimated:YES completion:nil];
    //    [self dismissModalViewControllerAnimated:YES];
}
#pragma tableview delegate

#pragma mark - Table view delegate


- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    JContactTableViewCell* cell = [ tableView dequeueReusableCellWithIdentifier : @"JContactTableViewCell" ] ;
    
    ContactsData *mData=[[sectionArray objectAtIndex: indexPath.section] objectAtIndex: indexPath.row];
    cell.mLblFullName.text=[NSString stringWithFormat:@"%@ %@", mData.firstNames, mData.lastNames];
//    cell.mInfo=mData;
//        if([self.mContactsSelected containsObject:mData])
//        {
//            cell.mBtnChecked.selected=YES;
//        }
//        else
//        {
//            cell.mBtnChecked.selected=NO;
//        }
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
//    ContactsData *mData=[[sectionArray objectAtIndex: indexPath.section] objectAtIndex: indexPath.row];
//    [self.mContactsSelected addObject:mData];
}
//-(void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    ContactsData *mData=[[sectionArray objectAtIndex: indexPath.section] objectAtIndex: indexPath.row];
//    [self.mContactsSelected removeObject:mData];
//}


@end
