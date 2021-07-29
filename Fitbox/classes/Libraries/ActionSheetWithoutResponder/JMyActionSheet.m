//
//  JMyActionSheet.m
//  ThisIsWhere
//
//  Created by Khatib H. on 5/28/14.
//  Copyright (c) 2014 Khatib Mobile. All rights reserved.
//

#import "JMyActionSheet.h"

@implementation JMyActionSheet
-(BOOL)canBecomeFirstResponder
{
    return NO;
}
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

@end
