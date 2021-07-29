//
//  JFitlifeViewController.h
//  Fitbox
//
//  Created by Khatib H. on 11/8/15.
//  
//

#import <UIKit/UIKit.h>
#import "JFitlifeTableViewCell.h"

@interface JFitlifeViewController : UIViewController<UISearchBarDelegate, UITableViewDataSource, UITableViewDelegate>



@property (nonatomic, weak) IBOutlet UITableView *mTView;
@property (nonatomic, strong) NSMutableArray *mArrData;
@property (nonatomic, weak) IBOutlet UISearchBar *mSearchBar;

@property (nonatomic, retain) NSMutableArray* mArrDataAll;
@property (nonatomic, retain) NSMutableArray* mArrDataFiltered;

@property (nonatomic, strong) IBOutlet UIImageView          *mImgProfilePhotoTopRight;

@end
