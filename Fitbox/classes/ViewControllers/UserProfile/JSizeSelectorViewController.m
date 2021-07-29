//
//  JSizeSelectorViewController.m
//  Fitbox
//
//  Created by Khatib H. on 11/11/15.
//  
//

#import "JSizeSelectorViewController.h"

@interface JSizeSelectorViewController ()
{
    IBOutlet UIView *mViewTopsPanel;
    IBOutlet UIView *mViewBottomsPanel;
    
    IBOutlet UIView *mViewOverlayTops;
    IBOutlet UIView *mViewOverlayBottoms;
    
    IBOutlet UIButton *mBtnTops;
    IBOutlet UIButton *mBtnBottoms;
    
    NSArray *mArrSizeInfo;
}


@end

@implementation JSizeSelectorViewController
@synthesize delegate;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
//    mArrSizeInfo = @[@"AVERAGE", @"XS", @"S", @"M", @"L", @"XL",
//                     @"SIZE", @"0 - 2", @"4 - 6", @"8 - 10", @"12 - 14", @"16 - 18",
//                     @"BUST", @"]
    [self initButtons];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)stylizeButtons:(UIButton*)button
{
    button.layer.borderColor = MAIN_COLOR_PINK.CGColor;
    button.layer.borderWidth = 1;
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

-(IBAction)onTouchBtnBack:(id)sender
{
    if ([(id)delegate respondsToSelector:@selector(JSizeSelectorViewControllerCancel)]) {
        [delegate JSizeSelectorViewControllerCancel];
    }
    else
    {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

-(void)initButtons
{
    mViewOverlayTops.hidden = true;
    mViewOverlayBottoms.hidden = true;
    if ([_mPageType isEqualToString:SIZE_PAGE_BOTTOMS]) {
        mViewOverlayTops.hidden = false;
    }
    else if([_mPageType isEqualToString:SIZE_PAGE_TOPS])
    {
        mViewOverlayBottoms.hidden = false;
    }
    
    if (_mSizeTops) {
        [mBtnTops setTitle:_mSizeTops forState:UIControlStateNormal];
    }
    if (_mSizeBottom) {
        [mBtnBottoms setTitle:_mSizeBottom forState:UIControlStateNormal];
    }
    
    [self stylizeButtons:mBtnTops];
    [self stylizeButtons:mBtnBottoms];
}

-(IBAction)onTouchBtnTopBottom:(id)sender
{
    UIButton *btn = (UIButton*)sender;
    NSString *currentSize;
    if (btn.tag < 200)
    {//When it's top
        currentSize = _mSizeTops;
    }
    else
    {
        currentSize = _mSizeBottom;
    }
    
    NSString *nextSize = [self getNextSize:currentSize];
    
    if (btn.tag < 200)
    {//When it's top
        _mSizeTops = nextSize;
        [mBtnTops setTitle:_mSizeTops forState:UIControlStateNormal];
    }
    else
    {
        _mSizeBottom = nextSize;
        [mBtnBottoms setTitle:_mSizeBottom forState:UIControlStateNormal];
    }
}

-(NSString*)getNextSize:(NSString*)curSize
{
    NSUInteger curIndex = [[Engine gSizeList] indexOfObject:curSize];
    if (curIndex == NSNotFound) {
        return [[Engine gSizeList] objectAtIndex:0];
    }
    if (curIndex == [[Engine gSizeList] count] - 1) {
        return [[Engine gSizeList] firstObject];
    }
    
    return [[Engine gSizeList] objectAtIndex:curIndex + 1];
}

-(IBAction)onTouchBtnDone:(id)sender
{
    if ([(id)delegate respondsToSelector:@selector(JSizeSelectorViewControllerSizeSelected:sizeBottom:)]) {
        [delegate JSizeSelectorViewControllerSizeSelected:_mSizeTops sizeBottom:_mSizeBottom];
    }
    if ([_mPageType isEqualToString:SIZE_PAGE_MY_SIZE]) {
        [self.navigationController popViewControllerAnimated:true];
    }
}
@end
