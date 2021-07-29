//
//  JSizeSelectorViewController.h
//  Fitbox
//
//  Created by Khatib H. on 11/11/15.
//  
//

#import <UIKit/UIKit.h>

@protocol JSizeSelectorViewControllerDelegate

@optional;
-(void) JSizeSelectorViewControllerSizeSelected:(NSString*)sizeTop sizeBottom:(NSString*)sizeBottom;
-(void) JSizeSelectorViewControllerCancel;
@end

@interface JSizeSelectorViewController : UIViewController
@property (nonatomic, assign) id<JSizeSelectorViewControllerDelegate> delegate;

@property (nonatomic, strong) NSString *mSizeTops;
@property (nonatomic, strong) NSString *mSizeBottom;

@property (nonatomic, strong) NSString *mPageType;

@end
