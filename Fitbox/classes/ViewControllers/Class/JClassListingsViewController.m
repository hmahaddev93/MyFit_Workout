//
//  JClassListingsViewController.m
//  Fitbox
//
//  Created by Khatib H. on 2/18/16.
//  
//

#import "JClassListingsViewController.h"
#import "JClassDetailViewController.h"
#import "JAmazonS3ClientManager.h"
#import "SVPullToRefresh.h"
#import "BasicMapAnnotation.h"

#define SPAN_MY_LOCATION 0.05
@import MapKit;

@interface JClassListingsViewController ()<MKMapViewDelegate, UITableViewDataSource, UITableViewDelegate, UIAlertViewDelegate>
{
    BOOL isLoading;
    NSString *mLastSearchString;
    
    JListing *actionObject;
    
    BOOL startClicked;
    
}

@property (nonatomic, strong) UIView *viewMapOverlay;
@property (nonatomic, strong) UIImageView *imgLogoWorkoutBuddy;
//@property (nonatomic, weak) IBOutlet UIView *viewWelcome;
@property (nonatomic, weak) IBOutlet UIButton *btnWorkoutBuddy;



@property (nonatomic, weak) IBOutlet UITableView *mTView;
@property (nonatomic, strong) NSMutableArray *mArrData;
@property (nonatomic, strong) IBOutlet UIImageView *mImgBg;
@property (nonatomic, weak) IBOutlet UISearchBar *mSearchBar;

@property (nonatomic, retain) NSMutableArray* mArrDataAll;
@property (nonatomic, retain) NSMutableArray* mArrDataFiltered;

@property (nonatomic, strong) IBOutlet UIImageView          *mImgProfilePhotoTopRight;
@property (nonatomic, strong) MKMapView          *mMapView;

@end

@implementation JClassListingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    startClicked = false;
    
    // Do any additional setup after loading the view.
    _mArrDataAll = [[NSMutableArray alloc] init];
    _mArrDataFiltered = [[NSMutableArray alloc] init];
    _mArrData = _mArrDataAll;
    isLoading = false;
    
    _viewMapOverlay = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 170.0)];
    _imgLogoWorkoutBuddy = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 170.0)];
    _imgLogoWorkoutBuddy.image=[UIImage imageNamed:@"bgWorkoutBuddy"];
    _imgLogoWorkoutBuddy.contentMode = UIViewContentModeCenter;
    _imgLogoWorkoutBuddy.backgroundColor= [UIColor colorWithWhite:1 alpha:0.8];
    _mMapView = [[MKMapView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 170.0)];
    _mMapView.delegate = self;
    MKCoordinateRegion region = MKCoordinateRegionMake([Engine myLocation], MKCoordinateSpanMake(SPAN_MY_LOCATION, SPAN_MY_LOCATION));
    [_mMapView setRegion:region animated:true];
    [_viewMapOverlay addSubview:_mMapView];
    [_viewMapOverlay addSubview:_imgLogoWorkoutBuddy];
    _mTView.tableHeaderView = _viewMapOverlay;

    __block JClassListingsViewController *viewController=self;
    [_mTView addPullToRefreshWithActionHandler:^{
        [viewController insertRowAtTop];
    }];
    
    // setup infinite scrolling
    [_mTView addInfiniteScrollingWithActionHandler:^{
        [viewController insertRowAtBottom];
    }];

//    [self loadData:nil filterString:nil];
    [self.btnWorkoutBuddy setTitle:@"START" forState:UIControlStateNormal];
    [self updateUnreadMessageCount];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(removeListing:) name:NOTIF_REMOVE_LISTING object:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)removeListing:(NSNotification*)notif
{
    if (notif.object) {
        [_mArrDataAll removeObject:notif.object];
        [_mArrDataFiltered removeObject:notif.object];
        [self checkAndReloadTableView];
    }
}


-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self initTopRightProfilePhoto];

    [self updateUnreadMessageCount];
    [APIClient checkNewMessages];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateUnreadMessageCount) name:NOTIF_MESSAGE_COUNT_UPDATED object:nil];
}
-(void)updateUnreadMessageCount
{
    if ([Engine gNewMessageCount]>0) {
        self.navigationItem.rightBarButtonItem.badgeValue = [NSString stringWithFormat:@"%d", [Engine gNewMessageCount]];
    }
    else
    {
        self.navigationItem.rightBarButtonItem.badgeValue = @"";
        //        self.navigationItem.rightBarButtonItem.badgeBGColor = [UIColor clearColor];
    }
}
-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIF_MESSAGE_COUNT_UPDATED object:nil];
}

