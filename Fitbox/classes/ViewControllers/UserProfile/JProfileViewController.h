//
//  JProfileViewController.h
//  Zold
//
//  Created by Khatib H. on 7/05/14.
//  Copyright (c) 2014 Khatib Mobile. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JSizeSelectorViewController.h"

@interface JProfileViewController : UIViewController<UIActionSheetDelegate,  UIAlertViewDelegate, UITableViewDataSource, UITableViewDelegate, JSizeSelectorViewControllerDelegate>
{
    IBOutlet UITableView *mTView;
}

@property (nonatomic, strong) IBOutlet UIImageView          *mImgProfilePhotoTopRight;

@end
