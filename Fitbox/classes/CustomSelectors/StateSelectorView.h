//
//  ASCPStateSelectorView.h
//  ASCP
//
//  Created by Khatib H. on 11/4/15.
//  
//

#import <UIKit/UIKit.h>

@protocol StateSelectorViewDelegate

@optional;
- (void)StateSelectorViewDone: (NSString *)strStateName;
- (void)StateSelectorViewCancel;

@end

@interface StateSelectorView : UIView<UIPickerViewDataSource, UIPickerViewDelegate>

@property (nonatomic, assign) id<StateSelectorViewDelegate> delegate;
@property (nonatomic, copy) NSString *strStateName;
@property (nonatomic, copy) NSArray *arrStates;
@property (nonatomic, copy) NSArray *arrStatesAbbreviation;
@property (nonatomic, weak) IBOutlet UIPickerView *pickerView;

@end
