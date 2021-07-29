//
//  ASCPStateSelectorView.m
//  ASCP
//
//  Created by Khatib H. on 11/4/15.
//  
//

#import "StateSelectorView.h"

@implementation StateSelectorView
@synthesize delegate ;

-(void)awakeFromNib
{
    [super awakeFromNib];
    
    
    self.arrStates = @[@"Alabama", 	@"Montana",
                       @"Alaska", 	 	@"Nebraska",
                       @"Arizona", 		@"Nevada",
                       @"Arkansas", 	 	@"New Hampshire",
                       @"California",  	@"New Jersey",
                       @"Colorado", 	 	@"New Mexico",
                       @"Connecticut", 		@"New York",
                       @"Delaware", 	 	@"North Carolina",
                       @"Florida",	 	@"North Dakota",
                       @"Georgia",  	@"Ohio",
                       @"Hawaii", 	 	@"Oklahoma",
                       @"Idaho", 	 	@"Oregon",
                       @"Illinois",  	@"Pennsylvania",
                       @"Indiana",  	@"Rhode Island",
                       @"Iowa", 	 	@"South Carolina",
                       @"Kansas", 	 	@"South Dakota",
                       @"Kentucky", 	 	@"Tennessee",
                       @"Louisiana", 	@"Texas",
                       @"Maine",  	@"Utah",
                       @"Maryland",  	@"Vermont",
                       @"Massachusetts",  	@"Virginia",
                       @"Michigan", 	@"Washington", 	@"WA",
                       @"Minnesota",  	@"West Virginia",
                       @"Mississippi",  	@"Wisconsin",
                       @"Missouri", 		@"Wyoming"];
    self.arrStatesAbbreviation = @[	@"AL", 		@"MT",
                                    @"AK",  	@"NE",
                                    @"AZ",  	@"NV",
                                    @"AR", 	 	@"NH",
                                    @"CA", 		@"NJ",
                                    @"CO", 	 	@"NM",
                                    @"CT", 		@"NY",
                                    @"DE",  	@"NC",
                                    @"FL",      @"ND",
                                    @"GA", 		@"OH",
                                    @"HI", 		@"OK",
                                    @"ID", 	 	@"OR",
                                    @"IL", 	 	@"PA",
                                    @"IN", 	@"RI",
                                    @"IA", 		@"SC",
                                    @"KS", 	 	@"SD",
                                    @"KY", 		@"TN",
                                    @"LA", 	@"TX",
                                    @"ME",  	@"UT",
                                    @"MD", 	 	@"VT",
                                    @"MA", 		@"VA",
                                    @"MI", 		@"WA",
                                    @"MN", 	 	@"WV",
                                    @"MS", 		@"WI",
                                    @"MO", @"WY"];
    self.strStateName = [self.arrStatesAbbreviation firstObject];
    
}
-(id)initWithCoder:(NSCoder *)aDecoder
{
    if(self = [super initWithCoder:aDecoder])
    {
        
    }
    return self;
}
//-(instancetype)initWithFrame:(CGRect)frame
//{
//    if (self = [super initWithFrame:frame]) {
//        
//        
//    }
//    return self;
//}

#pragma mark - UIPickerView

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return self.arrStates.count;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    //    [self._pickerView rel]
    if(self.arrStates.count>row)
    {
        return [self.arrStates objectAtIndex:row];
    }
    else
        return @"";
}

-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    self.strStateName = [self.arrStatesAbbreviation objectAtIndex:row];
}


- (IBAction)actionDone: (id)sender {
    if ([(id)delegate respondsToSelector:@selector(StateSelectorViewDone:)]) {
        [delegate StateSelectorViewDone: self.strStateName];
    }
}

- (IBAction)actionCancel: (id)sender {
    if ([(id)delegate respondsToSelector:@selector(StateSelectorViewCancel)]) {
        [delegate StateSelectorViewCancel];
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
