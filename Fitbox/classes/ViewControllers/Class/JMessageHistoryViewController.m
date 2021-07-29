//
//  JMessageHistoryViewController.m
//  Fitbox
//
//  Created by Khatib H. on 2/18/16.
//  
//

#import "JMessageHistoryViewController.h"
#import "JMessageViewController.h"
#import "JMessageHistoryTableViewCell.h"
#import "JAmazonS3ClientManager.h"
#import "SVPullToRefresh.h"

@interface JMessageHistoryViewController ()<UITableViewDataSource, UITableViewDelegate>
{
    BOOL isLoading;
}


@property (nonatomic, weak) IBOutlet UITableView *mTView;
@property (nonatomic, strong) NSMutableArray *mArrData;

@property (nonatomic, strong) IBOutlet UIImageView          *mImgProfilePhotoTopRight;

@end

@implementation JMessageHistoryViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _mArrData = [[NSMutableArray alloc] init];
    isLoading = false;
    
    __block JMessageHistoryViewController *viewController=self;
    [_mTView addPullToRefreshWithActionHandler:^{
        [viewController insertRowAtTop];
    }];
    
    // setup infinite scrolling
    [_mTView addInfiniteScrollingWithActionHandler:^{
        [viewController insertRowAtBottom];
    }];
    
    
    [self loadData:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [_mTView reloadData];
//    [self initTopRightProfilePhoto];
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
            [self loadData:nil];
        }
    });
}


- (void)insertRowAtBottom {
    int64_t delayInSeconds = 0.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        if((!isLoading)&&([_mArrData count]>20))
        {
            [self loadData:[_mArrData lastObject]];
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
    if ([segue.identifier isEqualToString:@"showMessageView"]) {
        JMessageViewController *mController = (JMessageViewController*)segue.destinationViewController;
        mController.mMessageHistory = (JMessageHistory*)sender;
    }
}


-(IBAction)onTouchBtnBack:(id)sender
{
    [self.navigationController popViewControllerAnimated:true];
}
-(void)loadData:(JMessageHistory*)lastObject
{
    
    isLoading = true;
    [APIClient loadMessageHistories:lastObject success:^(NSArray *messageHistories) {
        [_mTView.pullToRefreshView stopAnimating];
        [_mTView.infiniteScrollingView stopAnimating];
        if (!lastObject) {
            [self.mArrData removeAllObjects];
        }
        [self.mArrData addObjectsFromArray:messageHistories];
        isLoading = false;
        [self.mTView reloadData];
    } failure:^(NSString *errorMessage) {
        [_mTView.pullToRefreshView stopAnimating];
        [_mTView.infiniteScrollingView stopAnimating];
        isLoading = false;

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

//- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    return 58;
//}

#pragma tableview delegate

#pragma mark - Table view delegate

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 65.0;
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
            cell.textLabel.text=@"Loading chat history..";
        else
        {
            cell.textLabel.text = @"No chat history!";
        }
        //whatever else to configure your one cell you're going to return
        return cell;
    }
    
    JMessageHistoryTableViewCell* cell = [ tableView dequeueReusableCellWithIdentifier : @"JMessageHistoryTableViewCell" ] ;
    JMessageHistory *object = [self.mArrData objectAtIndex:indexPath.row];
    [cell setInfo:object];
    //    cell.mBtnLike.selected = [[Engine followPersons] containsObject:object.objectId];
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([_mArrData count] > 0) {
        [self performSegueWithIdentifier:@"showMessageView" sender:[_mArrData objectAtIndex:indexPath.row]];
    }
}

-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([_mArrData count] == 0) {
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
        [JUtils showLoadingIndicator:self.navigationController.view message:@"Removing..."];
        JMessageHistory *object = [_mArrData objectAtIndex:indexPath.row];
        [APIClient removeMessageHistory:object success:^(JMessageHistory *messageHistory) {
            [_mArrData removeObject:object];
            [_mTView reloadData];
            [JUtils hideLoadingIndicator:self.navigationController.view];
        } failure:^(NSString *errorMessage) {
            [JUtils hideLoadingIndicator:self.navigationController.view];
            [self.navigationController.view makeToast:errorMessage duration:1.5 position:CSToastPositionTop];
        }];
    }
}
@end
