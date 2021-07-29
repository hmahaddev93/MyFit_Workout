//
//  JCDatePicker.m
//  TwinPoint
//
//  Created by Khatib H. on 3/1/15.
//  
//

#import "JDatePicker.h"

@implementation JDatePicker
@synthesize delegate;
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.mDatePicker.timeZone = [NSTimeZone localTimeZone];
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


- (IBAction)actionCancel
{
    if ([(id)delegate respondsToSelector:@selector(JDatePickerCancel)]) {
        [delegate JDatePickerCancel];
    }
}

- (IBAction)actionDone
{
    
    if ( [ ( id ) delegate respondsToSelector : @selector(JDatePickerDone:)])
    {
        [delegate JDatePickerDone:[self.mDatePicker date]];
    }
}
@end
