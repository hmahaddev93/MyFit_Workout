//
//  JSingleUserViewController.m
//  Zold
//
//  Created by Khatib H. on 8/18/14.
//  
//

#import "JSingleUserViewController.h"
#import "JSingleViewController.h"
#import "JAmazonS3ClientManager.h"
#import "JNewsViewController.h"

@interface JSingleUserViewController ()

@end

@implementation JSingleUserViewController


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    mArrData=[[NSMutableArray alloc] init];
    mTView.tableHeaderView = mViewHeader;
    [self initHeaderView];
    [self getUsersProfileItem:nil];
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear: animated];
}


// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([segue.identifier isEqualToString:@"showSingleProduct"])
    {
        JSingleViewController *mView = (JSingleViewController*)segue.destinationViewController;
        mView.mItem = sender;
    }
    else if ([segue.identifier isEqualToString:@"showSingleNews"])
    {
        JNewsViewController *mView = (JNewsViewController*)segue.destinationViewController;
        mView.mCInfo = sender;
    }
}

-(void)initView
{
    [mArrData removeAllObjects];
    [mTView reloadData];
    [self getUsersProfileItem:nil];
//    [JPerson loadPersonWithWithID:self.mPerson.objectId completionBlock:^(JPerson *person) {
//        [mTView reloadData];
//    }];

}


-(void) initHeaderView
{
    mLblBrand.text = _mPerson.fullName;
    [self.navigationItem setTitle:_mPerson.fullName];

    if (self.mPerson.backgroundPhoto) {
        [mImgBrand setImageWithURL:[[JAmazonS3ClientManager defaultManager] cdnUrlForProfileBackground:self.mPerson.backgroundPhoto]];
    }
}

-(void)deselectAllButtons:(UIView*)mView
{
    NSArray *mArr=mView.subviews;
    for (int i=0; i<[mArr count]; i++) {
        UIView *subView=[mArr objectAtIndex:i];
        if([subView isKindOfClass:[UIButton class]])
        {
            UIButton* mBtn=(UIButton*)subView;
            mBtn.selected=NO;
        }
    }
}


-(void)getUsersProfileItem:(JItem*)lastObject
{
    [APIClient getUserItems:self.mPerson._id lastItem:lastObject success:^(NSMutableArray *items) {
        if (!lastObject) {
            [mArrData removeAllObjects];
        }
        if([items count]>0)
        {
            [mArrData addObjectsFromArray:items];
        }
        [mTView reloadData];
    } failure:^(NSString *errorMessage) {
        
    }];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


#pragma mark - Touch Event

- (IBAction)onTouchBtnBack: (id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

-(IBAction)onTouchBtnInfo:(id)sender
{
    if (self.mPerson.siteLink) {
        NSLog(@"URL: %@", self.mPerson.siteLink);
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:self.mPerson.siteLink]];
    }
}

-(IBAction)onTouchBtnShare:(id)sender
{
    [self shareItemInfo:self.mPerson];
}

-(void)shareItemInfo:(JUser *)feedInfo{
    NSString *textToShare = [NSString stringWithFormat:@"Checkout this on FITBOX www.iwantfitbox.com   %@", @""];
    
    CGPoint contentOffset = mTView.contentOffset;
    mTView.contentOffset = CGPointMake(0, 0);
    
    UIImage *image = [JUtils imageWithView:mTView];
    mTView.contentOffset = contentOffset;
    NSArray *objectsToShare = @[textToShare, image];
    
    UIActivityViewController *activityVC = [[UIActivityViewController alloc] initWithActivityItems:objectsToShare applicationActivities:nil];
    
    NSMutableArray *excludeActivities = [[NSMutableArray alloc] initWithObjects:UIActivityTypeAirDrop,
                                         UIActivityTypePrint,UIActivityTypePostToTencentWeibo, UIActivityTypePostToWeibo,
                                         //                                         UIActivityTypeAssignToContact,
                                         UIActivityTypeSaveToCameraRoll,
                                         UIActivityTypeAddToReadingList,
                                         UIActivityTypePostToFlickr,
                                         UIActivityTypePostToVimeo, UIActivityTypeCopyToPasteboard, nil];
    
    
    activityVC.excludedActivityTypes = excludeActivities;
    
    
    [self presentViewController:activityVC animated:YES completion:nil];
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    //    if((mIsSearch)&&([[Engine mIsFavourite] isEqualToString:@"1"])
    return [mArrData count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return SCREEN_WIDTH;
}

#pragma tableview delegate

#pragma mark - Table view delegate


- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell* cell = [ tableView dequeueReusableCellWithIdentifier : @"JSingleUserItemCell" ] ;
    JItem *object = [mArrData objectAtIndex:indexPath.row];

    UIActivityIndicatorView *mActivityIndicator = [cell viewWithTag:101];
    [mActivityIndicator startAnimating];
    UIImageView *mImgView = [cell viewWithTag:100];
    
    mImgView.image = nil;
    
    if ([object.itemType isEqualToString:ITEM_TYPE_NEWS]) {
//        [mImgView setImageWithURL:[NSURL URLWithString:[[object objectForKey:kItemPhotos] objectAtIndex:0]]];
        if([object.photos count]>0)
        {
            [mImgView setImageWithURL:[[JAmazonS3ClientManager defaultManager] cdnUrlForItemPhoto:[object.photos objectAtIndex:0]]];
        }
    }
    else if ([object.itemType isEqualToString:ITEM_TYPE_PHOTO]) {
        if([object.photos count]>0)
        {
            [mImgView setImageWithURL:[[JAmazonS3ClientManager defaultManager] cdnUrlForItemPhoto:[object.photos objectAtIndex:0]]];
        }
    }
    else if([object.itemType isEqualToString:ITEM_TYPE_PRODUCT])
    {
        if([object.photos count]>0)
        {
            [mImgView setImageWithURL:[[JAmazonS3ClientManager defaultManager] cdnUrlForItemPhoto:[object.photos objectAtIndex:0]]];
        }
        else if(object.video)
        {
            [mImgView setImageWithURL:[[JAmazonS3ClientManager defaultManager] cdnUrlForItemVideoThumb:object.video]];
        }
    }

    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    JItem *object = [mArrData objectAtIndex:indexPath.row];
    if ([object.itemType isEqualToString:ITEM_TYPE_NEWS])
    {
        [self performSegueWithIdentifier:@"showSingleNews" sender:[mArrData objectAtIndex:indexPath.row]];
    }
    else if([object.itemType isEqualToString:ITEM_TYPE_PRODUCT])
    {
        [self performSegueWithIdentifier:@"showSingleProduct" sender:[mArrData objectAtIndex:indexPath.row]];
    }
}




@end
