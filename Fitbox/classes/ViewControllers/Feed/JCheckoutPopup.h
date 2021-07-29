//
//  JCheckoutPopup.h
//  Fitbox
//
//  Created by Khatib H. on 11/11/15.
//  
//

#import <UIKit/UIKit.h>

@protocol JCheckoutPopupDelegate

@optional;
-(void) JCheckoutPopupSelectSize;
-(void) JCheckoutPopuSelectShippingAddress;
-(void) JCheckoutPopupSelectPayment;
-(void) JCheckoutPopupAddToCart;
-(void) JCheckoutPopupCancel;
@end

@interface JCheckoutPopup : UIView

@property (nonatomic, assign) id<JCheckoutPopupDelegate> delegate;
@property (nonatomic, weak) IBOutlet UILabel *mLblSize;
@property (nonatomic, weak) IBOutlet UILabel *mLblAddress;
@property (nonatomic, weak) IBOutlet UILabel *mLblPayment;
@property (nonatomic, weak) IBOutlet UILabel *mLblShippingMethod;
@property (nonatomic, weak) IBOutlet UILabel *mLblTotal;

@property (nonatomic, strong) JAddressInfo *mAddressInfo;
@property (nonatomic, strong) JCreditCardInfo *mCreditCardInfo;
@property (nonatomic, strong) JOrder *mOrderInfo;
@property (nonatomic, strong) JItem *mItem;

-(void)initCheckoutPopup;
@end
