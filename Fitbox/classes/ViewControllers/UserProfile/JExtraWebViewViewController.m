//
//  JExtraWebViewViewController.m
//  Zold
//
//  Created by Khatib H. on 9/23/14.
//  
//

#import "JExtraWebViewViewController.h"

@interface JExtraWebViewViewController ()

@end

@implementation JExtraWebViewViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    mWebView.scrollView.decelerationRate=UIScrollViewDecelerationRateNormal;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self initView];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear: animated];

    [self.navigationItem setTitle:self.mTitle];
}

-(void)initView
{
    mWebView.scrollView.contentOffset=CGPointMake(0, 0);
    mWebView.scalesPageToFit = true;
    if ([self.contentSourceType isEqualToString:@"web"])
    {
        [mWebView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:_mFileName]]];
    }
    else if([self.contentSourceType isEqualToString:@"file"])
    {
        NSString *htmlFile = [[NSBundle mainBundle] pathForResource:self.mFileName ofType:@"html"];
        NSString* htmlString = [NSString stringWithContentsOfFile:htmlFile encoding:NSUTF8StringEncoding error:nil];
        [mWebView loadHTMLString:htmlString baseURL:nil];
    }
    else if([self.contentSourceType isEqualToString:@"content"])
    {
//        NSString *htmlFile = [[NSBundle mainBundle] pathForResource:self.mFileName ofType:@"html"];
//        NSString* htmlString = [NSString stringWithContentsOfFile:htmlFile encoding:NSUTF8StringEncoding error:nil];
        [mWebView loadHTMLString:self.mFileName baseURL:nil];
    }
    
}

#pragma mark - Touch Event

-(IBAction)onTouchBtnBack:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

@end
