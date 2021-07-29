//
//  JMusicPlayerViewController.m
//  Fitbox
//
//  Created by Khatib H. on 11/23/15.
//  
//

#import "JMusicPlayerViewController.h"
#import <AVFoundation/AVFoundation.h>

@interface JMusicPlayerViewController ()
{
    IBOutlet UILabel *mLblArtist;
    IBOutlet UILabel *mLblTitle;
    IBOutlet UIImageView *mImgThumb;
    IBOutlet UISlider *mSliderTime;
    IBOutlet UIButton *mBtnPlay;
    IBOutlet UIButton *mBtnNext;
    IBOutlet UIButton *mBtnPrev;
    
    int currentPlay;

    AVPlayer *audioPlayer;
    
    BOOL isPlaying;

    JSoundCloudTrackInfo *currentTrack;
        id playerObserver_;
    BOOL isSeeking;
    
    BOOL isLoading;
}

@end

@implementation JMusicPlayerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    currentPlay = 0;
    isLoading = false;
    [mSliderTime addTarget:self action:@selector(beginSeek:) forControlEvents:UIControlEventTouchDown];
    [mSliderTime addTarget:self action:@selector(seekPositionChanged:) forControlEvents:UIControlEventValueChanged];
    [mSliderTime addTarget:self action:@selector(endSeek:) forControlEvents:(UIControlEventTouchUpInside | UIControlEventTouchUpOutside | UIControlEventTouchCancel)];
    
    [mSliderTime setThumbImage:[UIImage imageNamed:@"iconCircle"] forState:UIControlStateNormal];
    [mSliderTime setThumbImage:[UIImage imageNamed:@"iconCircle"] forState:UIControlStateHighlighted];

    if (_mPlaylistId) {
        _mMusicInfo = [[Engine gSoundCloudPlayDict] objectForKey:_mPlaylistId];
    }
    if (_mMusicInfo) {
        if ([_mMusicInfo.playlistTracks count]>0) {
            [self initViewWithTrack:[_mMusicInfo.playlistTracks objectAtIndex:0]];
        }
        else
        {
            [self.navigationController.view makeToast:@"No tracks in the playlist" duration:1.0 position:CSToastPositionTop];
            [self.navigationController popViewControllerAnimated:YES];
        }
    }
    else
    {
        [self getPlayList:_mPlaylistId];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:true animated:animated];
    mImgThumb.layer.cornerRadius = mImgThumb.frame.size.width / 2.0;
    mImgThumb.layer.cornerRadius = (SCREEN_HEIGHT - 125 - 40 - 170 - 23)/2.0;

}
-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear: animated];
    [self.navigationController setNavigationBarHidden:false animated:animated];
    [self removeObservers];
    [self removeCurrentOne];
}


