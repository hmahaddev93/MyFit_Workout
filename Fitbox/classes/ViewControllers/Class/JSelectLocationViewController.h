//
//  JSelectLocationViewController.h
//  Fitbox
//
//  Created by Khatib H. on 2/20/16.
//  
//

#import <UIKit/UIKit.h>

@protocol JSelectLocationViewControllerDelegate

@optional;
-(void) JSelectLocationViewControllerDelegateLocationSelected: (double)lat lng:(double)lng;
-(void) JSelectLocationViewControllerDelegateCancel;
@end

@interface JSelectLocationViewController : UIViewController

@property (nonatomic, retain) NSNumber *mLat;
@property (nonatomic, retain) NSNumber *mLng;

@property (nonatomic) BOOL isSelectLocation;


@property (nonatomic, assign) id<JSelectLocationViewControllerDelegate>   delegate;
@end
