//
//  JFavoriteViewController.h
//  Zold
//
//  Created by Khatib H. on 7/20/14.
//  
//

#import <UIKit/UIKit.h>
#import "JItemCollectionViewCell.h"

@interface JFavoriteViewController : UIViewController<UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout>
{
    IBOutlet UIView         *mTableViewContainer;
    
}
@property (nonatomic, strong) IBOutlet UICollectionView   *mCollectionView;
@property (nonatomic, strong) NSMutableArray *mArrData;
@end
