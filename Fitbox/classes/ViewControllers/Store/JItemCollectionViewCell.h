//
//  JItemCollectionViewCell.h
//  Zold
//
//  Created by Khatib H. on 8/7/14.
//  
//

#import <UIKit/UIKit.h>

@interface JItemCollectionViewCell : UICollectionViewCell

@property (nonatomic, retain) IBOutlet UILabel *mLblTitle;
@property (nonatomic, retain) IBOutlet UILabel *mLblDescription;

@property (nonatomic, retain) IBOutlet UILabel *mLblPriceReg;
@property (nonatomic, retain) IBOutlet UILabel *mLblPriceVIP;

@property (nonatomic, retain) IBOutlet UIImageView *mImgView;

@property (nonatomic, retain) JItem                      *mCInfo;

-(void)setInfo:(JItem*)info;
@end
