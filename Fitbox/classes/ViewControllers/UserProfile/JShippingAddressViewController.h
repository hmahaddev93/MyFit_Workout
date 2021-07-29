//
//  JShippingAddressViewController.h
//  Fitbox
//
//  Created by Khatib H. on 11/11/15.
//  
//

#import <UIKit/UIKit.h>
#import "StateSelectorView.h"

@protocol JShippingAddressViewControllerDelegate

@optional;
-(void) JShippingAddressViewControllerAddressChosen:(JAddressInfo*)address;
-(void) JShippingAddressViewControllerCancel;
@end

@interface JShippingAddressViewController : UIViewController<StateSelectorViewDelegate, UITextFieldDelegate>

@property (nonatomic, retain) IBOutlet UIScrollView *mScrollView;

@property (nonatomic, retain) IBOutlet UIView *mViewShipPopup;
@property (nonatomic, retain) IBOutlet UIView *mViewShipPopupContent;

@property (nonatomic, retain) IBOutlet UITextField *mTxtShipFirstName;
@property (nonatomic, retain) IBOutlet UITextField *mTxtShipLastName;
@property (nonatomic, retain) IBOutlet UITextField *mTxtShipAddress;
@property (nonatomic, retain) IBOutlet UITextField *mTxtShipAddressExtra;
@property (nonatomic, retain) IBOutlet UITextField *mTxtShipCity;
@property (nonatomic, retain) IBOutlet UITextField *mTxtShipState;
@property (nonatomic, retain) IBOutlet UITextField *mTxtShipZipCode;
@property (nonatomic, retain) IBOutlet UITextField *mTxtShipPhone;

@property (nonatomic, retain) JAddressInfo *mAddress;

@property (nonatomic, assign) id<JShippingAddressViewControllerDelegate> delegate;
@end
