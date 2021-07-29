//
//  JCustomTextField.m
//  Fitbox
//
//  Created by Khatib H. on 2/25/16.
//  
//

#import "JCustomTextField.h"

@implementation JCustomTextField

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

// placeholder position
- (CGRect)textRectForBounds:(CGRect)bounds {
    return CGRectInset(bounds, 5, 5);
}

// text position
- (CGRect)editingRectForBounds:(CGRect)bounds {
    return CGRectInset(bounds, 5, 5);
}

@end
