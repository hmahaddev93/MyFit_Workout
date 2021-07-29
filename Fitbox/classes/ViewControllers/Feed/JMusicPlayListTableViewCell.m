//
//  JMusicPlayListTableViewCell.m
//  Fitbox
//
//  Created by Khatib H. on 11/23/15.
//  
//

#import "JMusicPlayListTableViewCell.h"

@implementation JMusicPlayListTableViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
-(void)setInfo:(JSoundCloudPlayListInfo*)info
{
    _mLblTitle.text = info.playlistTitle;
    _mLblDesc.text = info.playlistDescription;

    [_mImgThumb cancelImageRequestOperation];
    _mImgThumb.image = [UIImage imageNamed:@"app_icon"];
    if (info.playlistImage && ![info.playlistImage isEqualToString:@""]) {
        [_mImgThumb setImageWithURL:[NSURL URLWithString:info.playlistImage]];
    }
    
    CGSize sz;
    sz=[_mLblTitle.text boundingRectWithSize:CGSizeMake(100000, 20) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:_mLblTitle.font} context:nil].size;
    if (sz.width > _mLblTitle.frame.size.width) {
        sz.width = _mLblTitle.frame.size.width;
    }
//    _mViewRedBar.frame = CGRectMake(_mViewRedBar.frame.origin.x, _mViewRedBar.frame.origin.y, sz.width, _mViewRedBar.frame.size.height);
    _mConstraintRedWidth.constant = sz.width;
}
@end
