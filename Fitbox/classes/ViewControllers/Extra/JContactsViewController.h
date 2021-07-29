//
//  JContactsViewController.h
//  Zold
//
//  Created by Khatib H. on 7/10/14.
//  
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
//@class MBProgressHUD;
#import "JContactTableViewCell.h"

@interface JContactsViewController : UIViewController<MFMessageComposeViewControllerDelegate, JContactTableViewCellDelegate, UITableViewDataSource, UITableViewDelegate, MFMailComposeViewControllerDelegate>

@property (nonatomic, retain) NSMutableArray* mArrData;
@property (nonatomic, retain) NSMutableArray* mArrDataDeselected;


@property (nonatomic, retain) NSMutableArray* mContactsArr;
@property (nonatomic, retain) NSMutableArray* mContactsSelected;
@property (nonatomic, retain) IBOutlet UITableView* mTView;

@property (nonatomic, retain) NSMutableArray          *sectionArray;

@end
