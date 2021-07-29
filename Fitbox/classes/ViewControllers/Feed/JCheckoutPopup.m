//
//  JCheckoutPopup.m
//  Fitbox
//
//  Created by Khatib H. on 11/11/15.
//  
//

#import "JCheckoutPopup.h"

@implementation JCheckoutPopup
@synthesize delegate;
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
-(void)initCheckoutPopup
{
    if (!self.mCreditCardInfo) {
        self.mLblPayment.text = @"enter here";
        self.mLblPayment.textColor = MAIN_COLOR_GRAY;
    }
    else
    {
        self.mLblPayment.text = [self.mCreditCardInfo creditCardInfoAbbreviation];
        self.mLblPayment.textColor = [UIColor blackColor];
    }
    
    NSString *itemSizeString;
    if([self.mOrderInfo.itemObject hasTop] && self.mOrderInfo.itemSizeTop)
    {
        itemSizeString = [NSString stringWithFormat:@"TOP - %@", self.mOrderInfo.itemSizeTop];
    }
    
    if([self.mOrderInfo.itemObject hasBottom] && self.mOrderInfo.itemSizeBottom)
    {
        if(itemSizeString)
        {
            itemSizeString = [NSString stringWithFormat:@"%@, BOTTOM - %@", itemSizeString, self.mOrderInfo.itemSizeBottom];
        }
        else
        {
            itemSizeString = [NSString stringWithFormat:@"BOTTOM - %@", self.mOrderInfo.itemSizeBottom];
        }
    }
    
    if (itemSizeString) {
        self.mLblSize.text = itemSizeString;
    }
    else
    {
        self.mLblSize.text = @"enter here";
    }
    
    if (([self.mOrderInfo.itemObject hasTop] && !self.mOrderInfo.itemSizeTop) || ([self.mOrderInfo.itemObject hasBottom] && !self.mOrderInfo.itemSizeBottom)) {
        self.mLblSize.textColor = MAIN_COLOR_GRAY;
    }
    else
    {
        self.mLblSize.textColor = [UIColor blackColor];
    }
    
    if (!self.mAddressInfo) {
        self.mLblAddress.text = @"enter here";
        self.mLblAddress.textColor = MAIN_COLOR_GRAY;
    }
    else
    {
        self.mLblAddress.text = [NSString stringWithFormat:@"%@ %@", self.mAddressInfo.shipFirstName, self.mAddressInfo.shipLastName];
        self.mLblAddress.textColor = [UIColor blackColor];
    }
    
    self.mLblShippingMethod.text = [NSString stringWithFormat:@"%@ (%@)", self.mItem.shippingPeriod, self.mItem.shippingOption];
    self.mLblTotal.text = [NSString stringWithFormat:@"$%.2f", [self.mItem.listingprice floatValue]];
    
}

-(IBAction)onTouchBtnSize:(id)sender
{
    if ([(id)delegate respondsToSelector: @selector(JCheckoutPopupSelectSize)])
    {
        [delegate JCheckoutPopupSelectSize];
    }
}
-(IBAction)onTouchBtnShipTo:(id)sender
{
    if ([(id)delegate respondsToSelector: @selector(JCheckoutPopuSelectShippingAddress)])
    {
        [delegate JCheckoutPopuSelectShippingAddress];
    }
    
}
-(IBAction)onTouchBtnPayment:(id)sender
{
    if ([(id)delegate respondsToSelector: @selector(JCheckoutPopupSelectPayment)])
    {
        [delegate JCheckoutPopupSelectPayment];
    }
    
}
-(IBAction)onTouchBtnAddToCart:(id)sender
{
    if ([(id)delegate respondsToSelector: @selector(JCheckoutPopupAddToCart)])
    {
        [delegate JCheckoutPopupAddToCart];
    }
}

-(IBAction)onTouchBtnCancel:(id)sender
{
    if ([(id)delegate respondsToSelector: @selector(JCheckoutPopupCancel)])
    {
        [delegate JCheckoutPopupCancel];
    }
}

@end