-(IBAction)onTouchBtnBack:(id)sender
{
    [self.navigationController popViewControllerAnimated:true];
}

-(IBAction)onTouchBtnStart:(id)sender
{
    if (startClicked) {
        if (![[JUser me] isAuthorized]) {
            [Engine showAlertViewForLogin];
        }
        else
        {
            [self performSegueWithIdentifier:@"segueNewListing" sender:nil];
        }
    }
    else{
        startClicked = true;
        [self loadData:nil filterString:nil];
        [self.btnWorkoutBuddy setTitle:@"FIND A WORKOUT BUDDY" forState:UIControlStateNormal];
        [self.mTView reloadData];
    }
}
#pragma mark -
#pragma mark - SVPullToRefresh

- (void)insertRowAtTop {
    int64_t delayInSeconds = 0.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        //update
        if(isLoading)
        {
            [_mTView.pullToRefreshView stopAnimating];
        }
        else
        {
            //            mPage = 0;
            [self loadData:nil filterString:mLastSearchString];
        }
    });
}


- (void)insertRowAtBottom {
    int64_t delayInSeconds = 0.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        if((!isLoading)&&([_mArrData count]>20))
        {
            [self loadData:[_mArrData lastObject] filterString:mLastSearchString];
        }
        else
        {
            [_mTView.infiniteScrollingView stopAnimating];
        }
    });
}


-(void)initTopRightProfilePhoto
{
    if ([[JUser me] isAuthorized]) {
        _mImgProfilePhotoTopRight.hidden = false;
        NSString *profilePhoto = [JUser me].profilePhoto;
        _mImgProfilePhotoTopRight.image = [UIImage imageNamed:@"iconPerson56"];
        if (profilePhoto && ![profilePhoto isEqualToString:@""]) {
            [_mImgProfilePhotoTopRight setImageWithURL:[[JAmazonS3ClientManager defaultManager] cdnUrlForProfilePhotoThumb:profilePhoto]];
        }
    }
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([segue.identifier isEqualToString:@"showClassDetail"]) {
        JClassDetailViewController *mController = (JClassDetailViewController*)segue.destinationViewController;
        mController.mListing = (JListing*)sender;
    }
}

-(BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender
{
    if (![[JUser me] isAuthorized]) {
        if ([identifier isEqualToString:@"segueNewListing"] || [identifier isEqualToString:@"showMessageHistory"]) {
            [Engine showAlertViewForLogin];
            return false;
        }
    }
    return true;
}

-(void)loadData:(JListing*)lastObject filterString:(NSString*)filterString
{
    if (![JUtils isLocationAvailable]) {
        return;
    }

    isLoading = true;
    mLastSearchString = filterString;
    [APIClient loadListings:filterString lastListing:lastObject success:^(NSArray *listings) {
        [_mTView.pullToRefreshView stopAnimating];
        [_mTView.infiniteScrollingView stopAnimating];

        if ([listings count]>0)
        {
            if (!lastObject) {
                [self.mArrDataAll removeAllObjects];
            }
            [self.mArrDataAll addObjectsFromArray:listings];
        }

        isLoading = false;
        [self checkAndReloadTableView];
    } failure:^(NSString *errorMessage) {
        [_mTView.pullToRefreshView stopAnimating];
        [_mTView.infiniteScrollingView stopAnimating];
        isLoading = false;
        [self checkAndReloadTableView];
    }];
    
}

-(void)checkAndReloadTableView
{
    [_mMapView removeAnnotations:_mMapView.annotations];
    if ([self.mArrData count] == 0) {
        _mImgBg.hidden = false;
        MKCoordinateRegion region = MKCoordinateRegionMake([Engine myLocation], MKCoordinateSpanMake(SPAN_MY_LOCATION, SPAN_MY_LOCATION));
        [_mMapView setRegion:region animated:true];
//        _mTView.tableHeaderView = nil;
    }
    else
    {
        for (int i=0; i<[_mArrData count]; i++) {
            JListing *obj = [_mArrData objectAtIndex:i];
            [self addPinToMap:[[obj.lnglat objectAtIndex:1] doubleValue] lng:[[obj.lnglat objectAtIndex:0] doubleValue]];
        }
        
        [_mMapView showAnnotations:_mMapView.annotations animated:true];
        _mImgBg.hidden = true;
    }
    
    if ([self.mArrDataAll count]==0)
//    if (!startClicked)
    {
        self.imgLogoWorkoutBuddy.hidden = false;
//        [self.btnWorkoutBuddy setTitle:@"START" forState:UIControlStateNormal];
    }
    else
    {
        self.imgLogoWorkoutBuddy.hidden = true;
//        [self.btnWorkoutBuddy setTitle:@"FIND A WORKOUT BUDDY" forState:UIControlStateNormal];
    }
    [self.mTView reloadData];

}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    //    if((mIsSearch)&&([[Engine mIsFavourite] isEqualToString:@"1"])
    if ([self.mArrData count] == 0) {
        return 1;
    }
    return [self.mArrData count];
}

//- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    return 58;
//}

#pragma tableview delegate

#pragma mark - Table view delegate

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self.mArrData count] == 0) {
        return SCREEN_HEIGHT - 64.0 - 60.0 - _mMapView.frame.size.height;
    }
    return 100.0;
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if([_mArrData count]==0)
    {
        UITableViewCell *cell = [[UITableViewCell alloc] init];
        [cell.textLabel setFont:[UIFont fontWithName:FONT_NAME_AAUX_PROBOLD size:15.0]];
        [cell.textLabel setTextColor:[UIColor blackColor]];
        [cell.textLabel setTextAlignment:NSTextAlignmentCenter];
        [cell.textLabel setFrame:cell.frame];
        
        cell.backgroundColor = [UIColor clearColor];
        cell.selectionStyle=UITableViewCellSelectionStyleNone;
        cell.textLabel.numberOfLines = 0;
        
        if (![JUtils isLocationAvailable]) {
            cell.textLabel.text=@"Location is disabled. Please update your location setting.";
        }
        else if(isLoading)
            cell.textLabel.text=@"Loading listings..";
        else
        {
            if (!startClicked) {
                cell.textLabel.text = @"Welcome to Workout Buddy!\n\nFind workout events and buddies in your area to assist you on your fitness journey!\n\nJust press Start below to get going!";
            }
            else if([_mArrDataAll count] == 0) {
//                UIImageView *imgView = [[UIImageView alloc] initWithFrame:cell.bounds];
//                imgView.image= [UIImage imageNamed:@"messageWorkoutBuddy"];
//                imgView.contentMode=UIViewContentModeCenter;
//                [cell.contentView addSubview:imgView];
//                cell.textLabel.text = @"No classes available, please check back later.";
                cell.textLabel.text = @"No events posted today!";
            }
            else
            {
                cell.textLabel.text = @"No classes with search keyword!";
            }
        }
        //whatever else to configure your one cell you're going to return
        return cell;
    }
    
    JClassListingTableViewCell* cell = [ tableView dequeueReusableCellWithIdentifier : @"JClassListingTableViewCell" ] ;
    cell.rowNumber = (int)indexPath.row;
    JListing *object = [self.mArrData objectAtIndex:indexPath.row];
    [cell setInfo:object];
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([_mArrData count] > 0) {
        [self performSegueWithIdentifier:@"showClassDetail" sender:[_mArrData objectAtIndex:indexPath.row]];
    }
}

-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if ([_mArrData count] == 0) {
        return false;
    }
    if (![[JUser me] isAuthorized]) {
        return false;
    }
    
    JListing *object = [self.mArrData objectAtIndex:indexPath.row];
    if(![object.user._id isEqualToString:[JUser me]._id])
    {
        return false;
    }
    return true;
}
-(UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellEditingStyleDelete;
}
-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        actionObject = [self.mArrData objectAtIndex:indexPath.row];
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:APP_NAME message:@"Are you sure to delete this class listing?" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Delete", nil];
        alertView.tag = 100;
        [alertView show];
    }
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 100) {
        if (buttonIndex == 1) {
            [JUtils showLoadingIndicator:self.navigationController.view message:@"Delete..."];
            [APIClient cancelListing:actionObject._id success:^(NSString *message) {
                [JUtils hideLoadingIndicator:self.navigationController.view];
                [_mArrData removeObject:actionObject];

                int number = [Engine gClassListingCount] - 1;
                if (number < 0) {
                    number = 0;
                }
                [Engine setGClassListingCount:number];
                
                [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_CLASS_LISTING_COUNT_UPDATED object:nil];
                
                actionObject = nil;
                
                [_mTView reloadData];
            } failure:^(NSString *errorMessage) {
                [JUtils hideLoadingIndicator:self.navigationController.view];
                [self.navigationController.view makeToast:errorMessage duration:1.5 position:CSToastPositionTop];
            }];
        }
    }
}

