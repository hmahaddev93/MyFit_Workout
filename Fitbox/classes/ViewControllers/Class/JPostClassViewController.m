//
//  JPostClassViewController.m
//  Fitbox
//
//  Created by Khatib H. on 2/18/16.
//  
//

#import "JPostClassViewController.h"
#import "JAmazonS3ClientManager.h"
#import "JDatePicker.h"
#import "AttendeeCountSelectorView.h"

#define PREFERED_WITH 640
#define PREFERED_HEIGHT 640
#define PREFERED_RATIO 1//1136.0/640.0


#define THUMB_WITH 200
#define THUMB_HEIGHT 200

@interface JPostClassViewController ()<JSelectLocationViewControllerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIActionSheetDelegate, UIAlertViewDelegate, JDatePickerDelegate, AttendeeCountSelectorViewDelegate>

{
    IBOutlet UITextField *mTxtClassType;
    IBOutlet UITextField *mTxtPlaceName;
    IBOutlet UITextField *mTxtPrice;
    IBOutlet UIButton *mBtnPayPref;
    IBOutlet UIButton *mBtnGenderPrefMale;
    IBOutlet UIButton *mBtnGenderPrefFemale;
    IBOutlet UIButton *mBtnGenderPrefBoth;
    IBOutlet UITextView *mTxtComments;
    
    IBOutlet UIImageView *mImgPhoto;
    IBOutlet UIButton *mBtnAddPhoto;
    
    IBOutlet UIScrollView *mScrollView;
//    IBOutlet UITextField
    
    UIView *mViewSuccess;
    
    NSNumber *mLat;
    NSNumber *mLng;
    
    BOOL isUploading;
    UIImage *mImageToUpload;

//    IBOutlet UIButton *mBtnExpire;
    IBOutlet UIButton *mBtnEventDate;
    
    IBOutlet UIButton *mBtnAttendeeCount;
    
    NSDate *eventDate;
    NSInteger eventAttendeeCount;
    
    JDatePicker *datePicker;
    AttendeeCountSelectorView *attendeeCountSelector;
}
@property (nonatomic, retain) NSString* mFileNameToUpload;
@property (nonatomic, retain) UIImage *mImageBig;
@property (nonatomic, retain) UIImage *mImageSmall;


@end

@implementation JPostClassViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    eventAttendeeCount = 1;
    // Do any additional setup after loading the view.
    [self stylizeTextField:mTxtClassType];
    [self stylizeTextField:mTxtPlaceName];
    [self stylizeTextField:mTxtPrice];
    [self stylizeView:mTxtComments];
    
    [self stylizeView:mBtnGenderPrefBoth];
    [self stylizeView:mBtnGenderPrefMale];
    [self stylizeView:mBtnGenderPrefFemale];
    [self stylizeView:mBtnPayPref];
//    [self stylizeView:mBtnExpire];
    [self stylizeView:mBtnEventDate];
    [self stylizeView:mBtnAttendeeCount];
    
//    mBtnEventDate.enabled = false;

    
    NSArray* nibArray = [ [ NSBundle mainBundle ] loadNibNamed : @"JDatePicker" owner: nil options: nil];
    datePicker = ( JDatePicker * )[ nibArray objectAtIndex : 0];
    datePicker.delegate = self;
    [datePicker setFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
    NSLog(@"Width: %d   HEIGHT: %d", (int)SCREEN_WIDTH, (int)SCREEN_HEIGHT);
    [self.view addSubview: datePicker];
    [self showPicker:datePicker show:NO animated:NO];

    NSArray* nibArray1 = [ [ NSBundle mainBundle ] loadNibNamed : @"AttendeeCountSelectorView" owner: nil options: nil];
    attendeeCountSelector = ( AttendeeCountSelectorView * )[ nibArray1 objectAtIndex : 0];
    attendeeCountSelector.delegate = self;
    [attendeeCountSelector setFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
    [self.view addSubview: attendeeCountSelector];
    [self showPicker:attendeeCountSelector show:NO animated:NO];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear: animated];
    
    [ [ NSNotificationCenter defaultCenter ] addObserver : self selector : @selector( onShowKeyBoard : ) name : UIKeyboardWillShowNotification object : nil ];
    [ [ NSNotificationCenter defaultCenter ] addObserver : self selector : @selector( onHideKeyBoard : ) name : UIKeyboardWillHideNotification object : nil ];
}

