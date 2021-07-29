//
//  JFilterCircleButton.m
//  Zold
//
//  Created by Khatib H. on 13/10/14.
//  
//

#import "JFilterCircleButton.h"

@implementation JFilterCircleButton

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.layer.borderWidth=1;
        self.layer.borderColor=[[UIColor blackColor] CGColor];

        [self setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [self setBackgroundColor:[UIColor whiteColor]];
        [self.titleLabel setFont:[UIFont fontWithName:@"helvetica" size:13.0]];
        self.layer.cornerRadius=frame.size.width/2;
        self.layer.masksToBounds=YES;
        self.contentHorizontalAlignment=UIControlContentHorizontalAlignmentCenter;
    }
    return self;
}

-(void)setSelected:(BOOL)selected
{
    [super setSelected:selected];
    if(selected)
    {
        self.layer.borderColor=[[UIColor colorWithRed:239.0/255.0 green:148.0/255.0 blue:18.0/255.0 alpha:1] CGColor];
    }
    else
    {
        self.layer.borderColor=[[UIColor blackColor] CGColor];
    }
}
@end