- (void)addPinToMap:(double)lat lng:(double)lng
{
    BasicMapAnnotation* mAnnot=[[BasicMapAnnotation alloc] initWithLatitude:lat andLongitude:lng];
    [_mMapView addAnnotation:mAnnot];
    
    
//        CLLocationCoordinate2D centerLocation;
//        centerLocation.latitude = lat;
//        centerLocation.longitude = lng;
//        MKCoordinateSpan span;
//        
//        span.latitudeDelta=MAP_SHOW_DISTANCE_FOR_PLACE;
//        span.longitudeDelta=MAP_SHOW_DISTANCE_FOR_PLACE;
//        centerLocation.latitude += MAP_SHOW_DISTANCE_FOR_PLACE/8;
//        MKCoordinateRegion region = {centerLocation, span};
//        [_mMapView setRegion:region];
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView1 viewForAnnotation:(id <MKAnnotation>)annotation {
    
    
    MKAnnotationView *annotationView = [[MKAnnotationView alloc] initWithAnnotation:annotation
                                                                    reuseIdentifier:@"CustomAnnotation"];
    
    annotationView.canShowCallout = NO;
    //    BasicMapAnnotation* annot=(BasicMapAnnotation*)annotation;
    UIView* mAnnotationContainer=[[UIView alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
    UIImageView* imgView=[[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
    [imgView setImage:[UIImage imageNamed:@"iconMapPin"]];
    [mAnnotationContainer addSubview:imgView];
    
//    UIImageView *mImgAnnot = [[UIImageView alloc] initWithFrame:CGRectM]
//    [mImgAnnot setFrame:CGRectMake(3, 4, 24, 24)];
//    [mAnnotationContainer addSubview:mImgAnnot];
    [annotationView addSubview:mAnnotationContainer];
    
    annotationView.centerOffset = CGPointMake(-15, -15);
    return annotationView;
    
}


#pragma mark -
#pragma mark - Search Bar
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    if(![self.mSearchBar.text isEqualToString:@""])
    {
        _mArrData = _mArrDataFiltered;
        [self doFilterMembers:self.mSearchBar.text];
    }
    else
    {
        _mArrData = _mArrDataAll;
        [self checkAndReloadTableView];
    }
}

- (void)searchBarCancelButtonClicked:(UISearchBar *) searchBar
{
    //    [UIView animateWithDuration:0.5f animations:^{
    //        mFlgViewSearch = NO;
    ////        [mViewSearch setFrame: CGRectMake(0, 64 - mViewSearch.frame.size.height, mViewSearch.frame.size.width, mViewSearch.frame.size.height)];
    //    } completion:^(BOOL finished) {
    [searchBar setText:@""];
    [searchBar resignFirstResponder];
    [searchBar setShowsCancelButton:NO animated:YES];
    _mArrData = _mArrDataAll;
    [_mArrDataFiltered removeAllObjects];
    [self checkAndReloadTableView];
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
//    _mArrData = _mArrDataFiltered;
    [searchBar setShowsCancelButton:YES animated:YES];
}

-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [searchBar setShowsCancelButton:NO animated:YES];
    [searchBar resignFirstResponder];
    
    if(![self.mSearchBar.text isEqualToString:@""])
    {
        [self doFilterMembers:self.mSearchBar.text];
    }
}

-(void)doFilterMembers:(NSString*)filterText
{
    NSString *lowerCaseFilter = [filterText lowercaseString];
    [self.mArrDataFiltered removeAllObjects];
    
    for (JListing *listing in self.mArrDataAll) {
        
        NSString *mString = [NSString stringWithFormat:@"%@ %@", [listing.comments lowercaseString], [listing.classType lowercaseString]] ;
        
        JUser *person = listing.user;
        if (person) {
            mString = [NSString stringWithFormat:@"%@ %@",mString, [person.username lowercaseString]];
        }
        
        if([mString containsString:lowerCaseFilter])
        {
            [self.mArrDataFiltered addObject:listing];
        }
    }
    
    [self checkAndReloadTableView];
}


@end