-(void)getPlayList:(NSString*)playlistId
{
    //    if ([_mArrData count] == 0) {
    //        [JUtils showLoadingIndicator:self.navigationController.view message:@"Loading"];
    //    }
    isLoading = true;
    AFHTTPSessionManager *sessionManager = [[AFHTTPSessionManager alloc] initWithBaseURL:[NSURL URLWithString:@"http://api.soundcloud.com/"]];
    sessionManager.responseSerializer = [AFJSONResponseSerializer serializer];
//    sessionManager.responseSerializer.acceptableContentTypes =[NSSet setWithObjects:@"application/json", @"text/json", @"text/javascript", @ nil];
    NSString *path = [NSString stringWithFormat:@"playlists/%@?client_id=%@", playlistId, SOUND_CLOUD_ID];
    [JUtils showLoadingIndicator:self.navigationController.view message:@"Loading playlist..."];
    [sessionManager GET:path parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        isLoading = false;
        [JUtils hideLoadingIndicator:self.navigationController.view];
        if (responseObject) {
            
            NSDictionary *dict = (NSDictionary*)responseObject;
            JSoundCloudPlayListInfo *playlist = [[JSoundCloudPlayListInfo alloc] init];
            [playlist setWithDictionary:dict];
            if ([playlist.playlistTracks count]==0) {
                [self.navigationController.view makeToast:@"No tracks in the playlist" duration:1.0 position:CSToastPositionTop];
                [self.navigationController popViewControllerAnimated:YES];
                return ;
            }
            [[Engine gSoundCloudPlayDict] setObject:playlist forKey:playlist.playlistId];
            _mMusicInfo = playlist;
            
            [self initViewWithTrack:[_mMusicInfo.playlistTracks objectAtIndex:0]];
        }
        else
        {
            [self.navigationController.view makeToast:@"No playlist found" duration:1.0 position:CSToastPositionTop];
            [self.navigationController popViewControllerAnimated:YES];
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        isLoading = false;
        if (error) {
            NSLog(@"Error: %@", error);
        }
        [JUtils hideLoadingIndicator:self.navigationController.view];
        [self.navigationController popViewControllerAnimated:YES];
        [self.navigationController.view makeToast:@"No playlist found" duration:1.0 position:CSToastPositionCenter];
    }];
}



-(void)removeCurrentOne
{
    [self pause];
    if (audioPlayer) {
//        [audioPlayer pause];
        audioPlayer = nil;
    }
}
-(void)initViewWithTrack:(JSoundCloudTrackInfo*)track
{
    currentTrack = track;
    mLblArtist.text = track.trackArtist;
    mLblTitle.text = track.trackTitle;
    mSliderTime.maximumValue = track.trackDuration / 1000;
    mSliderTime.value = 0;


    [mImgThumb cancelImageRequestOperation];
    mImgThumb.image = [UIImage imageNamed:@"app_icon"];
    if (track.trackThumb && ![track.trackThumb isEqualToString:@""])
    {
        [mImgThumb setImageWithURL:[NSURL URLWithString:track.trackThumb]];
    }
    else
    {
    }
    [self setAudioPlayer:track];
}
-(void)setAudioPlayer:(JSoundCloudTrackInfo*)track
{
    [self removeObservers];
    [self removeCurrentOne];
    NSString *soundURLString = [NSString stringWithFormat:SOUND_CLOUD_AUDIO_URL,track.trackId];
    NSURL * url = [NSURL URLWithString:soundURLString];
    audioPlayer = [AVPlayer playerWithURL:url];
    [audioPlayer setVolume:1];
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
    [[AVAudioSession sharedInstance] setActive:YES error:nil];

    AVPlayerLayer * layer = [AVPlayerLayer layer];
    [layer setPlayer:audioPlayer];
    [layer setFrame:CGRectMake(0, 0, 1, 1)];
    [layer setBackgroundColor:[UIColor clearColor].CGColor];
    [self.view.layer addSublayer:layer];
//    [self addObservers];
    
//    playButton.userInteractionEnabled = true;
    [self addObservers];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(playerItemDidReachEnd:)
                                                 name:AVPlayerItemDidPlayToEndTimeNotification
                                               object:[audioPlayer currentItem]];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(playerItemPlaybackStalled:)
                                                 name:AVPlayerItemPlaybackStalledNotification
                                               object:[audioPlayer currentItem]];
}

