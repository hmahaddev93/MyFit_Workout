//
//  JCDatePicker.h
//  TwinPoint
//
//  Created by Khatib H. on 3/1/15.
//  
//

#import <UIKit/UIKit.h>


@protocol JDatePickerDelegate

@optional;
- ( void ) JDatePickerCancel ;
- ( void ) JDatePickerDone:(NSDate*)date;
@end

@interface JDatePicker : UIView
{
}

@property ( nonatomic, retain ) IBOutlet UIDatePicker*   mDatePicker;
@property (nonatomic, assign) id<JDatePickerDelegate> delegate;

@end
