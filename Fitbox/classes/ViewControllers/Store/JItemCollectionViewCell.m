//
//  JItemCollectionViewCell.m
//  Zold
//
//  Created by Khatib H. on 8/7/14.
//  
//

#import "JItemCollectionViewCell.h"
#import "JAmazonS3ClientManager.h"

@implementation JItemCollectionViewCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/
-(void)setInfo:(JItem*)info
{
    [self setMCInfo: info];
    self.mLblPriceReg.text=[NSString stringWithFormat:@"Price: $%.2f",[info.listingprice floatValue]];
    self.mLblTitle.text=[info.item_name uppercaseString];
    self.mLblTitle.numberOfLines = 0;
    self.mLblTitle.lineBreakMode = NSLineBreakByWordWrapping;

    self.mImgView.image=nil;
    if([info.photos count]>0)
    {
        [self.mImgView setImageWithURL:[[JAmazonS3ClientManager defaultManager] cdnUrlForItemPhoto:[info.photos objectAtIndex:0]]];
    }
    else if(info.video)
    {
        [self.mImgView setImageWithURL:[[JAmazonS3ClientManager defaultManager] cdnUrlForItemVideoThumb:info.video]];
    }
    self.mLblDescription.text = info.desc;
    self.mLblDescription.numberOfLines = 0;
    self.mLblDescription.lineBreakMode = NSLineBreakByWordWrapping;
}
@end
