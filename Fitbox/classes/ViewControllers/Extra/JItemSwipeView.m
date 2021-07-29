//
//  JItemSwipeView.m
//  Zold
//
//  Created by Khatib H. on 8/14/14.
//  
//

#import "JItemSwipeView.h"
#import "JAmazonS3ClientManager.h"
#import <AVFoundation/AVFoundation.h>
#import <MapKit/MapKit.h>

@implementation JItemSwipeView
{

    UIView *mViewVideo;
}

@synthesize delegate;
@synthesize avPlayer;
@synthesize mBtnPlay;
//- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
//{
//    self = [super initWithFrame:CGRectMake(0, 0, 282, 314) options:nibBundleOrNil.;
//    if (self) {
//        // Custom initialization
//    }
//    return self;
//}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
                       item:(NSObject *)item
                      options:(MDCSwipeToChooseViewOptions *)options {
    self = [super initWithFrame:frame options:options];
    if (self) {
        self.layer.masksToBounds=YES;
        self.backgroundColor=[UIColor whiteColor];
        if ([item isKindOfClass:[JItem class]]) {
            self.mItem = (JItem*)item;
        }
        else if([item isKindOfClass:[JListing class]])
        {
            self.mListing = (JListing*)item;
        }

        if (self.mItem) {
            if ([self.mItem.itemType isEqualToString:ITEM_TYPE_NEWS]) {
                [self initItemNews:frame item:self.mItem];
            }
            else if ([self.mItem.itemType isEqualToString:ITEM_TYPE_VIDEO])
            {
                [self initItemVideo:frame item:self.mItem];
            }
            else if ([self.mItem.itemType isEqualToString:ITEM_TYPE_PHOTO])
            {
                [self initItemPhoto:frame item:self.mItem];
            }
            else if ([self.mItem.itemType isEqualToString:ITEM_TYPE_PRODUCT])
            {
                [self initItemProduct:frame item:self.mItem];
            }
            else if ([self.mItem.itemType isEqualToString:ITEM_TYPE_PLAYLIST])
            {
                [self initItemPlayList:frame item:self.mItem];
            }
        }
        else if(self.mListing)
        {
            [self initListing:frame item:self.mListing];
        }
    }
    return self;
}

-(void)initItemNews:(CGRect)frame item:(JItem*)item
{
    UIFont *font = [UIFont fontWithName:FONT_NAME_AAUX_PROBOLD size:16.0];
    CGSize sz;
//    sz=[item.item_name boundingRectWithSize:CGSizeMake(100000, 20) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:font} context:nil].size;
//    if (sz.width > (frame.size.width - 30)) {
//        sz.width = frame.size.width - 30;
//    }
    

    
    UILabel *mLblTitle=[[UILabel alloc] init];
    mLblTitle.font=font;
    mLblTitle.text=item.item_name;
    mLblTitle.numberOfLines = 0;
    mLblTitle.textColor = [UIColor blackColor];
    sz = [mLblTitle sizeThatFits:CGSizeMake(frame.size.width - 30, 10000)];
    
    mLblTitle.frame = CGRectMake(15, 30, sz.width, sz.height);

    
    
    UIView *mViewLblContainer =[[UILabel alloc] initWithFrame:CGRectMake(mLblTitle.frame.origin.x - 5, mLblTitle.frame.origin.y, mLblTitle.frame.size.width + 10, mLblTitle.frame.size.height + 5)];
    mViewLblContainer.backgroundColor = [UIColor colorWithWhite:1 alpha:0.8];
    [self addSubview:mViewLblContainer];
    [self addSubview:mLblTitle];

    UIView *mPinkView = [[UIView alloc] initWithFrame:CGRectMake(15, 20 , sz.width, 3)];
    mPinkView.backgroundColor = MAIN_COLOR_PINK;
    [self addSubview:mPinkView];
    
    UILabel *mLblDesc=[[UILabel alloc] initWithFrame:CGRectMake(15, frame.size.height - 60, frame.size.width - 30, 60)];
    mLblDesc.font=[UIFont fontWithName:FONT_NAME_AAUX_PROREGULAR size:12.0];
    
    NSError *err;
    mLblDesc.attributedText = [[NSAttributedString alloc] initWithData: [item.desc dataUsingEncoding:NSUTF16StringEncoding]
                                                                  options: @{ NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType, NSFontAttributeName: mLblDesc.font}
                                                       documentAttributes: nil
                                                                    error: &err];
    if (err) {
        mLblDesc.text=item.desc;
    }
    mLblDesc.textColor = [UIColor blackColor];
    mLblDesc.numberOfLines = 2;
    mLblDesc.lineBreakMode = NSLineBreakByClipping;
    mLblDesc.layer.masksToBounds = true;
    [self addSubview:mLblDesc];
    
    
    self.mPhotoView=[[UIImageView alloc] initWithFrame:CGRectMake(0, 60, frame.size.width, frame.size.height-120)];
    self.mPhotoView.contentMode=UIViewContentModeScaleAspectFill;
    self.mPhotoView.layer.masksToBounds=YES;
    [self addSubview:self.mPhotoView];
    [self sendSubviewToBack:self.mPhotoView];

    
    UITapGestureRecognizer *mTapGesture=[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTouchBtnInfo:)];
    mTapGesture.numberOfTouchesRequired=1;
    self.mPhotoView.userInteractionEnabled=YES;
    [self.mPhotoView addGestureRecognizer:mTapGesture];
    
    self.mPhotoView.image=nil;
    if ([item.photos count]>0) {
        [self.mPhotoView setImageWithURL:[[JAmazonS3ClientManager defaultManager] cdnUrlForItemPhoto:[item.photos objectAtIndex:0]]];
//        [self.mPhotoView setImageWithURL:[NSURL URLWithString:[[item objectForKey:kItemPhotos] objectAtIndex:0]]];
    }
}

