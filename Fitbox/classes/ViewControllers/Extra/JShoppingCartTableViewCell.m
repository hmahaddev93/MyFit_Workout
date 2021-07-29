//
//  JShoppingCartTableViewCell.m
//  Fitbox
//
//  Created by Khatib H. on 11/12/15.
//  
//

#import "JShoppingCartTableViewCell.h"
#import "JAmazonS3ClientManager.h"

@implementation JShoppingCartTableViewCell

@synthesize delegate;

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)initCellWithOrder:(JOrder *)order
{
    _order = order;
    
    self.mImgView.image=nil;
    
    JItem *info = order.itemObject;
    
    if([info.photos count]>0)
    {
        [self.mImgView setImageWithURL:[[JAmazonS3ClientManager defaultManager] cdnUrlForItemPhoto:[info.photos objectAtIndex:0]]];
    }
    else if(info.video)
    {
        [self.mImgView setImageWithURL:[[JAmazonS3ClientManager defaultManager] cdnUrlForItemVideoThumb:info.video]];
    }
    
    self.mLblTitle.text=info.item_name;
    _mLblPrice.text=[NSString stringWithFormat:@"$%.2f",order.itemCost];
    if ([order.itemObject hasTopBottom]) {
        _mLblSize.text=[NSString stringWithFormat:@"Size: TOP - %@, BOTTOM - %@", order.itemSizeTop, order.itemSizeBottom];
    }
    else if([order.itemObject hasTop])
    {
        _mLblSize.text=[NSString stringWithFormat:@"Size: TOP - %@", order.itemSizeTop];
    }
    else if([order.itemObject hasBottom])
    {
        _mLblSize.text=[NSString stringWithFormat:@"Size: BOTTOM - %@", order.itemSizeBottom];
    }
    _mLblShippingArrival.text = [NSString stringWithFormat:@"Estimated Arrival: %@", info.shippingPeriod];
    _mLblAvailableRegion.text = [NSString stringWithFormat:@"Availability: %@", @"USA"];
}

-(IBAction)onTouchBtnRemove:(id)sender
{
    if ([(id)delegate respondsToSelector:@selector(JShoppingCartTableViewCellRemoveOrder:)]) {
        [delegate JShoppingCartTableViewCellRemoveOrder:_order];
    }
}

@end
