//
//  JEditProfileViewController.m
//  Zold
//
//  Created by Khatib H. on 13/10/14.
//  
//

#import "JEditProfileViewController.h"
#import "JAmazonS3ClientManager.h"

@interface JEditProfileViewController ()

@end

@implementation JEditProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self initView];
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
    [[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(onShowKeyBoard :) name: UIKeyboardWillShowNotification object: nil];
    [[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(onHideKeyBoard :) name: UIKeyboardWillHideNotification object: nil];
}

-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear: animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

-(void)initView
{
    mTxtFirstName.text = [JUser me].firstName;
    mTxtLastName.text = [JUser me].lastName;
    mTxtEmail.text = [JUser me].email;

    mPhoto.image=nil;

    if([[JUser me].profilePhoto isEqualToString:@""])
    {
        mPhoto.image = [UIImage imageNamed:@"btnIconsCameraAdd"];
        mPhoto.contentMode=UIViewContentModeCenter;
        
    }
    else
    {
        [mPhoto setImageWithURL:[[JAmazonS3ClientManager defaultManager] cdnUrlForProfilePhoto: [JUser me].profilePhoto]];
        mPhoto.contentMode=UIViewContentModeScaleAspectFill;
    }

    mIndicatorProfile.hidden=YES;
    [mIndicatorProfile stopAnimating];

}




#pragma mark - Key Board ;
- (void)onShowKeyBoard: (NSNotification *)notification
{
    [mScrollView setContentInset:UIEdgeInsetsMake(0, 0, 260, 0)];
//    [mScrollView setContentSize:CGSizeMake(320,696)];
//    [mScrollView setContentOffset:CGPointMake(0, 80) animated:YES];
}

- (void)onHideKeyBoard: (NSNotification *)notification
{
    [mScrollView setContentInset:UIEdgeInsetsMake(0, 0, 0, 0)];
//    [mScrollView setContentSize:CGSizeMake(320,mScrollView.frame.size.height)];
}

-(IBAction)onTouchBtnBack:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}


-(IBAction)onTouchBtnSaveChanges:(id)sender
{
    NSMutableDictionary *mDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:mTxtFirstName.text, @"firstName", mTxtLastName.text,@"lastName", [NSString stringWithFormat:@"%@ %@", mTxtFirstName.text, mTxtLastName.text],@"fullName", nil];
    if ([mTxtOriginalPassword.text isEqualToString:@""] && [mTxtNewPassword.text isEqualToString:@""] && [mTxtNewPasswordConfirm.text isEqualToString:@""]) {
    }
    else
    {
        if(![mTxtNewPassword.text isEqualToString:mTxtNewPasswordConfirm.text])
        {
            [JUtils showMessageAlert:@"New Passwords mistach! You can leave all fields blank to not to change password"];
            return;
        }
        else if([mTxtNewPassword.text isEqualToString:@""])
        {
            [JUtils showMessageAlert:@"Passwords can't be blank!  You can leave all fields blank to not to change password"];
            return;
        }
//        else if(![[JUser me].specData isEqualToString:[JUser securingData:mTxtOriginalPassword.text]])
//        {
//            [JUtils showMessageAlert:@"You need to input correct old password!  You can leave all fields blank to not to change password"];
//            return;
//        }
        else
        {
            [mDict setObject:mTxtNewPassword.text forKey:@"password"];
            [mDict setObject:mTxtOriginalPassword.text forKey:@"old_password"];
//            [mDict setObject:[JUser securingData:mTxtNewPassword.text] forKey:@"specData"];
        }
    }
    
    
    [JUtils showLoadingIndicator:self.navigationController.view message:@"Updating Profile..."];
    [APIClient updateProfile:mDict success:^(JUser *user) {
        [JUtils hideLoadingIndicator: self.navigationController.view];
        [self.navigationController.view makeToast:@"Profile Updated Successfully" duration:1.0 position:CSToastPositionTop];
    } failure:^(NSString *errorMessage) {
        [JUtils hideLoadingIndicator: self.navigationController.view];
        [self.navigationController.view makeToast:errorMessage duration:1.0 position:CSToastPositionTop];
    }];
}

