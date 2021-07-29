//
//  JStoreViewController.m
//  Fitbox
//
//  Created by Khatib H. on 11/10/15.
//  
//

#import "JStoreViewController.h"
#import "JSingleViewController.h"
#import "JAmazonS3ClientManager.h"
#import "SVPullToRefresh.h"

@interface JStoreViewController ()

@end

@implementation JStoreViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [_mCollectionView registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:@"FooterView"];
    [_mCollectionView registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"HeaderView"];
    self.mArrData = [[NSMutableArray alloc] init];
    isLoading = false;
//    [self updateShoppingCartBadge];
    self.navigationItem.rightBarButtonItem.badgeValue = @"";
    self.navigationItem.leftBarButtonItem.badgeValue = @"";

    [_mCollectionView addPullToRefreshWithActionHandler:^{
        [self insertRowAtTop];
    }];
    
    [_mCollectionView addInfiniteScrollingWithActionHandler:^{
        [self insertRowAtBottom];
    }];
    [self loadData:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateShoppingCartBadge) name:SHOPPING_CART_NOTIFICATION object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateListingCount) name:NOTIF_CLASS_LISTING_COUNT_UPDATED object:nil];
}
-(void)insertRowAtTop
{
    if(!isLoading)
    {
        [self loadData:nil];
    }
    else
    {
        [_mCollectionView.pullToRefreshView stopAnimating];
    }
}


-(void)insertRowAtBottom
{
    if((_mArrData.count>15)&&(!isLoading))
    {
        [self loadData:[_mArrData lastObject]];
    }
    else
    {
        [_mCollectionView.infiniteScrollingView stopAnimating];
    }
}
-(void)updateShoppingCartBadge
{
    if ([[Engine gShoppingCart] count]>0) {
        self.navigationItem.rightBarButtonItem.badgeValue = [NSString stringWithFormat:@"%d", (int)[[Engine gShoppingCart] count]];
//        self.navigationItem.rightBarButtonItem.badgeBGColor = [UIColor redColor];
//        self.navigationItem.rightBarButtonItem.badgeTextColor = [UIColor whiteColor];
//        self.navigationItem.rightBarButtonItem.badge.layer.masksToBounds = true;
//        self.navigationItem.rightBarButtonItem.badge.layer.cornerRadius =  self.navigationItem.rightBarButtonItem.badge.frame.size.width / 2.0;
        //        self.navigationItem.rightBarButtonItem.b
    }
    else
    {
        self.navigationItem.rightBarButtonItem.badgeValue = @"";
//        self.navigationItem.rightBarButtonItem.badgeBGColor = [UIColor clearColor];
    }
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
-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:SHOPPING_CART_NOTIFICATION object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIF_CLASS_LISTING_COUNT_UPDATED object:nil];
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
//    [self initTopRightProfilePhoto];
    [_mCollectionView reloadData];
//    [self updateShoppingCartBadge];
}
-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self updateShoppingCartBadge];
    [self updateListingCount];
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


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([segue.identifier isEqualToString:@"showSingleProduct"])
    {
        JSingleViewController *mView = (JSingleViewController*)segue.destinationViewController;
        mView.mItem = sender;
    }
}


-(void)loadData:(JItem*)lastObject
{
    
    isLoading = true;
    [APIClient getStoreItems:lastObject success:^(NSMutableArray *items) {
        isLoading = false;
        [_mCollectionView.pullToRefreshView stopAnimating];
        [_mCollectionView.infiniteScrollingView stopAnimating];
        if ([items count]>0) {
            if (!lastObject) {
                [self.mArrData removeAllObjects];
            }
            [self.mArrData addObjectsFromArray:items];
            [self.mCollectionView reloadData];
        }
    } failure:^(NSString *errorMessage) {
        isLoading = false;
        [_mCollectionView.pullToRefreshView stopAnimating];
        [_mCollectionView.infiniteScrollingView stopAnimating];
    }];
}

#pragma mark - UICollectionView Delegate
- ( NSInteger ) collectionView : ( UICollectionView* ) _collectionView numberOfItemsInSection : ( NSInteger ) _section
{
    NSLog(@"%d", (int)self.mArrData.count);
    return [self.mArrData count];
}

- ( UICollectionViewCell* ) collectionView : ( UICollectionView* ) _collectionView cellForItemAtIndexPath : ( NSIndexPath* ) _indexPath
{
    static NSString* identifier = @"JItemCollectionViewCell" ;
    
    JItemCollectionViewCell*       cell    = [ _collectionView dequeueReusableCellWithReuseIdentifier : identifier forIndexPath : _indexPath ] ;
    JItem* item=[self.mArrData objectAtIndex:_indexPath.row];
    [cell setInfo:item];
    return cell ;
}

- ( NSInteger ) numberOfSectionsInCollectionView : ( UICollectionView* ) _collectionView
{
    return 1 ;
}

- ( void ) collectionView : ( UICollectionView* ) _collectionView didSelectItemAtIndexPath : ( NSIndexPath* ) _indexPath
{
    JItem* item=[self.mArrData objectAtIndex:_indexPath.row];
    [self performSegueWithIdentifier:@"showSingleProduct" sender:item];
}

-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section
{
    if(_mArrData.count == 0)
    {
        return CGSizeMake(SCREEN_WIDTH, SCREEN_HEIGHT - 49 - 64);
    }
    return CGSizeMake(0, 0);
    
}

-(UICollectionReusableView*)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    if (kind == UICollectionElementKindSectionHeader) {
        UICollectionReusableView* mView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier: @"HeaderView" forIndexPath:indexPath];
        return mView;
    }
    else
    {
        UICollectionReusableView *mView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier: @"FooterView" forIndexPath:indexPath];
        
        [mView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
        
        if(_mArrData.count == 0)
        {
            if(isLoading == true)
            {
                UIImageView *mImgView = [[UIImageView alloc] initWithFrame: mView.bounds];
                mImgView.animationImages = @[[UIImage imageNamed: @"uploadingAnimation00"], [UIImage imageNamed: @"uploadingAnimation01"], [UIImage imageNamed: @"uploadingAnimation02"], [UIImage imageNamed: @"uploadingAnimation03"]];
                mImgView.animationDuration = 0.4;
                mImgView.animationRepeatCount = 0;
                mImgView.contentMode = UIViewContentModeCenter;
                [mImgView startAnimating];
                [mView addSubview:mImgView];
            }
            else
            {
                UILabel *mLabel = [[UILabel alloc] initWithFrame: CGRectMake(20, 0, mView.bounds.size.width - 40, mView.bounds.size.height)];
                
                mLabel.text = @"No products here...";
                mLabel.textAlignment = NSTextAlignmentCenter;
                mLabel.textColor = [UIColor whiteColor];
                mLabel.numberOfLines = 0;
                mLabel.font =  [UIFont fontWithName:FONT_NAME_AAUX_PROBOLD size:14];
                [mView addSubview:mLabel];
            }
        }
        return mView;
    }
    
//    PFQuery *query = [PFQuery queryWithClassName:@"A"];
//    
//    PFQuery *querySub = [PFQuery queryWithClassName:@"B"];
//    [querySub whereKey:@"k" greaterThan:@5];
//    
//    [query whereKey:@"bObjectInA" matchesQuery:querySub];
//    
//    [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
//        
//    }];

    return nil;
}


@end