#pragma mark - Key Board ;
- (void)onShowKeyBoard: (NSNotification *)notification
{
    //    [mLoginScroll setContentSize:CGSizeMake(320,self.view.frame.size.height+120)];
    [mScrollView setContentInset:UIEdgeInsetsMake(0, 0, 250, 0)];
}

- (void)onHideKeyBoard: (NSNotification *)notification
{
    [mScrollView setContentInset:UIEdgeInsetsMake(0, 0, 0, 0)];
    //    [mLoginScroll setContentSize:CGSizeMake(320,470)];
}


-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    
}

-(void)stylizeTextField:(UITextField*)textField
{
//    [textField setTex]
    [self stylizeView:textField];
}
-(void)stylizeView:(UIView*)viewItem
{
    viewItem.layer.borderColor = [MAIN_COLOR_LIGHT_GRAY CGColor];
    viewItem.layer.borderWidth = 1;
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
    [self.navigationController popViewControllerAnimated:true];
}

-(IBAction)onTouchBtnGenderPref:(id)sender
{
    mBtnGenderPrefMale.selected = false;
    mBtnGenderPrefFemale.selected = false;
    mBtnGenderPrefBoth.selected = false;
    
    UIButton *btn = (UIButton *)sender;
    btn.selected = true;
}

-(IBAction)onTouchBtnPayPref:(id)sender
{
    mBtnPayPref.selected = !mBtnPayPref.selected;
    
    mTxtPrice.enabled = !mBtnPayPref.selected;
    
    if (mTxtPrice.enabled) {
        mTxtPrice.textColor = [UIColor blackColor];
    }
    else
    {
        mTxtPrice.textColor = [UIColor lightGrayColor];
    }
}

//-(IBAction)onTouchBtnExpire:(id)sender
//{
//    mBtnExpire.selected = !mBtnExpire.selected;
//    mBtnExpireDate.enabled = mBtnExpire.selected;
//}

-(IBAction)onTouchBtnEventDate:(id)sender
{
    [self.view endEditing:true];
    [self showPicker:datePicker show:true animated:true];
}
-(IBAction)onTouchBtnAttendeeCount:(id)sender
{
    [self.view endEditing:true];
    [self showPicker:attendeeCountSelector show:true animated:true];
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

- (IBAction)onTouchBtnPublish:(id)sender
{
    if(!mImageToUpload)
    {
        [JUtils showMessageAlert:@"You need to upload a photo"];
        return;
    }
    
    if([mTxtClassType.text isEqualToString:@""])
    {
        [JUtils showMessageAlert:@"Item title is missing"];
        return;
    }
    
    if([mTxtPlaceName.text isEqualToString:@""])// || (!mLat)
    {
        [JUtils showMessageAlert:@"Please set the location name"];
        return;
    }
    
    if(!mBtnPayPref.selected && ([mTxtPrice.text doubleValue]<=0.0))
    {
        [JUtils showMessageAlert:@"Please select valid pay option"];
        return;
    }

    if(!mBtnGenderPrefBoth.selected && !mBtnGenderPrefFemale.selected && !mBtnGenderPrefMale.selected)
    {
        [JUtils showMessageAlert:@"Gender preference not selected"];
        return;
    }
    
    if ([mTxtComments.text isEqualToString:@""]) {
        [JUtils showMessageAlert:@"Please provide detailed information in comments section"];
        return;
    }
    
    if (!eventDate) {
        [JUtils showMessageAlert:@"Event date not selected"];
        return;
    }
    else
    {
        int timeDiff = [eventDate timeIntervalSinceDate:[NSDate date]];
        if (timeDiff < 60*60) {
            [JUtils showMessageAlert:@"You should set event date at least an hour from now"];
            return;
        }
    }
    isUploading=YES;
    
    [JUtils showLoadingIndicator:self.navigationController.view message:@"Geocoding address..."];
    
    CLGeocoder *ceo = [[CLGeocoder alloc]init];
//    CLLocation *loc = [[CLLocation alloc]initWithLatitude:lat longitude:lng]; //insert your coordinates
//    CLRegion *region = [[CLRegion alloc] init];
//    region.radius
    [ceo geocodeAddressString:mTxtPlaceName.text completionHandler:^(NSArray<CLPlacemark *> * _Nullable placemarks, NSError * _Nullable error) {
        [JUtils hideLoadingIndicator:self.navigationController.view];
        if (placemarks && [placemarks count]>0) {
            CLPlacemark *placemark = [placemarks objectAtIndex:0];
            mLat = [NSNumber numberWithDouble: placemark.location.coordinate.latitude];
            mLng = [NSNumber numberWithDouble: placemark.location.coordinate.longitude];
            
            UIStoryboard* storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            
            JSelectLocationViewController *mLocationView = [storyboard instantiateViewControllerWithIdentifier:@"JSelectLocationViewController"];
            mLocationView.delegate = self;
            mLocationView.isSelectLocation = true;
            
            mLocationView.mLat = mLat;
            mLocationView.mLng = mLng;
            
            UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:mLocationView];
            
            [self presentViewController:navigationController animated:true completion:^{
                
            }];
            
//            [self uploadFileManager];
        }
        else
        {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:APP_NAME message:@"Sorry we can't find your location, please drop pin on map" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Ok", nil];
            alertView.tag = 100;
            [alertView show];
        }
    }];
    
//    [self uploadFileManager];
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 100) {
        if (buttonIndex == 1) {
            
            UIStoryboard* storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            
            JSelectLocationViewController *mLocationView = [storyboard instantiateViewControllerWithIdentifier:@"JSelectLocationViewController"];
            mLocationView.delegate = self;
            mLocationView.isSelectLocation = true;
            
//            mLocationView.mLat = mLat;
//            mLocationView.mLng = mLng;
            
            UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:mLocationView];
            
            [self presentViewController:navigationController animated:true completion:^{
                
            }];
        }
    }
}


