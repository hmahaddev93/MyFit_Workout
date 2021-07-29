//
//  JMyTabBarViewController.m
//  Fitbox
//
//  Created by Khatib H. on 11/10/15.
//  
//

#import "JMyTabBarViewController.h"

@interface JMyTabBarViewController ()

@end

@implementation JMyTabBarViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.delegate = self;
//    CGRect tabRect = self.tabBar.frame;
//    NSLog(@"TAB BAR RECT: %f %f %f %f", tabRect.origin.x, tabRect.origin.y, tabRect.size.width, tabRect.size.height);
//    [self.tabBar setBounds:CGRectMake(0, 0, SCREEN_WIDTH, 28)];
//    tabRect = self.tabBar.frame;
//    NSLog(@"TAB BAR RECT: %f %f %f %f", tabRect.origin.x, tabRect.origin.y, tabRect.size.width, tabRect.size.height);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
//    [self.tabBar setFrame:CGRectMake(0, SCREEN_HEIGHT - 28, SCREEN_WIDTH, 49)];
//    NSLog(@"TAB BAR RECT: %f %f %f %f", tabRect.origin.x, tabRect.origin.y, tabRect.size.width, tabRect.size.height);
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
-(void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    [self.tabBar setFrame:CGRectMake(0, SCREEN_HEIGHT - 38, SCREEN_WIDTH, 49)];
//    [self.tabBar setBounds:CGRectMake(0, 0, SCREEN_WIDTH, 35)];
}
-(BOOL)tabBarController:(UITabBarController *)tabBarController shouldSelectViewController:(UIViewController *)viewController
{
    if([self.viewControllers indexOfObject:viewController] == 0)
    {//If discover page clicked.
        if (self.selectedViewController == viewController) {
            NSLog(@"Bang - Discover page clicked again. Then we will show the first item.");
            [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_DISCOVER_CLICKED_AGAIN object:nil];
        }
    }
    if (![[JUser me] isAuthorized]) {
        if ([self.viewControllers indexOfObject:viewController]==3)//Profile
        {
            [Engine showAlertViewForLogin];
            return false;
        }
    }
    return true;
}

@end
