//
//  JNewsViewController.m
//  Zold
//
//  Created by Khatib H. on 8/22/14.
//  
//

#import "JNewsViewController.h"
#import "JAmazonS3ClientManager.h"
#import "JExtraWebViewViewController.h"

@interface JNewsViewController ()
{
    IBOutlet NSLayoutConstraint *constraintTitleHeight;
    float fontSize;
}

@end

@implementation JNewsViewController

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
    fontSize = 15;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self initView];
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    
    // Pass the selected object to the new view controller.
    if ([segue.identifier isEqualToString:@"showExtraWebView"]) {
        JExtraWebViewViewController *mView = segue.destinationViewController;
        mView.mFileName = self.mCInfo.desc;
        mView.mTitle = self.mCInfo.item_name;
        mView.contentSourceType = @"content";
    }

}

#pragma mark - Touch Event

-(IBAction)onTouchBtnBack:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)initView
{
    mLblTitle.text=self.mCInfo.item_name;
    mLblTitle.numberOfLines = 0;
    CGSize sz1 = [mLblTitle sizeThatFits:CGSizeMake(mLblTitle.frame.size.width, 100000)];
    constraintTitleHeight.constant = sz1.height + 10;
    
    _mPerson = self.mCInfo.user;
    
    if (_mPerson) {
        [self initAuthorInfo];
    }
    else
    {
        //Should'tfallhere
//        [JPerson loadPersonWithWithID:[_mCInfo objectForKey:kItemUserID] completionBlock:^(PFObject *object) {
//            if (object) {
//                _mPerson = object;
//                [self initAuthorInfo];
//            }
//        }];
    }
    
    
    [mScrollViewImage.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    
    if(self.mCInfo.photos && [self.mCInfo.photos count]>0)
    {
        [mScrollViewImage setContentSize:CGSizeMake(mScrollViewImage.frame.size.width*[self.mCInfo.photos count], mScrollViewImage.frame.size.height)];
        mPgControl.numberOfPages=[self.mCInfo.photos count];
        for (int i=0; i<[self.mCInfo.photos count]; i++)
        {
            UIImageView *mImgView=[[UIImageView alloc] initWithFrame:CGRectMake(i*mScrollViewImage.frame.size.width, 0, mScrollViewImage.frame.size.width, mScrollViewImage.frame.size.height) ];
            [mImgView setImageWithURL:[[JAmazonS3ClientManager defaultManager] cdnUrlForItemPhoto:[self.mCInfo.photos objectAtIndex:i]]];
            mImgView.contentMode=UIViewContentModeScaleAspectFill;
            mImgView.layer.masksToBounds=YES;
            [mScrollViewImage addSubview:mImgView];
        }
    }
    else
    {
        mPgControl.numberOfPages=0;
    }
    
    [self initArticleInfo];
    
}
-(void)initArticleInfo
{
    
    NSString *html = self.mCInfo.desc;
    
    NSError *err = nil;
    //    mTxtContent.font = [UIFont fontWithName:FONT_NAME_AAUX_PROREGULAR size:18];
    //    NSMutableString *htmlString = [html mutableCopy];
    html = [html stringByAppendingString:[NSString stringWithFormat:@"<style>body{font-family: '%@'; font-size:%fpx;}</style>",
                                          FONT_NAME_AAUX_PRO,
                                          fontSize]];
    
    //    NSDictionary *dict = @{ NSFontAttributeName: [UIFont fontWithName:FONT_NAME_AAUX_PROREGULAR size:20]};
    //    mTxtContent.attributedText = [[NSAttributedString alloc] initWithString:html attributes:@{NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType, NSFontAttributeName: [UIFont fontWithName:FONT_NAME_AAUX_PROREGULAR size:20]}];
    mTxtContent.attributedText = [[NSAttributedString alloc] initWithData: [html dataUsingEncoding:NSUTF16StringEncoding]
                                                                  options: @{ NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType}
                                                       documentAttributes: nil
                                                                    error: &err];
    
    CGSize sz1 = [mTxtContent sizeThatFits:CGSizeMake(mTxtContent.frame.size.width, 100000)];
    mConstraintScrollContentHeight.constant = mTxtContent.frame.origin.y + (sz1.height) + 30;
    
    if(err)
        NSLog(@"Unable to parse label text: %@", err);
    
}
-(void)initAuthorInfo
{
    mLblAuthor.text=[NSString stringWithFormat:@"%@", _mPerson.fullName];
    mImgPhoto.image = nil;
    mImgPhoto.image = [UIImage imageNamed:@"app_icon"];
    [mImgPhoto setImageWithURL:[[JAmazonS3ClientManager defaultManager] cdnUrlForProfilePhotoThumb:_mPerson.profilePhoto]];
}


-(IBAction)onTouchChangePage:(id)sender
{
    [mScrollViewImage setContentOffset:CGPointMake(mScrollViewImage.frame.size.width*mPgControl.currentPage, 0) animated:YES];
}

-(IBAction)onTouchChooseFont:(id)sender
{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Choose Font Size" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    [alertController addAction:[UIAlertAction actionWithTitle:@"Small" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        fontSize = 12.0;
        [self initArticleInfo];
    }]];
    [alertController addAction:[UIAlertAction actionWithTitle:@"Medium" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        fontSize = 15.0;
        [self initArticleInfo];
    }]];
    [alertController addAction:[UIAlertAction actionWithTitle:@"Big" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        fontSize = 18.0;
        [self initArticleInfo];
    }]];
    [alertController addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
    }]];
    [self presentViewController:alertController animated:true completion:^{
        
    }];
}


- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    int mNewPage=scrollView.contentOffset.x/scrollView.frame.size.width;
    if(mPgControl.currentPage!=mNewPage)
    {
        mPgControl.currentPage=scrollView.contentOffset.x/scrollView.frame.size.width;
    }
    NSLog(@"scrollViewDidEndDecelerating: %f",scrollView.contentOffset.x);
}

@end
