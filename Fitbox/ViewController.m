//
//  ViewController.m
//  Fitbox
//
//  Created by Khatib H. on 11/8/15.
//  
//

#import "ViewController.h"

@interface ViewController ()
{
    IBOutlet UIScrollView *mScrollView;
    NSTimer *timer;
    int currentPage;
}

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    [JUser loadFromNSDefaults];
    [JUser loadTokenFromNSDefaults];
    
    
    if ([[JUser me] isAuthorized])
    {
        [JUtils showLoadingIndicator:self.navigationController.view message:@"Loading User Info..."];
        [APIClient getCurrentUserInfo:^(JUser *user) {
            [JUtils hideLoadingIndicator:self.navigationController.view];
            [JUser actionAfterLogin];
            [self performSegueWithIdentifier:@"showTabController" sender:nil];
        } failure:^(NSString *errorMessage) {
            [JUtils hideLoadingIndicator:self.navigationController.view];
            [self.navigationController.view makeToast:@"Failed to load user information. Login again"];
            [[JUser me] logout];
//            [JUser actionAfterLogin];
//            [self performSegueWithIdentifier:@"showTabController" sender:nil];
        }];
    }
    
    [self.navigationController setNavigationBarHidden:true animated:false];
    
    for (int i=0; i<5; i++) {
        UIImageView *mImgView = [[UIImageView alloc] initWithFrame:CGRectMake(i*SCREEN_WIDTH, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
        mImgView.image = [UIImage imageNamed:[NSString stringWithFormat:@"bgLoginBackground%d", (i%4+1)]];
        mImgView.contentMode = UIViewContentModeScaleAspectFill;
        [mScrollView addSubview:mImgView];
    }
    currentPage = 0;
    [mScrollView setContentSize:CGSizeMake(SCREEN_WIDTH*4, SCREEN_HEIGHT)];
    mScrollView.userInteractionEnabled = false;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onBackMain:) name:@"BACK_TO_LOGIN_VIEW" object:nil];
    
    timer = [NSTimer scheduledTimerWithTimeInterval:3 target:self selector:@selector(scrollTheSlide:) userInfo:nil repeats:true];
}

-(void)scrollTheSlide:(id)sender
{
    currentPage = currentPage + 1;
    [mScrollView setContentOffset:CGPointMake(currentPage * SCREEN_WIDTH, 0) animated:true];
    if (currentPage == 4)
    {
        [self performSelector:@selector(resetScrollView:) withObject:nil afterDelay:1.5];
    }
}
-(void)resetScrollView:(id)sender
{
    currentPage = 0;
    mScrollView.contentOffset = CGPointMake(0, 0);
}
-(void)onBackMain:(id)sender
{
    [self.navigationController popToRootViewControllerAnimated:true];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear: animated];
}

-(IBAction)onTouchBtnSkip:(id)sender
{
    [self performSegueWithIdentifier:@"showTabController" sender:nil];
}

@end
