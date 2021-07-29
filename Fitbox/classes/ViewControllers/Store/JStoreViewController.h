//
//  JStoreViewController.h
//  Fitbox
//
//  Created by Khatib H. on 11/10/15.
//  
//

#import <UIKit/UIKit.h>
#import "JItemCollectionViewCell.h"

@interface JStoreViewController : UIViewController<UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout>
{
    BOOL isLoading;
}


@property (nonatomic, weak) IBOutlet UICollectionView *mCollectionView;
@property (nonatomic, strong) NSMutableArray *mArrData;

@property (nonatomic, strong) IBOutlet UIImageView          *mImgProfilePhotoTopRight;


@end
