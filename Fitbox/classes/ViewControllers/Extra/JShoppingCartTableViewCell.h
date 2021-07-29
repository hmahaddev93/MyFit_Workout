//
//  JShoppingCartTableViewCell.h
//  Fitbox
//
//  Created by Khatib H. on 11/12/15.
//  
//

#import <UIKit/UIKit.h>

@protocol JShoppingCartTableViewCellDelegate

@optional

-(void)JShoppingCartTableViewCellRemoveOrder:(JOrder*)order;

@end

@interface JShoppingCartTableViewCell : UITableViewCell

@property (nonatomic, weak) IBOutlet UIImageView *mImgView;
@property (nonatomic, weak) IBOutlet UILabel *mLblTitle;
@property (nonatomic, weak) IBOutlet UILabel *mLblSize;
//@property (nonatomic, weak) IBOutlet UILabel *mLblUser;
@property (nonatomic, weak) IBOutlet UILabel *mLblShippingArrival;
@property (nonatomic, weak) IBOutlet UILabel *mLblAvailableRegion;
@property (nonatomic, weak) IBOutlet UILabel *mLblPrice;

-(void)initCellWithOrder:(JOrder*)order;

@property (nonatomic, strong) JOrder *order;
@property (nonatomic, assign) id<JShoppingCartTableViewCellDelegate> delegate;
@end

