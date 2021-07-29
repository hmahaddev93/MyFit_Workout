//
//  ASCPStateSelectorView.m
//  ASCP
//
//  Created by Khatib H. on 11/4/15.
//  
//

#import "AttendeeCountSelectorView.h"

@implementation AttendeeCountSelectorView
@synthesize delegate ;

-(void)awakeFromNib
{
    self.selectedIndex = 0;
    [super awakeFromNib];
}
-(id)initWithCoder:(NSCoder *)aDecoder
{
    self.selectedIndex = 0;
    if(self = [super initWithCoder:aDecoder])
    {
        
    }
    return self;
}

#pragma mark - UIPickerView

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return 101;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    if (row == 0) {
        return @"Unlimited";
    }

    return [NSString stringWithFormat:@"%d", (int)row];
}

-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    self.selectedIndex = row;
}


- (IBAction)actionDone: (id)sender {
    if ([(id)delegate respondsToSelector:@selector(AttendeeCountSelectorViewDone:)]) {
        [delegate AttendeeCountSelectorViewDone: self.selectedIndex];
    }
}

- (IBAction)actionCancel: (id)sender {
    if ([(id)delegate respondsToSelector:@selector(AttendeeCountSelectorViewCancel)]) {
        [delegate AttendeeCountSelectorViewCancel];
    }
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