-(IBAction)onTouchBtnChangePhoto:(id)sender
{
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
        mPhoto.image=mImage;
        mPhoto.contentMode = UIViewContentModeScaleAspectFill;
        mIndicatorProfile.hidden=NO;
        [mIndicatorProfile startAnimating];
        [self uploadProfilePhoto:[self scaleAndRotateImage:mImage targetSize:CGSizeMake(200, 200)] quality:0.75];
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

- (void)uploadProfilePhoto:(UIImage*)imageTo quality:(float)quality// imageFrom:(NSString*)imageFrom
{
    [self setMFileNameToUpload:[self fileKeyForUpload]];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0),  ^ {
        
        NSData *data = [NSData dataWithData: UIImageJPEGRepresentation(imageTo,quality)];
        
        [[JAmazonS3ClientManager defaultManager] uploadProfilePhotoData:data fileKey:[self mFileNameToUpload] withProcessBlock:^ (float progress) {
            NSLog(@"Progress: %d", (int)(progress*100));
            
        } completeBlock:^ (NSString *obj1) {
            mBtnProfile.userInteractionEnabled=YES;

            if ([obj1 isKindOfClass:[NSString class]]) {
                NSMutableDictionary*mDict=[NSMutableDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%@.jpg", self.mFileNameToUpload], kUserProfilePhoto, nil];
                [APIClient updateProfile:mDict success:^(JUser *user) {
                    [mIndicatorProfile stopAnimating];
                    mIndicatorProfile.hidden=YES;
                    mPhoto.image=nil;
                    [mPhoto setImageWithURL:[[JAmazonS3ClientManager defaultManager] cdnUrlForProfilePhoto:[JUser me].profilePhoto]];
                    mPhoto.contentMode=UIViewContentModeScaleAspectFill;
                } failure:^(NSString *errorMessage) {
                    [mIndicatorProfile stopAnimating];
                    mIndicatorProfile.hidden=YES;
                    [self.navigationController.view makeToast:@"Error in uploading profile photo" duration:2.0 position:CSToastPositionTop];
                }];
            
            }
            else
            {
                [mIndicatorProfile stopAnimating];
                mIndicatorProfile.hidden=YES;
                [self.navigationController.view makeToast:@"Error in uploading profile photo" duration:2.0 position:CSToastPositionTop];
            }
        }];
        
    });
}

-(UIImage * )scaleAndRotateImage:(UIImage *)image targetSize:(CGSize)targetSize
{
    CGImageRef imgRef = image.CGImage;
    
    if ( !image )
        NSLog(@"Image is nil in scaleAndRotateImage");
    
    CGFloat width = CGImageGetWidth(imgRef);
    CGFloat height = CGImageGetHeight(imgRef);
    
    //	CGAffineTransform transform = CGAffineTransformIdentity;
    CGRect bounds = CGRectMake(0, 0, width, height);
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    
    
    CGContextRef context = CGBitmapContextCreate(NULL, targetSize.width,targetSize.height, 8, targetSize.width * 4, colorSpace, (CGBitmapInfo)kCGImageAlphaPremultipliedLast);
    //	CGContextTranslateCTM(context, 0, bounds.size.height);
    //	CGContextScaleCTM(context, 1, -1);
    CGColorSpaceRelease(colorSpace);
    
    
    
    CGContextScaleCTM(context, targetSize.width/bounds.size.width, targetSize.width/bounds.size.width);
    //    CGContextTranslateCTM(context, 0, -(bounds.size.height-bounds.size.width)/2.0);
    //	CGContextConcatCTM(context, transform);
    CGContextDrawImage(context, CGRectMake(0, 0, bounds.size.width, bounds.size.height), image.CGImage);
    CGImageRef imageRef = CGBitmapContextCreateImage(context);
    UIImage *finalImage = [[UIImage alloc] initWithCGImage:imageRef scale:1 orientation:UIImageOrientationUp];
    CGImageRelease(imageRef);
    CGContextRelease(context);
    
    return finalImage;
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return NO;
}
@end
