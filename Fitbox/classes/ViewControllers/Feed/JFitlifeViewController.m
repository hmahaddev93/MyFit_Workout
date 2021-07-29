//
//  JFitlifeViewController.m
//  Fitbox
//
//  Created by Khatib H. on 11/8/15.
//  
//

#import "JFitlifeViewController.h"
#import "JSingleUserViewController.h"
#import "JAmazonS3ClientManager.h"
#import "SVPullToRefresh.h"

@interface JFitlifeViewController ()
{
    BOOL isLoading;
    NSString *mLastSearchString;
}

@end

@implementation JFitlifeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _mArrDataAll = [[NSMutableArray alloc] init];
    _mArrDataFiltered = [[NSMutableArray alloc] init];
    _mArrData = _mArrDataAll;
    isLoading = false;
    self.navigationItem.leftBarButtonItem.badgeValue = @"";

    __block JFitlifeViewController *viewController=self;
    [_mTView addPullToRefreshWithActionHandler:^{
        [viewController insertRowAtTop];
    }];
    
    // setup infinite scrolling
    [_mTView addInfiniteScrollingWithActionHandler:^{
        [viewController insertRowAtBottom];
    }];
    
    [self loadData:nil filterString:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateListingCount) name:NOTIF_CLASS_LISTING_COUNT_UPDATED object:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)updateListingCount
{
    if ([Engine gClassListingCount]>0) {
        self.navigationItem.leftBarButtonItem.badgeValue = [NSString stringWithFormat:@"%d", [Engine gClassListingCount]];
//        self.navigationItem.leftBarButtonItem.badgeBGColor = [UIColor blackColor];
    }
    else
    {
        self.navigationItem.leftBarButtonItem.badgeValue = @"";
    }
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self updateListingCount];

//    [self initTopRightProfilePhoto];
}
-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIF_CLASS_LISTING_COUNT_UPDATED object:nil];
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
        _mImgProfilePhotoTopRight.image = [UIImage imageNamed:@"app_icon"];
        if (profilePhoto && ![profilePhoto isEqualToString:@""]) {
            [_mImgProfilePhotoTopRight setImageWithURL:[[JAmazonS3ClientManager defaultManager] cdnUrlForProfilePhotoThumb:profilePhoto]];
        }
    }
    else
    {
        _mImgProfilePhotoTopRight.hidden = true;
    }
}
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([segue.identifier isEqualToString:@"showSingleUser"]) {
        JSingleUserViewController *mController = (JSingleUserViewController*)segue.destinationViewController;
        mController.mPerson = (JUser*)sender;
    }
}



-(IBAction)onTouchBtnMusic:(id)sender
{
    
}


-(void)loadData:(JUser*)lastObject filterString:(NSString*)filterString
{
    
    isLoading = true;
    mLastSearchString = filterString;
    [APIClient getFitlifeUsers:filterString lastUser:lastObject success:^(NSArray *users) {
        isLoading = false;
        [_mTView.pullToRefreshView stopAnimating];
        [_mTView.infiniteScrollingView stopAnimating];
        
        if ([users count]>0)
        {
            if (!lastObject) {
                [self.mArrData removeAllObjects];
            }
            [self.mArrData addObjectsFromArray:users];
        }
        [self.mTView reloadData];
        
    } failure:^(NSString *errorMessage) {
        isLoading = false;
        [_mTView.pullToRefreshView stopAnimating];
        [_mTView.infiniteScrollingView stopAnimating];
        [self.mTView reloadData];
    }];
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

#pragma tableview delegate

#pragma mark - Table view delegate

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return SCREEN_WIDTH/2.0;
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if([_mArrData count]==0)
    {
        UITableViewCell *cell = [[UITableViewCell alloc] init];
        [cell.textLabel setFont:[UIFont fontWithName:FONT_NAME_AAUX_PROREGULAR size:13.0]];
        [cell.textLabel setTextColor:[UIColor grayColor]];
        [cell.textLabel setTextAlignment:NSTextAlignmentCenter];
        [cell.textLabel setFrame:cell.frame];
        cell.selectionStyle=UITableViewCellSelectionStyleNone;
        if(isLoading)
            cell.textLabel.text=@"Loading...";
        else
        {
            cell.textLabel.text = @"Nothing Found!";
        }
        //whatever else to configure your one cell you're going to return
        return cell;
    }
    
    JFitlifeTableViewCell* cell = [ tableView dequeueReusableCellWithIdentifier : @"JFitlifeTableViewCell" ] ;
    JUser *object = [self.mArrData objectAtIndex:indexPath.row];
    NSString *bgURL = object.backgroundPhoto;
    if (bgURL && ![bgURL isEqualToString:@""]) {
        [cell.mImgView setImageWithURL:[[JAmazonS3ClientManager defaultManager] cdnUrlForProfileBackground:bgURL]];
    }
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([_mArrData count] > 0) {
        [self performSegueWithIdentifier:@"showSingleUser" sender:[_mArrData objectAtIndex:indexPath.row]];
    }
}




#pragma mark -
#pragma mark - Search Bar
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    if(![self.mSearchBar.text isEqualToString:@""])
    {
        [self doFilterMembers:self.mSearchBar.text];
    }
    else
    {
        [self.mTView reloadData];
    }
}

- (void)searchBarCancelButtonClicked:(UISearchBar *) searchBar
{
    [searchBar setText:@""];
    [searchBar resignFirstResponder];
    [searchBar setShowsCancelButton:NO animated:YES];
    _mArrData = _mArrDataAll;
    [_mArrDataFiltered removeAllObjects];
    [self.mTView reloadData];
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
    _mArrData = _mArrDataFiltered;
    [_mTView reloadData];
    [searchBar setShowsCancelButton:YES animated:YES];
}

-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [searchBar setShowsCancelButton:NO animated:YES];
    [searchBar resignFirstResponder];
    
    if(![self.mSearchBar.text isEqualToString:@""])
    {
        [self doFilterMembers:self.mSearchBar.text];
        [self loadData:nil filterString:_mSearchBar.text];
    }
}

-(void)doFilterMembers:(NSString*)filterText
{
    NSString *lowerCaseFilter = [filterText lowercaseString];
    [self.mArrDataFiltered removeAllObjects];
    
    for (ContactsData *contact in self.mArrData) {
        NSString *mString = [NSString stringWithFormat:@"%@ %@", [contact.lastNames lowercaseString], [contact.firstNames lowercaseString]];
        if([mString containsString:lowerCaseFilter])
        {
            [self.mArrDataFiltered addObject:contact];
        }
    }
    [self.mTView reloadData];
}


@end
