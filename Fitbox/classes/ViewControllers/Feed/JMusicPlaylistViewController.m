//
//  JMusicPlaylistViewController.m
//  Fitbox
//
//  Created by Khatib H. on 11/23/15.
//  
//

#import "JMusicPlaylistViewController.h"
#import "SVPullToRefresh.h"
@interface JMusicPlaylistViewController ()
{
   
    
    BOOL isLoading;
    NSString *mLastSearchString;

}

@property (nonatomic, strong)  NSMutableArray *mArrData;
@property (nonatomic, strong)  NSMutableArray *mArrDataAll;
@property (nonatomic, strong)  NSMutableArray *mArrDataFiltered;
@property (nonatomic, strong)  IBOutlet UITableView *mTView;
@property (nonatomic, strong)  IBOutlet UISearchBar *mSearchBar;
@end

@implementation JMusicPlaylistViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    _mArrDataAll = [Engine gSoundCloudPlayLists];
    _mArrDataFiltered = [[NSMutableArray alloc] init];
    _mArrData = _mArrDataAll;
    isLoading = false;
    [_mTView setContentInset:UIEdgeInsetsMake(50, 0, 0, 0)];
//    __block JMusicPlaylistViewController *viewController=self;
//    [_mTView addPullToRefreshWithActionHandler:^{
//        [viewController insertRowAtTop];
//    }];
    
    // setup infinite scrolling
    //    [_mTView addInfiniteScrollingWithActionHandler:^{
    //        [viewController insertRowAtBottom];
    //    }];
    
    //    [self loadData:nil filterString:nil];
    if ([_mArrDataAll count]==0) {
        [self getPlayLists];
    }

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
            //            [self loadData:nil filterString:mLastSearchString];
            [self getPlayLists];
        }
    });
}


//
//- (void)insertRowAtBottom {
//    int64_t delayInSeconds = 0.0;
//    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
//    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
//        if((!isLoading)&&([_mArrData count]>20))
//        {
//            [self loadData:[_mArrData lastObject] filterString:mLastSearchString];
//        }
//        else
//        {
//            [_mTView.infiniteScrollingView stopAnimating];
//        }
//    });
//}
//

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([segue.identifier isEqualToString:@"showSinglePlaylist"]) {
        JMusicPlayerViewController *mController = (JMusicPlayerViewController*)segue.destinationViewController;
        mController.mMusicInfo = (JSoundCloudPlayListInfo*)sender;
    }
}



-(void)getPlayLists
{
//    if ([_mArrData count] == 0) {
//        [JUtils showLoadingIndicator:self.navigationController.view message:@"Loading"];
//    }
    isLoading = true;
    AFHTTPSessionManager *sessionManager = [[AFHTTPSessionManager alloc] initWithBaseURL:[NSURL URLWithString:@"http://api.soundcloud.com/"]];
    sessionManager.responseSerializer = [AFJSONResponseSerializer serializer];
    sessionManager.responseSerializer.acceptableContentTypes =[NSSet setWithObjects:@"application/json", @"text/json", @"text/javascript", nil];
    NSString *path = [NSString stringWithFormat:@"users/%@/playlists?client_id=%@", SOUND_CLOUD_GREGORY_USER_ID, SOUND_CLOUD_ID];
    [sessionManager GET:path parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        isLoading = false;
        if (responseObject) {
            NSArray *arrayPlaylists = (NSArray*)responseObject;
            
            for (int i=0; i<[arrayPlaylists count]; i++)
            {
                NSDictionary *dict = [arrayPlaylists objectAtIndex:i];
                JSoundCloudPlayListInfo *playlist = [[JSoundCloudPlayListInfo alloc] init];
                [playlist setWithDictionary:dict];
                [[Engine gSoundCloudPlayDict] setObject:playlist forKey:playlist.playlistId];
                [_mArrDataAll addObject:playlist];
            }
        }
        [_mTView reloadData];
//        if ([responseObject objectForKey:@"track_count"]) {
//            int track_count = [[responseObject objectForKey:@"track_count"] intValue];
//            if (track_count > 0) {
//                NSArray *mResponseArray = [responseObject objectForKey:@"tracks"];
//                for (int i=0; i<[mResponseArray count]; i++)
//                {
//                    NSDictionary *mDict = [mResponseArray objectAtIndex:i];
//                    JSoundCloudMusicInfo *info = [[JSoundCloudMusicInfo alloc] init];
//                    [info setWithDictionary:mDict];
//                }
//            }
//        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        isLoading = false;
        if (error) {
            NSLog(@"Error: %@", error);
        }
        [_mTView reloadData];
    }];
}


- (IBAction)onTouchBtnBack: (id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
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
    return 100.0;
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
            cell.textLabel.text = @"No Playlists!";
        }
        //whatever else to configure your one cell you're going to return
        return cell;
    }
    
    JMusicPlayListTableViewCell* cell = [ tableView dequeueReusableCellWithIdentifier : @"JMusicPlayListTableViewCell" ] ;
    JSoundCloudPlayListInfo *object = [self.mArrData objectAtIndex:indexPath.row];
    [cell setInfo:object];
    
    if (indexPath.row % 2 == 0) {
        cell.backgroundColor = [UIColor whiteColor];
    }
    else
    {
        cell.backgroundColor = MAIN_COLOR_LIGHT_GRAY;
    }
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self performSegueWithIdentifier:@"showSinglePlaylist" sender:[_mArrData objectAtIndex:indexPath.row]];
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
        [self.mTView reloadData];
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
    [self.mTView reloadData];
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
//    _mArrData = _mArrDataFiltered;
//    [_mTView reloadData];
    [searchBar setShowsCancelButton:YES animated:YES];
}

-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [searchBar setShowsCancelButton:NO animated:YES];
    [searchBar resignFirstResponder];
    
    if(![self.mSearchBar.text isEqualToString:@""])
    {
        [self doFilterMembers:self.mSearchBar.text];
//        [self loadData:nil filterString:_mSearchBar.text];
    }
}

-(void)doFilterMembers:(NSString*)filterText
{
    NSString *lowerCaseFilter = [filterText lowercaseString];
    [self.mArrDataFiltered removeAllObjects];
    
    for (JSoundCloudPlayListInfo *track in self.mArrDataAll) {
//        NSString *mString = [NSString stringWithFormat:@"%@ %@", [contact.lastNames lowercaseString], [contact.firstNames lowercaseString]];
        if([[track.playlistTitle lowercaseString] containsString:lowerCaseFilter] || [[track.playlistDescription lowercaseString] containsString:lowerCaseFilter])
        {
            [self.mArrDataFiltered addObject:track];
        }
    }
    [self.mTView reloadData];
}


@end