-(void)uploadFileManager
{
    [JUtils showLoadingIndicator:self.navigationController.view message:@"Posting..."];

    [self uploadItemPhoto:mImageToUpload quality:0.75];
//    [self createAndSaveToParse];
}

-(void)createAndSaveToParse
{
    NSMutableDictionary *dict=[NSMutableDictionary new];
    
    [dict setObject:[NSString stringWithFormat:@"%@.jpg",_mFileNameToUpload] forKey:kListingPhoto];
    [dict setObject:mTxtClassType.text forKey:kListingClassType];
    
    [dict setObject:[NSNumber numberWithBool:mBtnPayPref.selected] forKey:kListingPayPreference];
    [dict setObject:[NSNumber numberWithDouble:[mTxtPrice.text doubleValue]] forKey:kListingPrice];
    
    [dict setObject:mTxtPlaceName.text forKey:kListingPlaceName];
//    [dict setObject:@[mLng,mLng] forKey:kListingPlaceGeopoint];
    [dict setObject:mLng forKey:@"lng"];
    [dict setObject:mLat forKey:@"lat"];
    
    [dict setObject:[JUser me]._id forKey:kUserId];
    
    NSString *genderOption = @"B";
    if (mBtnGenderPrefMale.selected) {
        genderOption = @"M";
    }
    else if(mBtnGenderPrefFemale.selected)
    {
        genderOption = @"F";
    }
    [dict setObject:genderOption forKey:kListingGenderPreference];
    [dict setObject:mTxtComments.text forKey:kListingComments];
    [dict setObject:kListingStatusOpen forKey:kListingStatus];
    [dict setObject:[NSNumber numberWithInteger:eventAttendeeCount] forKey:kListingMaxAttendeeCount];
    
    if (eventDate) {
        [dict setObject:[NSNumber numberWithDouble:[eventDate timeIntervalSince1970]] forKey:kListingEventDate];
    }
    
    [APIClient postListing:dict success:^(JListing *item) {
        [JUtils hideLoadingIndicator:self.navigationController.view];
        isUploading=NO;
        mViewSuccess = [JUtils createSuccessViewWithMessage:@"SUCCESSFULLY UPLOADED"];
        [self.navigationController.view addSubview:mViewSuccess];
        
        [self performSelector:@selector(closeSuccessViewAndPage) withObject:nil afterDelay:2.0];
        
    } failure:^(NSString *errorMessage) {
        [JUtils hideLoadingIndicator:self.navigationController.view];
        isUploading=NO;
        [JUtils showMessageAlert:errorMessage];
    }];
    
    
}

