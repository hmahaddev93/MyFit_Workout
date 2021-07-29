//
//  JContactTableViewCell.m
//  Zold
//
//  Created by Khatib H. on 7/10/14.
//  
//

#import "JContactTableViewCell.h"

@implementation JContactTableViewCell
@synthesize delegate;

- (void)awakeFromNib {
    // Initialization code
//    self.mSwitch=[[UICustomSwitch alloc] initWithFrame:CGRectMake(235, 18, 41, 21)];
//    [self.contentView addSubview:self.mSwitch];
//    [self.mSwitch addTarget:self action:@selector(onSwitchChanged:) forControlEvents:UIControlEventValueChanged];
//    self.mSwitch set
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
//    [self.mBtnChecked setSelected:selected];
}

-(IBAction)onSwitchChanged:(id)sender
{
//    if ([(id)delegate respondsToSelector: @selector(switchChanged:switchValue:)])
//    {
//        [delegate switchChanged:self.mInfo switchValue:self.mSwitch.on];
//    }
}
@end
