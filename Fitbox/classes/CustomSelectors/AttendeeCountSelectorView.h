//
//  ASCPStateSelectorView.h
//  ASCP
//
//  Created by Khatib H. on 11/4/15.
//  
//

#import <UIKit/UIKit.h>

@protocol AttendeeCountSelectorViewDelegate

@optional;
- (void)AttendeeCountSelectorViewDone: (NSInteger)attendeeCount;
- (void)AttendeeCountSelectorViewCancel;

@end

@interface AttendeeCountSelectorView : UIView<UIPickerViewDataSource, UIPickerViewDelegate>

@property (nonatomic, assign) id<AttendeeCountSelectorViewDelegate> delegate;
@property (nonatomic, weak) IBOutlet UIPickerView *pickerView;
@property (nonatomic) NSInteger selectedIndex;

@end