-(void)closeSuccessViewAndPage
{
    if (mViewSuccess) {
        [mViewSuccess removeFromSuperview];
        mViewSuccess = nil;
    }
    [self.navigationController popViewControllerAnimated: true];
}


- (void)uploadItemPhoto:(UIImage*)imageTo quality:(float)quality// imageFrom:(NSString*)imageFrom
{
    /*    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle: @"Info" message: @"Uploading Profile Photo will be processed in background. You can continue using the app." delegate: nil cancelButtonTitle: @"Ok" otherButtonTitles: nil];
     [alertView show];*/
    [self setMFileNameToUpload:[self fileKeyForUpload]];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0),  ^ {
        
        [self scaleAndRotateImage:imageTo];
        
        NSData *data = [NSData dataWithData: UIImageJPEGRepresentation([self mImageSmall],quality)];
        if (data && data.length)
        {
//            [[JAmazonS3ClientManager defaultManager] uploadItemPhotoThumbnailData:data fileKey:[self mFileNameToUpload] withProcessBlock:^ (float progress) {
//                NSLog(@"Progress: %d", (int)(progress*100));
//                
//            } completeBlock:^ (NSString *obj) {
//                if ([obj isKindOfClass:[NSString class]]) {
//                    //                    NSString* key=(NSString*)obj;
            
                    NSData *data = [NSData dataWithData: UIImageJPEGRepresentation([self mImageBig],quality)];
                    
                    
                    [[JAmazonS3ClientManager defaultManager] uploadItemPhotoData:data fileKey:[self mFileNameToUpload] withProcessBlock:^ (float progress) {
                        NSLog(@"Progress: %d", (int)(progress*100));
                        
                    } completeBlock:^ (NSString *obj1) {
                        
                        
                        if ([obj1 isKindOfClass:[NSString class]]) {
                            [self createAndSaveToParse];
                        }
                        else
                        {
                            [self closeProgressAndShowMessage:@"List Posting Failed."];
                        }
                    }];
                    
//                    
//                    
//                    NSLog(@"got thumbnail key %@", obj);
//                }
//                else
//                {
//                    [self closeProgressAndShowMessage:@"List Posting Failed."];
//                }
//            }];
            
        }
        else {
            [self closeProgressAndShowMessage:@"List Posting Failed. "];
        }
    });
}

-(void)closeProgressAndShowMessage:(NSString*)message
{
    [JUtils hideLoadingIndicator:self.navigationController.view];
    [JUtils showMessageAlert:message];
}




-(IBAction)onTouchBtnChangePhoto:(id)sender
{
    [self.view endEditing:true];
    UIActionSheet* actionSheet = [ [ UIActionSheet alloc ] initWithTitle : @"Add Profile Photo"
                                                                delegate : self
                                                       cancelButtonTitle : @"Cancel"
                                                  destructiveButtonTitle :nil
                                                       otherButtonTitles : @"Camera", @"From Photo Library", nil ] ;
    
    [ actionSheet showInView : self.view ] ;
}

#pragma mark - Action Sheet
- (void)actionSheet: (UIActionSheet *) _actionSheet clickedButtonAtIndex : (NSInteger) _buttonIndex
{
    if([_actionSheet.title isEqualToString: @"Add Profile Photo"])
    {
        UIImagePickerController* pickerController = nil;
        
        switch(_buttonIndex)
        {
            case 0: // Camera ;
                if([UIImagePickerController isSourceTypeAvailable: UIImagePickerControllerSourceTypeCamera] == NO)
                {
                    return ;
                }
                pickerController = [[UIImagePickerController alloc] init];
                pickerController.delegate  = self;
                pickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
                pickerController.cameraCaptureMode = UIImagePickerControllerCameraCaptureModePhoto;
                pickerController.allowsEditing = YES;
                
                [self presentViewController: pickerController animated: YES completion: nil];
                break ;
                
            case 1: // Photo ;
                pickerController = [[UIImagePickerController alloc] init];
                pickerController.delegate = self;
                pickerController.allowsEditing = YES;
                pickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
                
                [self presentViewController: pickerController animated: YES completion: nil];
                break ;
            default :
                break ;
        }
    }
    
}

