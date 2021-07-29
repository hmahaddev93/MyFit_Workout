//
//  JMessageHistoryTableViewCell.m
//  Fitbox
//
//  Created by Khatib H. on 2/23/16.
//  
//

#import "JMessageHistoryTableViewCell.h"
#import "JAmazonS3ClientManager.h"
#import "CustomBadge.h"

@implementation JMessageHistoryTableViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)setInfo:(JMessageHistory *)info
{
    _mMessageHistory = info;
    
    [self initView];
}

-(void)initView
{
    
    int unReadCount = 0;
    if ([_mMessageHistory.listingPoster._id isEqualToString:[JUser me]._id]) {
        _mPerson = _mMessageHistory.user;// [[Engine gPersonsDict] objectForKey:[_mMessageHistory objectForKey:kUserId]];
        unReadCount = [_mMessageHistory.unreadCountPoster intValue];
    }
    else
    {
        _mPerson = _mMessageHistory.listingPoster;// [[Engine gPersonsDict] objectForKey:[_mMessageHistory objectForKey:kChatHistoryListingPosterID]];
        unReadCount = [_mMessageHistory.unreadCountUser intValue];
    }
    
    if (unReadCount < 1) {
        mViewBadge.hidden = true;
    }
    else
    {
        mViewBadge.hidden = false;
        mLblBadge.text = [NSString stringWithFormat:@"%d", unReadCount];
    }
    
    mImgUserPhoto.image = nil;
    mImgUserPhoto.image = [UIImage imageNamed:@"iconPerson56"];
    if (_mPerson) {
        mLblUsername.text = _mPerson.username;
        if (_mPerson.profilePhoto && ![_mPerson.profilePhoto isEqualToString:@""]) {
            [mImgUserPhoto setImageWithURL:[[JAmazonS3ClientManager defaultManager] cdnUrlForProfilePhoto: _mPerson.profilePhoto]];
        }
    }
    
    mLblLastMessage.text = _mMessageHistory.lastMessage;
    mLblMessageDate.text = [JUtils dateTimeStringFromTimestap:[_mMessageHistory.updatedAt intValue]];
}
@end
