//
//  JExtraWebViewViewController.h
//  Zold
//
//  Created by Khatib H. on 9/23/14.
//  
//

#import <UIKit/UIKit.h>

@interface JExtraWebViewViewController : UIViewController
{
    IBOutlet UIWebView *mWebView;
}

//@property (nonatomic) int           whichPage;
@property (nonatomic, strong) NSString *mTitle;
@property (nonatomic, strong) NSString *mFileName;
@property (nonatomic, strong) NSString *contentSourceType;
@end
