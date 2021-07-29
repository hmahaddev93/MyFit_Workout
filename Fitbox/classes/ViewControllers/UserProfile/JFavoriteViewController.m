//
//  JFavoriteViewController.m
//  Zold
//
//  Created by Khatib H. on 7/20/14.
//  
//

#import "JFavoriteViewController.h"
#import "SVPullToRefresh.h"
#import "JSingleViewController.h"


@interface JFavoriteViewController ()
{
    BOOL isLoading;
}

@end

@implementation JFavoriteViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [_mCollectionView registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:@"FooterView"];
    [_mCollectionView registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"HeaderView"];
    self.mArrData = [[NSMutableArray alloc] init];
    isLoading = false;
    
    __block JFavoriteViewController *weakController = self;
    [_mCollectionView addPullToRefreshWithActionHandler:^{
        [weakController insertRowAtTop];
    }];
    
    [_mCollectionView addInfiniteScrollingWithActionHandler:^{
        [weakController insertRowAtBottom];
    }];
    
    [self loadData:nil];
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
//-(void)updateShoppingCartBadge
//{
//    if ([[Engine gShoppingCart] count]>0) {
//        self.navigationItem.rightBarButtonItem.badgeValue = [NSString stringWithFormat:@"%d", (int)[[Engine gShoppingCart] count]];
//        self.navigationItem.rightBarButtonItem.badgeBGColor = [UIColor redColor];
//        self.navigationItem.rightBarButtonItem.badgeTextColor = [UIColor whiteColor];
//        self.navigationItem.rightBarButtonItem.badge.layer.masksToBounds = true;
//        self.navigationItem.rightBarButtonItem.badge.layer.cornerRadius =  self.navigationItem.rightBarButtonItem.badge.frame.size.width / 2.0;
//        //        self.navigationItem.rightBarButtonItem.b
//    }
//    else
//    {
//        self.navigationItem.rightBarButtonItem.badgeValue = @"";
//        self.navigationItem.rightBarButtonItem.badgeBGColor = [UIColor clearColor];
//    }
//}

-(void)dealloc
{
//    [[NSNotificationCenter defaultCenter] removeObserver:self name:SHOPPING_CART_NOTIFICATION object:nil];
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [_mCollectionView reloadData];
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


-(IBAction)onTouchBtnBack:(id)sender
{
    [self.navigationController popViewControllerAnimated:true];
}

-(void)loadData:(JItem*)lastObject
{
    
    isLoading = true;

    [APIClient getFavoriteItems:lastObject success:^(NSMutableArray *items) {
        isLoading = false;
        [_mCollectionView.pullToRefreshView stopAnimating];
        [_mCollectionView.infiniteScrollingView stopAnimating];
        if (items && [items count]>0) {
            if (!lastObject) {
                [self.mArrData removeAllObjects];
            }
            
            [self.mArrData addObjectsFromArray:items];
        }
        [self.mCollectionView reloadData];
    } failure:^(NSString *errorMessage) {
        isLoading = false;
        [_mCollectionView.pullToRefreshView stopAnimating];
        [_mCollectionView.infiniteScrollingView stopAnimating];
        [self.mCollectionView reloadData];
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
                
                mLabel.text = @"No Favorite Items.";
                mLabel.textAlignment = NSTextAlignmentCenter;
                mLabel.textColor = [UIColor blackColor];
                mLabel.numberOfLines = 0;
                mLabel.font =  [UIFont fontWithName:FONT_NAME_AAUX_PROBOLD size:14];
                [mView addSubview:mLabel];
            }
        }
        return mView;
    }
    return nil;
}


@end