#pragma mark - Image Picker
- (void)imagePickerController: (UIImagePickerController *) _picker didFinishPickingMediaWithInfo: (NSDictionary *) _info
{
    NSURL *mediaUrl = (NSURL *)[_info valueForKey: UIImagePickerControllerMediaURL];
    if(mediaUrl == nil)
    {
        UIImage* mImage=[_info valueForKey: UIImagePickerControllerEditedImage];
        mImgPhoto.image=mImage;
        mImgPhoto.contentMode = UIViewContentModeScaleAspectFill;
        mImageToUpload = mImage;
        mBtnAddPhoto.hidden=true;
        [_picker dismissViewControllerAnimated : YES completion : ^{
            
        }];
    }
}

- (NSString *)fileKeyForUpload
{
    int time_key=[[NSDate date] timeIntervalSince1970];//*1000;
    NSLog(@"Time Interval: %d",time_key);
    return [NSString stringWithFormat:@"fitbox_%d_%@",time_key,[JUser me]._id];
}

-(UIImage * )scaleAndRotateImage:(UIImage *)image
{
    CGImageRef imgRef = image.CGImage;
    
    if ( !image )
        NSLog(@"Image is nil in scaleAndRotateImage");
    
    CGFloat width = CGImageGetWidth(imgRef);
    CGFloat height = CGImageGetHeight(imgRef);
    
    //	CGAffineTransform transform = CGAffineTransformIdentity;
    CGRect bounds = CGRectMake(0, 0, width, height);
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    
    
    CGContextRef context = CGBitmapContextCreate(NULL, PREFERED_WITH,PREFERED_HEIGHT, 8, PREFERED_WITH * 4, colorSpace, (CGBitmapInfo)kCGImageAlphaPremultipliedLast);
    //	CGContextTranslateCTM(context, 0, bounds.size.height);
    //	CGContextScaleCTM(context, 1, -1);
    CGColorSpaceRelease(colorSpace);
    
    
    
    CGContextScaleCTM(context, PREFERED_WITH/bounds.size.width, PREFERED_HEIGHT/bounds.size.width);
    CGContextTranslateCTM(context, 0, -(bounds.size.height-bounds.size.width)/2.0);
    //	CGContextConcatCTM(context, transform);
    CGContextDrawImage(context, CGRectMake(0, 0, bounds.size.width, bounds.size.height), image.CGImage);
    CGImageRef imageRef = CGBitmapContextCreateImage(context);
    UIImage *finalImage = [[UIImage alloc] initWithCGImage:imageRef scale:1 orientation:UIImageOrientationUp];
    self.mImageBig=finalImage;
    CGImageRelease(imageRef);
    CGContextRelease(context);
    
    
    context = CGBitmapContextCreate(NULL, THUMB_WITH,THUMB_HEIGHT, 8, THUMB_WITH * 4, colorSpace,(CGBitmapInfo)kCGImageAlphaPremultipliedLast);
    //	CGContextTranslateCTM(context, 0, bounds.size.height);
    //	CGContextScaleCTM(context, 1, -1);
    CGColorSpaceRelease(colorSpace);
    
    
    
    CGContextScaleCTM(context, THUMB_WITH/bounds.size.width, THUMB_HEIGHT/bounds.size.width);
    CGContextTranslateCTM(context, 0, -(bounds.size.height-bounds.size.width)/2.0);
    //	CGContextConcatCTM(context, transform);
    CGContextDrawImage(context, CGRectMake(0, 0, bounds.size.width, bounds.size.height), image.CGImage);
    imageRef = CGBitmapContextCreateImage(context);
    finalImage = [[UIImage alloc] initWithCGImage:imageRef scale:1 orientation:UIImageOrientationUp];
    self.mImageSmall=finalImage;
    CGImageRelease(imageRef);
    CGContextRelease(context);
    
    return finalImage;
}


- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if (textField ==   mTxtPlaceName) {
        NSRange lowercaseCharRange = [string rangeOfCharacterFromSet:[NSCharacterSet lowercaseLetterCharacterSet]];
        
        if (lowercaseCharRange.location != NSNotFound) {
            textField.text = [textField.text stringByReplacingCharactersInRange:range
                                                                     withString:[string uppercaseString]];
            return NO;
        }
    }
    
    return YES;
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return NO;
}

#pragma mark - Location View

-(IBAction)onTouchBtnSelectLocation:(id)sender
{
    
    UIStoryboard* storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    
    JSelectLocationViewController *mLocationView = [storyboard instantiateViewControllerWithIdentifier:@"JSelectLocationViewController"];
    mLocationView.delegate = self;
    mLocationView.isSelectLocation = true;

    mLocationView.mLat = mLat;
    mLocationView.mLng = mLng;
    
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:mLocationView];
    
    [self presentViewController:navigationController animated:true completion:^{
        
    }];
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
    
    mLat = [NSNumber numberWithDouble: lat];
    mLng = [NSNumber numberWithDouble: lng];
    
    [self uploadFileManager];
//    [self getCurrentLocatonName:lat lng:lng];
}

-(void)getCurrentLocatonName:(double)lat lng:(double)lng
{
    [JUtils showLoadingIndicator:self.navigationController.view message:@"Geocoding address..."];
    
    CLGeocoder *ceo = [[CLGeocoder alloc]init];
    CLLocation *loc = [[CLLocation alloc]initWithLatitude:lat longitude:lng]; //insert your coordinates
    
    [ceo reverseGeocodeLocation:loc
              completionHandler:^(NSArray *placemarks, NSError *error) {
                  [JUtils hideLoadingIndicator:self.navigationController.view];
                  if (placemarks && [placemarks count]>0) {
                      CLPlacemark *placemark = [placemarks objectAtIndex:0];
                      NSLog(@"placemark %@",placemark);
                      //String to hold address
                      NSString *locatedAt = [[placemark.addressDictionary valueForKey:@"FormattedAddressLines"] componentsJoinedByString:@", "];
                      NSLog(@"addressDictionary %@", placemark.addressDictionary);
                      
                      NSLog(@"placemark %@",placemark.region);
                      NSLog(@"placemark %@",placemark.country);  // Give Country Name
                      NSLog(@"placemark %@",placemark.locality); // Extract the city name
                      NSLog(@"location %@",placemark.name);
                      NSLog(@"location %@",placemark.ocean);
                      NSLog(@"location %@",placemark.postalCode);
                      NSLog(@"location %@",placemark.subLocality);
                      
                      NSLog(@"location %@",placemark.location);
                      //Print the location to console
                      NSLog(@"I am currently at %@",locatedAt);
                      if (locatedAt) {
                          dispatch_async(dispatch_get_main_queue(), ^{
                              mTxtPlaceName.text = locatedAt;                              
                          });
                      }
                  }
                  else {
                      NSLog(@"Could not locate");
                  }
              }
     ];
}


-(void)JDatePickerCancel
{
    [self showPicker:datePicker show:false animated:true];
//    [self dismissViewControllerAnimated:true completion:^{
//        
//    }];
}

-(void)JDatePickerDone:(NSDate *)date
{
    [self showPicker:datePicker show:false animated:true];
    eventDate = date;
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"YYYY MMM dd hh:mm a";
    NSString *mString = [dateFormatter stringFromDate:eventDate];
    [mBtnEventDate setTitle:mString forState:UIControlStateNormal];
}


-(void)AttendeeCountSelectorViewDone:(NSInteger)attendeeCount
{
    eventAttendeeCount = attendeeCount;
    if (attendeeCount == 0) {
        [mBtnAttendeeCount setTitle:@"Unlimited" forState:UIControlStateNormal];
    }
    else
    {
        [mBtnAttendeeCount setTitle:[NSString stringWithFormat:@"%d", (int)attendeeCount] forState:UIControlStateNormal];
    }
    [self showPicker:attendeeCountSelector show:false animated:true];
}

-(void)AttendeeCountSelectorViewCancel
{
    [self showPicker:attendeeCountSelector show:false animated:true];

}

@end