-(void)initItemPhoto:(CGRect)frame item:(JItem*)item
{
    
    self.mPhotoView=[[UIImageView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
    self.mPhotoView.contentMode=UIViewContentModeScaleAspectFill;
    self.mPhotoView.layer.masksToBounds=YES;
    [self addSubview:self.mPhotoView];
    [self sendSubviewToBack:self.mPhotoView];
    
    self.mPhotoView.image=nil;
    self.mPhotoView.backgroundColor = [UIColor colorWithRed:0.92 green:0.92 blue:0.92 alpha:1];
    if (item.photos) {
        NSArray *arr = item.photos;
        if ([arr count]) {
            [self.mPhotoView setImageWithURL:[[JAmazonS3ClientManager defaultManager] cdnUrlForItemPhoto:[arr objectAtIndex:0]]];
        }
    }
}

-(void)initItemPlayList:(CGRect)frame item:(JItem*)item
{
    
    self.mPhotoView=[[UIImageView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
    self.mPhotoView.contentMode=UIViewContentModeScaleAspectFill;
    self.mPhotoView.layer.masksToBounds=YES;
    [self addSubview:self.mPhotoView];
    [self sendSubviewToBack:self.mPhotoView];
    
    self.mPhotoView.image=nil;
    self.mPhotoView.backgroundColor = [UIColor colorWithRed:0.92 green:0.92 blue:0.92 alpha:1];
    if (item.photos) {
        NSArray *arr = item.photos;
        if ([arr count]) {
            [self.mPhotoView setImageWithURL:[[JAmazonS3ClientManager defaultManager] cdnUrlForItemPhoto:[arr objectAtIndex:0]]];
        }
    }
    
    mBtnPlay = [[UIButton alloc] initWithFrame:CGRectMake((frame.size.width - 70)/2.0, (frame.size.height - 70)/2.0, 70, 70)];
    [mBtnPlay setImage:[UIImage imageNamed:@"btnIconMusicBigRed"] forState:UIControlStateNormal];
    [self addSubview:mBtnPlay];
    [self bringSubviewToFront:mBtnPlay];
    //    mBtnPlay.backgroundColor = [UIColor redColor];
    [mBtnPlay addTarget:self action:@selector(onTouchBtnInfo:) forControlEvents:UIControlEventTouchUpInside];
    
    UITapGestureRecognizer *mTapGesture=[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTouchBtnInfo:)];
    mTapGesture.numberOfTouchesRequired=1;
    self.mPhotoView.userInteractionEnabled=YES;
    [self.mPhotoView addGestureRecognizer:mTapGesture];
    
}

-(void)initItemVideo:(CGRect)frame item:(JItem*)item
{
    
    self.mPhotoView=[[UIImageView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
    self.mPhotoView.contentMode=UIViewContentModeScaleAspectFill;
    self.mPhotoView.layer.masksToBounds=YES;
    [self addSubview:self.mPhotoView];
    [self sendSubviewToBack:self.mPhotoView];
    
    
    self.mPhotoView.image=nil;
    self.mPhotoView.backgroundColor = [UIColor colorWithRed:0.92 green:0.92 blue:0.92 alpha:1];
    if (item.photos) {
        NSArray *arr = item.photos;
        if ([arr count]) {
            [self.mPhotoView setImageWithURL:[[JAmazonS3ClientManager defaultManager] cdnUrlForItemVideoThumb:[arr objectAtIndex:0]]];
        }
    }
    
    
    mViewVideo=[[UIView alloc] initWithFrame:self.bounds];
    mViewVideo.layer.masksToBounds = true;
    [self addSubview:mViewVideo];

    mBtnPlay = [[UIButton alloc] initWithFrame:CGRectMake((frame.size.width - 60)/2.0, (frame.size.height - 60)/2.0, 60, 60)];
    [mBtnPlay setImage:[UIImage imageNamed:@"btnIconBigMediaPlay"] forState:UIControlStateNormal];
    [self addSubview:mBtnPlay];
    [self bringSubviewToFront:mBtnPlay];
//    mBtnPlay.backgroundColor = [UIColor redColor];
    [mBtnPlay addTarget:self action:@selector(onTouchBtnPlay:) forControlEvents:UIControlEventTouchUpInside];
    mViewVideo.hidden = true;
}



-(void)initListing:(CGRect)frame item:(JListing*)item
{
    
    
    UIImageView *imgWorkoutIcon =[[UIImageView alloc] initWithFrame:CGRectMake(frame.size.width - 15 - 25, 15, 25, 25)];
    imgWorkoutIcon.contentMode=UIViewContentModeScaleAspectFill;
    imgWorkoutIcon.image = [UIImage imageNamed:@"btnIconMedListing"];
    [self addSubview:imgWorkoutIcon];

    
    UIFont *font = [UIFont fontWithName:FONT_NAME_AAUX_PROBOLD size:16.0];
    UIFont *fontSmallBold = [UIFont fontWithName:FONT_NAME_AAUX_PROBOLD size:12.0];
    UIFont *fontRegular = [UIFont fontWithName:FONT_NAME_AAUX_PROREGULAR size:12.0];
    
    UIView *mPinkView = [[UIView alloc] initWithFrame:CGRectMake(15, 20 , 100, 3)];
    mPinkView.backgroundColor = MAIN_COLOR_PINK;
    [self addSubview:mPinkView];
    
    UILabel *mLblTitle = [[UILabel alloc] initWithFrame:CGRectMake(15, 25, 180, 30)];
    mLblTitle.font = font;
    mLblTitle.text = @"EVENT INVITE";//item.classType;
    mLblTitle.textColor = [UIColor blackColor];
    [self addSubview:mLblTitle];

    
    self.mPhotoView=[[UIImageView alloc] initWithFrame:CGRectMake(15, 60, 107, 107)];
    self.mPhotoView.contentMode=UIViewContentModeScaleAspectFill;
    self.mPhotoView.layer.masksToBounds=YES;
    [self addSubview:self.mPhotoView];
    [self sendSubviewToBack:self.mPhotoView];
    
    UITapGestureRecognizer *mTapGesture=[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTouchBtnInfo:)];
    mTapGesture.numberOfTouchesRequired=1;
    self.mPhotoView.userInteractionEnabled=YES;
    [self.mPhotoView addGestureRecognizer:mTapGesture];
    
    self.mPhotoView.image=nil;
    [self.mPhotoView setImageWithURL:[[JAmazonS3ClientManager defaultManager] cdnUrlForItemPhoto:item.photo]];
    
    
    CGSize sz;
//    sz=[item.classType boundingRectWithSize:CGSizeMake(100000, 20) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:font} context:nil].size;
//    if (sz.width > (frame.size.width - 30)) {
//        sz.width = frame.size.width - 30;
//    }

    //Class Name
    UILabel *mLblClassName=[[UILabel alloc] initWithFrame:CGRectMake(135, 60, frame.size.width - 135 - 10, 10)];
    mLblClassName.font=fontSmallBold;
    mLblClassName.text=item.classType;
    mLblClassName.textColor = [UIColor blackColor];
    mLblClassName.numberOfLines=0;
    sz = [mLblClassName sizeThatFits:CGSizeMake(frame.size.width - 135 - 10, 1000000)];
    // TODO : Here we don't do anything on class size yet.
    mLblClassName.frame=CGRectMake(mLblClassName.frame.origin.x, mLblClassName.frame.origin.y, mLblClassName.frame.size.width, sz.height);
    [self addSubview:mLblClassName];

    // Event Date
    UILabel *mLblEventDate=[[UILabel alloc] initWithFrame:CGRectMake(135, mLblClassName.frame.origin.y + mLblClassName.frame.size.height + 3, frame.size.width - 135 - 10, 20)];
    mLblEventDate.font=[UIFont fontWithName:FONT_NAME_AAUX_PROREGULAR size:10.0];
    if(item.event_date && [item.event_date integerValue] > 0)
    {
        mLblEventDate.text=[NSString stringWithFormat:@"Time: %@", [JUtils dateTimeStringWithFormatFromTimestap: [item.event_date intValue] format:@"EEE MMM dd, hh:mm a"]];
    }
    else{
        mLblEventDate.text=[NSString stringWithFormat:@"Time: Unspecified"];
    }
    
    
    mLblEventDate.textColor = [UIColor blackColor];
    [self addSubview:mLblEventDate];

    // Place Name
    UIImageView *mImgPin=[[UIImageView alloc] initWithFrame:CGRectMake(135, mLblEventDate.frame.origin.y + mLblEventDate.frame.size.height + 3, 10, 15)];
    mImgPin.contentMode=UIViewContentModeScaleAspectFit;
    mImgPin.image = [UIImage imageNamed:@"iconLocationPin"];
    [self addSubview:mImgPin];
    // Event Date
    UILabel *mLblPlaceName=[[UILabel alloc] initWithFrame:CGRectMake(135, mImgPin.frame.origin.y, frame.size.width - 135 - 15, 15)];
    mLblPlaceName.font=fontRegular;
    mLblPlaceName.text=[NSString stringWithFormat:@"     %@", [item.placeName uppercaseString]];
    mLblPlaceName.textColor = [UIColor redColor];
    mLblPlaceName.numberOfLines=0;
    sz = [mLblPlaceName sizeThatFits:CGSizeMake(mLblPlaceName.frame.size.width, 1000000)];
//    mLblPlaceName.backgroundColor = [UIColor greenColor];
    mLblPlaceName.frame=CGRectMake(mLblPlaceName.frame.origin.x, mLblPlaceName.frame.origin.y, mLblPlaceName.frame.size.width, sz.height);
    [self addSubview:mLblPlaceName];
    
    
    UIButton *btnButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnButton setTitle:@"" forState:UIControlStateNormal];
    btnButton.frame = CGRectMake(mImgPin.frame.origin.y, mImgPin.frame.origin.y, mImgPin.frame.size.width + mLblPlaceName.frame.size.width, sz.height);
    [btnButton addTarget:self action:@selector(onTouchBtnMAP:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:btnButton];
    
    
    
    
    // RSVP
    UIButton *mBtnRSVP=[UIButton buttonWithType:UIButtonTypeCustom];
    [mBtnRSVP setFrame:CGRectMake((frame.size.width - 200) / 2, frame.size.height - 35, 200, 25)];
    [mBtnRSVP setTitle:@"RSVP" forState:UIControlStateNormal];
    [mBtnRSVP setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [mBtnRSVP.titleLabel setFont:fontRegular];
    [mBtnRSVP setBackgroundColor:MAIN_COLOR_PINK];
    [mBtnRSVP addTarget:self action:@selector(onTouchBtnRSVP:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:mBtnRSVP];
    
    // Attendees
    UIView *viewAttendees = [[UIView alloc] initWithFrame:CGRectMake(15, frame.size.height - 140, frame.size.width - 30, 90)];
    
    MKMapView *mapView = [[MKMapView alloc] initWithFrame:viewAttendees.bounds];
    
    [mapView setRegion:MKCoordinateRegionMake(CLLocationCoordinate2DMake([[item.lnglat objectAtIndex:1] doubleValue], [[item.lnglat objectAtIndex:0] doubleValue]), MKCoordinateSpanMake(0.002, 0.002))];
    
    MKPointAnnotation *annotation = [[MKPointAnnotation alloc] init];
    [annotation setCoordinate:CLLocationCoordinate2DMake([[item.lnglat objectAtIndex:1] doubleValue], [[item.lnglat objectAtIndex:0] doubleValue])];
    [mapView addAnnotation:annotation];
    [viewAttendees addSubview:mapView];
    
    UITapGestureRecognizer *tapMap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTouchBtnMAP:)];
    tapMap.numberOfTapsRequired = 1;
    [viewAttendees addGestureRecognizer:tapMap];
    [self addSubview:viewAttendees];
    
    
    mLblPrice=[[UILabel alloc] initWithFrame:CGRectMake(0, viewAttendees.frame.origin.y - 30, frame.size.width - 15, 20)];
    mLblPrice.textAlignment = NSTextAlignmentRight;
    mLblPrice.font=fontSmallBold;
    if ([item.price integerValue] == 0) {
        mLblPrice.text=@"FREE";
    }
    else{
        mLblPrice.text=[NSString stringWithFormat:@"Price: %.2f", [item.price floatValue]];
    }
    mLblPrice.textColor = [UIColor blackColor];
    [self addSubview:mLblPrice];
    
    
    float descHeight = mLblPrice.frame.origin.y - self.mPhotoView.frame.origin.y - self.mPhotoView.frame.size.height - 20;
    if (descHeight > 15) {
        UILabel *mLblDesc=[[UILabel alloc] initWithFrame:CGRectMake(15, self.mPhotoView.frame.origin.y + self.mPhotoView.frame.size.height + 10, frame.size.width - 30, descHeight)];
        mLblDesc.font=[UIFont fontWithName:FONT_NAME_AAUX_PROREGULAR size:12.0];
        
        NSError *err;
        mLblDesc.attributedText = [[NSAttributedString alloc] initWithData: [item.comments dataUsingEncoding:NSUTF16StringEncoding]
                                                                   options: @{ NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType, NSFontAttributeName: mLblDesc.font}
                                                        documentAttributes: nil
                                                                     error: &err];
        if (err) {
            mLblDesc.text=item.comments;
        }
        mLblDesc.textColor = [UIColor blackColor];
        mLblDesc.numberOfLines = 0;
        mLblDesc.lineBreakMode = NSLineBreakByClipping;
        mLblDesc.layer.masksToBounds = true;
        
        CGSize sz = [mLblDesc sizeThatFits:CGSizeMake(frame.size.width - 30, 1000000)];
        if (sz.height < descHeight) {
            mLblDesc.frame=CGRectMake(mLblDesc.frame.origin.x, mLblDesc.frame.origin.y, mLblDesc.frame.size.width, sz.height);
        }
        [self addSubview:mLblDesc];
    }
}


-(void)updateListingAttendees:(JListing*)item
{
    [scrollViewAttendees.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    for (int i=0; i<[item.attendees count]; i++) {
        UIImageView *imgView =[[UIImageView alloc] initWithFrame:CGRectMake(48 * i, 0, 37, 37)];
        imgView.contentMode=UIViewContentModeScaleAspectFill;
//        imgView.backgroundColor = [UIColor colorWithRed:0.5 green:0.5 blue:0.5 alpha:0.8];
        imgView.layer.masksToBounds=YES;
        imgView.layer.cornerRadius = 18;
        imgView.image=nil;
        JUser *user = [item.attendees objectAtIndex:i];
        [imgView setImageWithURL:[[JAmazonS3ClientManager defaultManager] cdnUrlForProfilePhotoThumb:user.profilePhoto] placeholderImage:[UIImage imageNamed:@"iconPerson56"]];
        
        [scrollViewAttendees addSubview:imgView];
    }
    [scrollViewAttendees setContentSize:CGSizeMake(48*[item.attendees count], 37)];
}
-(void)onTouchBtnPlay:(id)sender
{
    if (!avPlayer) {
        mBtnPlay.hidden=true;
        [[AVAudioSession sharedInstance]
         setCategory: AVAudioSessionCategoryPlayback
         error: nil];
        
        mViewVideo.hidden=NO;
        
        [mViewVideo.layer addSublayer: self.mPhotoView.layer];
        
        AVURLAsset* asset;
        if([JUtils videoDownloaded:self.mItem.video])
        {
            asset = [AVURLAsset URLAssetWithURL: [NSURL fileURLWithPath:[JUtils getTemporaryURL:self.mItem.video]] options:nil];
        }
        else
        {
            asset = [AVURLAsset URLAssetWithURL: [[JAmazonS3ClientManager defaultManager] cdnUrlForItemVideo:self.mItem.video] options:nil];
        }
        
        
        AVPlayerItem* item = [AVPlayerItem playerItemWithAsset:asset];
        avPlayer = [AVPlayer playerWithPlayerItem:item];
        avPlayer.actionAtItemEnd = AVPlayerActionAtItemEndNone;
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(playerItemDidReachEnd:)
                                                     name:AVPlayerItemDidPlayToEndTimeNotification
                                                   object:[avPlayer currentItem]];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(playerItemPlaybackStalled:)
                                                     name:AVPlayerItemPlaybackStalledNotification
                                                   object:[avPlayer currentItem]];
        
        AVPlayerLayer* lay = [AVPlayerLayer playerLayerWithPlayer: avPlayer];
        
        lay.frame = mViewVideo.bounds;
        lay.videoGravity = AVLayerVideoGravityResizeAspectFill;
        [mViewVideo.layer addSublayer:lay];
          [avPlayer play];
    }
    else
    {
        mBtnPlay.hidden=true;
        [avPlayer play];
    }
}
-(void)playerItemDidReachEnd:(id)sender
{
    if(avPlayer)
    {
        [avPlayer seekToTime:kCMTimeZero];
        [avPlayer pause];
        mBtnPlay.hidden = false;
        
    }
}

- (void)playerItemPlaybackStalled: (NSNotification *)notification {
    if(avPlayer)
    {
        if(mBtnPlay.hidden == true)
        {
            [avPlayer play];
        }
    }
}
-(void)initItemProduct:(CGRect)frame item:(JItem*)item
{
    self.mPhotoView=[[UIImageView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height-49)];
    self.mPhotoView.contentMode=UIViewContentModeScaleAspectFill;
    self.mPhotoView.layer.masksToBounds=YES;
    [self addSubview:self.mPhotoView];
    [self sendSubviewToBack:self.mPhotoView];
    
    
    
    mViewBottomContainer=[[UIView alloc] initWithFrame:CGRectMake(0,frame.size.height-49 , frame.size.width, 49)];
    mViewBottomContainer.backgroundColor = MAIN_COLOR_PINK;
    [self addSubview:mViewBottomContainer];
    
    
    
    mLblItemTitle=[[UILabel alloc] initWithFrame:CGRectMake(12, 4, 220, 25)];
    mLblItemTitle.font=[UIFont fontWithName:FONT_NAME_AAUX_PROBOLD size:12];
    mLblItemTitle.text=item.item_name;
    mLblItemTitle.textColor = [UIColor whiteColor];
    [mViewBottomContainer addSubview:mLblItemTitle];
    
    
    mLblPrice=[[UILabel alloc] initWithFrame:CGRectMake(12, 26, 203, 21)];
    mLblPrice.text=[NSString stringWithFormat:@"$ %.2f",[item.listingprice floatValue]];
    mLblPrice.font=[UIFont fontWithName:FONT_NAME_AAUX_PROBOLD size:12];
    mLblPrice.textColor = [UIColor whiteColor];
    [mViewBottomContainer addSubview:mLblPrice];
    
    
    UIButton *mBtnZold=[UIButton buttonWithType:UIButtonTypeCustom];
    mBtnZold.frame=CGRectMake(240, 0, 40, 49);
    [mBtnZold setImage:[UIImage imageNamed:@"btnIconShareWhite"] forState:UIControlStateNormal];
    [mBtnZold addTarget:self action:@selector(onTouchBtnShareInfo:) forControlEvents:UIControlEventTouchUpInside];
    [mViewBottomContainer addSubview:mBtnZold];
    
    
    mBtnInfo=[UIButton buttonWithType:UIButtonTypeCustom];
    mBtnInfo.frame=CGRectMake(240, 6, 40, 40);
    [mBtnInfo setImage:[UIImage imageNamed:@"btnIconInfo"] forState:UIControlStateNormal];
    [mBtnInfo addTarget:self action:@selector(onTouchBtnInfo:) forControlEvents:UIControlEventTouchUpInside];
    
    [self addSubview:mBtnInfo];
    
    UITapGestureRecognizer *mTapGesture=[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTouchBtnInfo:)];
    mTapGesture.numberOfTouchesRequired=1;
    self.mPhotoView.userInteractionEnabled=YES;
    [self.mPhotoView addGestureRecognizer:mTapGesture];
    
    
    
    self.mPhotoView.image=nil;
    if([item.photos count]>0)
    {
        [self.mPhotoView setImageWithURL:[[JAmazonS3ClientManager defaultManager] cdnUrlForItemPhoto:[item.photos objectAtIndex:0]]];
    }
    else if(item.video)
    {
        [self.mPhotoView setImageWithURL:[[JAmazonS3ClientManager defaultManager] cdnUrlForItemVideoThumb:item.video]];
    }
    
}
-(IBAction)onTouchBtnRSVP:(id)sender
{
    if ([(id)delegate respondsToSelector: @selector(onRSVP:swipeView:)])
    {
        [delegate onRSVP: [self mListing] swipeView:self];
    }
}
-(IBAction)onTouchBtnMAP:(id)sender
{
    if ([(id)delegate respondsToSelector: @selector(openMap:)])
    {
        [delegate openMap: [self mListing]];
    }
}
-(IBAction)onTouchBtnInfo:(id)sender
{
    if ([(id)delegate respondsToSelector: @selector(showItemInfo:)])
    {
        [delegate showItemInfo: [self mItem]];
    }
}

-(IBAction)onTouchBtnShareInfo:(id)sender
{
    if ([(id)delegate respondsToSelector: @selector(shareItemInfo:)])
    {
        [delegate shareItemInfo: [self mItem]];
    }
}
-(IBAction)onTouchBtnLike:(id)sender
{
    if(![[JUser me] isAuthorized])
    {
        [Engine showAlertViewForLogin];
        return;
    }
    if(!mBtnLike.selected)
    {
        [mBtnLike setSelected:YES];
    }
    else
    {
        [mBtnLike setSelected:NO];
    }
    
    [APIClient likeItem:self.mItem isLike:mBtnLike.selected success:^(JItem *item) {
        
    } failure:^(NSString *errorMessage) {
        
    }];
    
    [self mItem].likesCount=[NSNumber  numberWithInt:[[self mItem].likesCount  intValue]];
    [mBtnLike setTitle:[NSString stringWithFormat:@"%@",[self mItem].likesCount] forState:UIControlStateNormal];
    [mBtnLike setTitle:[NSString stringWithFormat:@"%@",[self mItem].likesCount] forState:UIControlStateSelected];
}



/*
 
 
 -(void)initListing:(CGRect)frame item:(JListing*)item
 {
 
 
 UIImageView *imgWorkoutIcon =[[UIImageView alloc] initWithFrame:CGRectMake(frame.size.width - 15 - 25, 10, 25, 25)];
 imgWorkoutIcon.contentMode=UIViewContentModeScaleAspectFill;
 imgWorkoutIcon.image = [UIImage imageNamed:@"btnIconMedListing"];
 [self addSubview:imgWorkoutIcon];
 
 UIImageView *imgViewProfilePhoto =[[UIImageView alloc] initWithFrame:CGRectMake(imgWorkoutIcon.frame.origin.x, imgWorkoutIcon.frame.origin.y + imgWorkoutIcon.frame.size.height - 2, 25, 25)];
 imgViewProfilePhoto.contentMode=UIViewContentModeScaleAspectFill;
 imgViewProfilePhoto.layer.masksToBounds=YES;
 imgViewProfilePhoto.layer.cornerRadius = 12;
 imgViewProfilePhoto.image=nil;
 if (item.user && item.user.profilePhoto && ![item.user.profilePhoto isEqualToString:@""]) {
 [imgViewProfilePhoto setImageWithURL:[[JAmazonS3ClientManager defaultManager] cdnUrlForProfilePhotoThumb:item.user.profilePhoto] placeholderImage:[UIImage imageNamed:@"iconPerson56"]];
 }
 else{
 imgViewProfilePhoto.image = [UIImage imageNamed:@"iconPerson56"];
 }
 
 [self addSubview:imgViewProfilePhoto];
 
 UIFont *font = [UIFont fontWithName:FONT_NAME_AAUX_PROBOLD size:16.0];
 UIFont *fontSmallBold = [UIFont fontWithName:FONT_NAME_AAUX_PROBOLD size:12.0];
 UIFont *fontRegular = [UIFont fontWithName:FONT_NAME_AAUX_PROREGULAR size:12.0];
 
 UIView *mPinkView = [[UIView alloc] initWithFrame:CGRectMake(15, 20 , 100, 3)];
 mPinkView.backgroundColor = MAIN_COLOR_PINK;
 [self addSubview:mPinkView];
 
 UILabel *mLblTitle = [[UILabel alloc] initWithFrame:CGRectMake(15, 25, 180, 30)];
 mLblTitle.font = font;
 mLblTitle.text = @"EVENT INVITE";//item.classType;
 mLblTitle.textColor = [UIColor blackColor];
 [self addSubview:mLblTitle];
 
 
 
 
 
 
 self.mPhotoView=[[UIImageView alloc] initWithFrame:CGRectMake(15, 60, 107, 107)];
 self.mPhotoView.contentMode=UIViewContentModeScaleAspectFill;
 self.mPhotoView.layer.masksToBounds=YES;
 [self addSubview:self.mPhotoView];
 [self sendSubviewToBack:self.mPhotoView];
 
 UITapGestureRecognizer *mTapGesture=[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTouchBtnInfo:)];
 mTapGesture.numberOfTouchesRequired=1;
 self.mPhotoView.userInteractionEnabled=YES;
 [self.mPhotoView addGestureRecognizer:mTapGesture];
 
 self.mPhotoView.image=nil;
 [self.mPhotoView setImageWithURL:[[JAmazonS3ClientManager defaultManager] cdnUrlForItemPhoto:item.photo]];
 
 
 
 CGSize sz;
 //    sz=[item.classType boundingRectWithSize:CGSizeMake(100000, 20) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:font} context:nil].size;
 //    if (sz.width > (frame.size.width - 30)) {
 //        sz.width = frame.size.width - 30;
 //    }
 
 //Class Name
 UILabel *mLblClassName=[[UILabel alloc] initWithFrame:CGRectMake(135, 60, frame.size.width - 135 - 10, 10)];
 mLblClassName.font=fontSmallBold;
 mLblClassName.text=item.classType;
 mLblClassName.textColor = [UIColor blackColor];
 mLblClassName.numberOfLines=0;
 sz = [mLblClassName sizeThatFits:CGSizeMake(frame.size.width - 135 - 10, 1000000)];
 // TODO : Here we don't do anything on class size yet.
 [self addSubview:mLblClassName];
 
 // Event Date
 UILabel *mLblEventDate=[[UILabel alloc] initWithFrame:CGRectMake(135, 72, frame.size.width - 135 - 10, 10)];
 mLblEventDate.font=fontRegular;
 if(item.event_date && [item.event_date integerValue] > 0)
 {
 mLblEventDate.text=[NSString stringWithFormat:@"Time: %@", [JUtils dateTimeStringWithFormatFromTimestap: [item.event_date intValue] format:@"mmm dd, yyyy"]];
 }
 else{
 mLblEventDate.text=[NSString stringWithFormat:@"Time: Unspecified"];
 }
 
 
 mLblEventDate.textColor = [UIColor blackColor];
 [self addSubview:mLblEventDate];
 
 // Place Name
 UIImageView *mImgPin=[[UIImageView alloc] initWithFrame:CGRectMake(135, 84, 17, 17)];
 mImgPin.contentMode=UIViewContentModeScaleAspectFill;
 mImgPin.image = [UIImage imageNamed:@"iconLocationPin"];
 [self addSubview:mImgPin];
 // Event Date
 UILabel *mLblPlaceName=[[UILabel alloc] initWithFrame:CGRectMake(155, 84, frame.size.width - 155 - 15, 15)];
 mLblPlaceName.font=fontRegular;
 mLblPlaceName.text=item.placeName;
 mLblPlaceName.textColor = [UIColor redColor];
 mLblPlaceName.numberOfLines=2;
 sz = [mLblPlaceName sizeThatFits:CGSizeMake(mLblPlaceName.frame.size.width, 1000000)];
 
 mLblPlaceName.frame=CGRectMake(mLblPlaceName.frame.origin.x, mLblPlaceName.frame.origin.y, mLblPlaceName.frame.size.width, sz.height);
 [self addSubview:mLblPlaceName];
 
 
 UIButton *btnButton = [UIButton buttonWithType:UIButtonTypeCustom];
 [btnButton setTitle:@"" forState:UIControlStateNormal];
 btnButton.frame = CGRectMake(mImgPin.frame.origin.y, mImgPin.frame.origin.y, mImgPin.frame.size.width + mLblPlaceName.frame.size.width, sz.height);
 [btnButton addTarget:self action:@selector(onTouchBtnMAP:) forControlEvents:UIControlEventTouchUpInside];
 [self addSubview:btnButton];
 
 MKMapView *mapView = [[MKMapView alloc] initWithFrame:CGRectMake(mLblClassName.frame.origin.x, mLblPlaceName.frame.origin.y + mLblPlaceName.frame.size.height + 5, frame.size.width - 15 - mLblClassName.frame.origin.x, self.mPhotoView.frame.size.height + self.mPhotoView.frame.origin.y - (mLblPlaceName.frame.origin.y + mLblPlaceName.frame.size.height + 5))];
 [mapView setRegion:MKCoordinateRegionMake(CLLocationCoordinate2DMake([[item.lnglat objectAtIndex:1] doubleValue], [[item.lnglat objectAtIndex:0] doubleValue]), MKCoordinateSpanMake(0.01, 0.01))];
 
 MKPointAnnotation *annotation = [[MKPointAnnotation alloc] init];
 [annotation setCoordinate:CLLocationCoordinate2DMake([[item.lnglat objectAtIndex:1] doubleValue], [[item.lnglat objectAtIndex:0] doubleValue])];
 [mapView addAnnotation:annotation];
 [self addSubview:mapView];
 
 
 
 
 
 // RSVP
 UIButton *mBtnRSVP=[UIButton buttonWithType:UIButtonTypeCustom];
 [mBtnRSVP setFrame:CGRectMake((frame.size.width - 200) / 2, frame.size.height - 35, 200, 25)];
 [mBtnRSVP setTitle:@"RSVP" forState:UIControlStateNormal];
 [mBtnRSVP setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
 [mBtnRSVP.titleLabel setFont:fontRegular];
 [mBtnRSVP setBackgroundColor:MAIN_COLOR_PINK];
 [mBtnRSVP addTarget:self action:@selector(onTouchBtnRSVP:) forControlEvents:UIControlEventTouchUpInside];
 [self addSubview:mBtnRSVP];
 
 // Attendees
 UIView *viewAttendees = [[UIView alloc] initWithFrame:CGRectMake(15, frame.size.height - 120, frame.size.width - 30, 70)];
 UIView *viewAttendeesLine1 = [[UIView alloc] initWithFrame:CGRectMake(0, 0, viewAttendees.bounds.size.width, 1)];
 viewAttendeesLine1.backgroundColor = [UIColor darkGrayColor];
 [viewAttendees addSubview:viewAttendeesLine1];
 UIView *viewAttendeesLine2 = [[UIView alloc] initWithFrame:CGRectMake(0, viewAttendees.bounds.size.height - 1, viewAttendees.bounds.size.width, 1)];
 viewAttendeesLine2.backgroundColor = [UIColor darkGrayColor];
 [viewAttendees addSubview:viewAttendeesLine2];
 
 UILabel *mLblAttendees=[[UILabel alloc] initWithFrame:CGRectMake(0, 5, 180, 20)];
 mLblAttendees.font=fontSmallBold;
 mLblAttendees.text=@"Attendees";
 mLblAttendees.textColor = [UIColor blackColor];
 [viewAttendees addSubview:mLblAttendees];
 
 scrollViewAttendees = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 25, viewAttendees.bounds.size.width, 37)];
 [self updateListingAttendees:item];
 //    for (int i=0; i<[item.attendees count]; i++) {
 //        UIImageView *imgView =[[UIImageView alloc] initWithFrame:CGRectMake(48 * i, 0, 37, 37)];
 //        imgView.contentMode=UIViewContentModeScaleAspectFill;
 //        imgView.layer.masksToBounds=YES;
 //        imgView.layer.cornerRadius = 18;
 //        imgView.image=nil;
 //        JUser *user = [item.attendees objectAtIndex:i];
 //        [imgView setImageWithURL:[[JAmazonS3ClientManager defaultManager] cdnUrlForProfilePhotoThumb:user.profilePhoto]];
 //
 //        [scrollViewAttendees addSubview:imgView];
 //
 //    }
 [viewAttendees addSubview:scrollViewAttendees];
 [self addSubview:viewAttendees];
 
 
 mLblPrice=[[UILabel alloc] initWithFrame:CGRectMake(0, viewAttendees.frame.origin.y - 30, frame.size.width - 15, 20)];
 mLblPrice.textAlignment = NSTextAlignmentRight;
 mLblPrice.font=fontSmallBold;
 if ([item.price integerValue] == 0) {
 mLblPrice.text=@"FREE";
 }
 else{
 mLblPrice.text=[NSString stringWithFormat:@"Price: %.2f", [item.price floatValue]];
 }
 mLblPrice.textColor = [UIColor blackColor];
 [self addSubview:mLblPrice];
 
 
 float descHeight = mLblPrice.frame.origin.y - self.mPhotoView.frame.origin.y - self.mPhotoView.frame.size.height - 20;
 if (descHeight > 15) {
 UILabel *mLblDesc=[[UILabel alloc] initWithFrame:CGRectMake(15, self.mPhotoView.frame.origin.y + self.mPhotoView.frame.size.height + 10, frame.size.width - 30, descHeight)];
 mLblDesc.font=[UIFont fontWithName:FONT_NAME_AAUX_PROREGULAR size:12.0];
 
 NSError *err;
 mLblDesc.attributedText = [[NSAttributedString alloc] initWithData: [item.comments dataUsingEncoding:NSUTF16StringEncoding]
 options: @{ NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType, NSFontAttributeName: mLblDesc.font}
 documentAttributes: nil
 error: &err];
 if (err) {
 mLblDesc.text=item.comments;
 }
 mLblDesc.textColor = [UIColor blackColor];
 mLblDesc.numberOfLines = 0;
 mLblDesc.lineBreakMode = NSLineBreakByClipping;
 mLblDesc.layer.masksToBounds = true;
 
 CGSize sz = [mLblDesc sizeThatFits:CGSizeMake(frame.size.width - 30, 1000000)];
 if (sz.height < descHeight) {
 mLblDesc.frame=CGRectMake(mLblDesc.frame.origin.x, mLblDesc.frame.origin.y, mLblDesc.frame.size.width, sz.height);
 }
 [self addSubview:mLblDesc];
 }
 }
 

 */
@end