- (IBAction)onTouchBtnBack: (id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

-(IBAction)onTouchBtnNext:(id)sender
{
    if (_mMusicInfo.playlistTracksCount <= 1) {
        return;
    }
//    else
//    {
//        [self pause];
//    }
    BOOL isCurrentlyPlaying = isPlaying;
    currentPlay = (currentPlay + 1) % _mMusicInfo.playlistTracksCount;
    NSLog(@"onTouchBtnNext - Next Play: %d", currentPlay);
    [self initViewWithTrack:[_mMusicInfo.playlistTracks objectAtIndex:currentPlay]];
    if (isCurrentlyPlaying) {
        [self play];
    }
}
-(IBAction)onTouchBtnPrev:(id)sender
{
    if (_mMusicInfo.playlistTracksCount <= 1) {
        return;
    }

    currentPlay = (currentPlay - 1) % _mMusicInfo.playlistTracksCount;
    [self initViewWithTrack:[_mMusicInfo.playlistTracks objectAtIndex:currentPlay]];
}


#pragma mark - Observers

-(void)addObservers {
    
    __weak JMusicPlayerViewController *weekSelf = self;
    playerObserver_ = [audioPlayer addPeriodicTimeObserverForInterval:CMTimeMake(1, 1) queue:dispatch_get_main_queue() usingBlock:^(CMTime time) {
        if ([weekSelf respondsToSelector:@selector(audioPlayerDidChangeCurrentTime)]) {
            [weekSelf  audioPlayerDidChangeCurrentTime];
        }
    }];
    
    
    
}

-(void)removeObservers {
    
    if (audioPlayer && playerObserver_) {
        [audioPlayer removeTimeObserver:playerObserver_];
    }
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
}


-(void)playerItemDidReachEnd:(id)sender
{
    NSLog(@"playerItemDidReachEnd");
    [self onTouchBtnNext:nil];
    if (_mMusicInfo.playlistTracksCount > 1) {
        [self play];
    }
    else{
        [self pause];
    }
}
- (void)playerItemPlaybackStalled: (NSNotification *)notification {
    NSLog(@"playerItemPlaybackStalled");
    if(audioPlayer)
    {
        if(isPlaying)
        {
            [audioPlayer play];
        }
    }
}
-(IBAction)playAudio:(id)sender{
    if (isPlaying) {
        [self pause];
    }else{
        [self play];
    }
}

-(void)play{
    NSLog(@"play");
    if (audioPlayer) {
        [audioPlayer play];
    }
    isPlaying = TRUE;
    [mBtnPlay setImage:[UIImage imageNamed:@"btnIconBigPause"] forState:UIControlStateNormal];
    
}
-(void)pause{
    if (audioPlayer) {
        [audioPlayer pause];
    }

    isPlaying = FALSE;
    [mBtnPlay setImage:[UIImage imageNamed:@"btnIconBigMediaPlay"] forState:UIControlStateNormal];
    
}

-(void)stop{
    [self pause];
    audioPlayer = nil;
}

- (void)applyProgressToSubviews
{
//    CGFloat progressWidth = bs.size.width *[self currentPlaybackTime] / [self currentPlaybackDuration];
    mSliderTime.value = [self currentPlaybackTime];// / (currentTrack.trackDuration / 1000);
}

#pragma mark - Actions

- (NSTimeInterval)currentPlaybackTime
{
    
    return audioPlayer.currentTime.value == 0 ? 0 : audioPlayer.currentTime.value / audioPlayer.currentTime.timescale;
}

- (NSTimeInterval)currentPlaybackDuration
{
    return CMTimeGetSeconds([[audioPlayer.currentItem asset] duration]);
}

-(void)audioPlayerDidChangeCurrentTime{
    
    if (isSeeking) {
        return;
    }
    //    [self.minimizeButton setHidden:false];
    [self applyProgressToSubviews];
    
}


#pragma mark Handler
- (void)beginSeek:(id)sender
{
    isSeeking = YES;
}

- (void)seekPositionChanged:(id)sender
{
//    NSMutableString *durationString = [NSMutableString new];
//    NSInteger currentTime = mSliderTime.value;
}

- (void)endSeek:(id)sender
{
    UISlider *slider = (UISlider *)sender;

//    [audioPlayer seekToTime: CMTimeMake([self currentPlaybackDuration] * slider.value, 1)];
    [audioPlayer seekToTime: CMTimeMake(slider.value, 1)];
    [audioPlayer play];
    isSeeking = NO;
}


@end
