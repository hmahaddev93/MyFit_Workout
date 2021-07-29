//
//  JShoppingCartViewController.h
//  Fitbox
//
//  Created by Khatib H. on 11/12/15.
//  
//

#import <UIKit/UIKit.h>
#import <PassKit/PassKit.h>
#import "Stripe.h"
#import "JShoppingCartTableViewCell.h"

@interface JShoppingCartViewController : UIViewController<UITableViewDataSource, UITableViewDelegate, JShoppingCartTableViewCellDelegate>

@property (nonatomic, weak) IBOutlet UITableView *mTView;
@property (nonatomic, strong) NSMutableArray *mArrData;

//Summary View
@property (nonatomic, weak) IBOutlet UIView *mViewSummary;
@property (nonatomic, weak) IBOutlet UILabel *mLblTotalPrice;
@property (nonatomic, weak) IBOutlet UILabel *mLblShippingPrice;


@end
