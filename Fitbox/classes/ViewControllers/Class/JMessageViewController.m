//
//  JMessageViewController.m
//  Fitbox
//
//  Created by Khatib H. on 2/18/16.
//  
//

#import "JMessageViewController.h"
#import "Fitbox-Swift.h"
#import "HPGrowingTextView.h"

#import "SVPullToRefresh.h"
#import "JAmazonS3ClientManager.h"
#import "AppDelegate.h"
#import "JMyActionSheet.h"

#define THUMBNAIL_WIDTH 150.0
#define THUMBNAIL_HEIGHT 150.0
#define PREFERED_WIDTH 640
#define PREFERED_HEIGHT 1136
#define PREFERED_RATIO 1136.0/640.0

#define SECTION_MAX_PREF     10000

#define FONT_CHAT_MESSAGE [UIFont systemFontOfSize:15]
#import "JTouchDownGestureRecognizer.h"

@interface JMessageViewController ()<UITextFieldDelegate, UIGestureRecognizerDelegate,HPGrowingTextViewDelegate,UITextViewDelegate, UIActionSheetDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>
{
    NSString *listingID;
    NSString *userID;
    NSString *roomID;// ListingID_ListingPosterID_MessengerID
    
    
    IBOutlet UIView *mViewForChat;
    IBOutlet UITableView    *mTView;
    
    BOOL tryHideKeyboardBool;
    
    IBOutlet UIButton   *mBtnSend;
    UIActivityIndicatorView *mActivityIndicator;
    IBOutlet UIImageView *mBlankFrame;
    
    NSMutableArray          *mArrChatMsg;
    
    BOOL alreadyDone;
    
    int                 mLastTimestamp;
    NSString*                 mLastMessageId;
    HPGrowingTextView *textView;

    BOOL isConnected;
    SocketIOClient* socket;
    
    NSManagedObjectContext *context;
    
    IBOutlet NSLayoutConstraint *mConstraintChatboxBottom;
    IBOutlet NSLayoutConstraint *mConstraintChatboxHeight;
    
    NSString *listingPosterId;
    
    BOOL alreadyDecreased;
    
    NSMutableArray *mRequestsUploadPool;
    
    IBOutlet UIButton *mBtnPhoto;
    
    
    IBOutlet UIView *mViewImageUploadProgressContainer;
    IBOutlet UIView *mViewImageUploadUploaded;
    IBOutlet UIButton *mBtnCancelPhotoUpload;
    IBOutlet NSLayoutConstraint *mConstraintProgressWidth;
    
    UIImageView* mFullPhoto;
    UIView*        mFullPhotoView;
    
    UITapGestureRecognizer *recog;
    
}
@property (nonatomic, retain) NSString *mFileNameToUpload;
@property (nonatomic, retain) UIImage *mImageBig;
@property (nonatomic, retain) UIImage *mImageSmall;
@end

@implementation JMessageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    isConnected = false;
    alreadyDecreased = false;
    // Do any additional setup after loading the view.

    alreadyDone = false;

    mLastTimestamp = 0;
    mArrChatMsg = [[NSMutableArray alloc] init];
    mRequestsUploadPool = [[NSMutableArray alloc] init];
    
    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    context = [delegate managedObjectContext];

    [mTView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"messageCell"];

    [self initChatView];
    [self getData];
    [self loadDataFromCore];

    [self initChatSystem];
    

    mFullPhotoView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
    mFullPhotoView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.8];

    mFullPhoto = [[UIImageView alloc] initWithFrame:mFullPhotoView.bounds];
    mFullPhoto.backgroundColor = [UIColor clearColor];
    mFullPhoto.contentMode = UIViewContentModeScaleAspectFit;
    [mFullPhotoView addSubview:mFullPhoto];
    
    [self.navigationController.view addSubview:mFullPhotoView];
    mFullPhotoView.hidden = true;
    
    
    UITapGestureRecognizer* recognizer=[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(closeFullPhotoView:)];
    recognizer.numberOfTouchesRequired=1;
    recognizer.delegate=self;
    [mFullPhotoView addGestureRecognizer:recognizer];
    
    mViewImageUploadProgressContainer.hidden = true;

    recog=[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTapBackground:)];
    recog.numberOfTouchesRequired=1;
    recog.delegate=self;
}

-(void)initChatSystem
{
    NSURL* url = [[NSURL alloc] initWithString:WEB_SERVICE_CHAT_URL];
    socket = [[SocketIOClient alloc] initWithSocketURL:url options:@{@"log": @YES}];//, @"forcePolling": @YES
    [socket onAny:^(SocketAnyEvent * _Nonnull anyEvent) {
        NSLog(@"socket any: %@ %@", anyEvent.event, anyEvent.items);
        
    }];
    [socket on:@"connect" callback:^(NSArray* data, SocketAckEmitter* ack) {
        NSLog(@"socket connected");
        isConnected = true;
        NSLog(@"ROOM: %@", @[@{@"roomID": roomID, @"user":[JUser me]._id, @"lastTime":[NSNumber numberWithInt:mLastTimestamp + 1], kChatHistoryListingPosterID: listingPosterId}]);
        [socket emit:@"set room" withItems:@[@{@"roomID": roomID, @"user":[JUser me]._id, @"lastTime":[NSNumber numberWithInt:mLastTimestamp + 1], kChatHistoryListingPosterID: listingPosterId}]];
    }];
    [socket on:@"disconnect" callback:^(NSArray* data, SocketAckEmitter* ack) {
        NSLog(@"socket disconnected");
        isConnected = true;
    }];
    [socket on:@"chat" callback:^(NSArray* data, SocketAckEmitter* ack) {
        NSLog(@"Chat Response: %@", data);
        if ([data count] > 0) {
            [self addNewMessageWithDataFromServer:[data objectAtIndex:0] withDate:nil];
            if (_mMessageHistory) {
                _mMessageHistory.lastMessage=[[data objectAtIndex:0] objectForKey:kMessagesMessage];
            }
            [mTView reloadData];
            [self moveScrollToBottom];

        }
    }];
    
    [socket on:@"past messages" callback:^(NSArray* data, SocketAckEmitter* ack) {
        NSLog(@"past messages: %@", data);
        if ([data count] > 0) {
            NSArray *messages = [data objectAtIndex:0];
            for (int i=(int)[messages count] - 1; i>=0; i--) {
                [self addNewMessageWithDataFromServer:[messages objectAtIndex:i] withDate:nil];
            }
            if (!alreadyDecreased) {
                if (([messages count] > 0) && ([Engine gNewMessageCount]>0)){
                    [Engine setGNewMessageCount:[Engine gNewMessageCount] - 1];
                    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_MESSAGE_COUNT_UPDATED object:nil];
                }
                alreadyDecreased = true;
            }
            [mTView reloadData];
            [self moveScrollToBottom];
        }
    }];
    
    [socket connect];
}

- (void)initChatView
{
    textView = [[HPGrowingTextView alloc] initWithFrame:CGRectMake(48, 7, 214, 15)];
    textView.isScrollable = NO;
    textView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
    textView.internalTextView.contentInset=UIEdgeInsetsMake(0, 0, 0, 0);
    
    textView.minNumberOfLines = 1;
    textView.maxNumberOfLines = 6;
    textView.returnKeyType = UIReturnKeyDefault; //just as an example
    textView.font = [UIFont systemFontOfSize:14.0f];
    textView.delegate = self;
    textView.backgroundColor = [UIColor whiteColor];
    textView.internalTextView.layer.masksToBounds=YES;
    textView.internalTextView.clipsToBounds=YES;
    textView.internalTextView.scrollEnabled=NO;
    textView.placeholder = @"Say something...";
    
    textView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [textView setBackgroundColor:[UIColor whiteColor]];
    [mViewForChat insertSubview:textView belowSubview:mBlankFrame];
    mBlankFrame.image = [[UIImage imageNamed:@"bgTextField_InnerBlank.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(26, 10, 26, 10)];
    
    textView.layer.masksToBounds=YES;
    
    mViewForChat.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
    
//    current_Run=0;
    
    mActivityIndicator=[[UIActivityIndicatorView alloc] initWithFrame:CGRectMake((mBtnSend.frame.size.width-20)/2, (mBtnSend.frame.size.height-20)/2, 20, 20)];
    mActivityIndicator.activityIndicatorViewStyle=UIActivityIndicatorViewStyleGray;
    [mBtnSend addSubview:mActivityIndicator];
    

    

}


-(void)getData
{
    if (_mMessageHistory) {
        roomID = _mMessageHistory.roomID;
        userID = _mMessageHistory.listingPoster._id;
        listingPosterId = _mMessageHistory.listingPoster._id;

        if ([userID isEqualToString:[JUser me]._id])
        {//Me is the listing Poster
            userID = _mMessageHistory.user._id;
        }
        
        _mPerson = [[JUser allDict] objectForKey:userID];
        
        if (!_mPerson) {
            //Shouldn't fallhere
//            [JPerson loadPersonWithWithID:userID completionBlock:^(PFObject *object) {
//                if (object) {
//                    _mPerson = object;
//                    [self initPersonInfo];
//                }
//            }];
        }
        else
        {
            [self initPersonInfo];
        }
        
        listingID = _mMessageHistory.listing._id;
        _mListing = _mMessageHistory.listing;
        
        if (!_mListing) {
             //Shouldn't fallhere
//            [JUser loadListing:listingID completionBlock:^(PFObject *object) {
//                if (object) {
//                    _mListing = object;
//                }
//            }];
        }
    }
    else
    {
        userID = [JUser me]._id;
        listingID = _mListing._id;
        listingPosterId = _mListing.user._id;
        roomID = [NSString stringWithFormat:@"%@_%@_%@", listingID, _mListing.user._id, userID];
        
        _mMessageHistory = [JMessageHistory messageHistoryWithRoomIdIfExists:roomID];
        if (!_mMessageHistory) {
            [self loadMessageHistory];
        }
        [self initPersonInfo];
    }
}

-(void)initPersonInfo
{
    self.navigationItem.title = _mPerson.username;
}

-(void)loadMessageHistory
{
    [APIClient loadMessageHistoryWithRoom:roomID success:^(JMessageHistory *messagHistory) {
        _mMessageHistory = messagHistory;
    } failure:^(NSString *errorMessage) {
        
    }];
}

- (void)loadDataFromCore
{

    NSError *error;
    
    
    // Retrieve the entity from the local store -- much like a table in a database
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Messages" inManagedObjectContext:context];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entity];
    
    // Set the predicate -- much like a WHERE statement in a SQL database
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"roomID == %@", roomID];
    
    [request setPredicate:predicate];
    
    // Set the sorting -- mandatory, even if you're fetching a single record/object
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"createdAt" ascending:YES];
    NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
    [request setSortDescriptors:sortDescriptors];
    
    NSArray *mArr=[context executeFetchRequest:request error:&error];
    
    sortDescriptors = nil;
    sortDescriptor = nil;
    NSManagedObject *object;
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat: @"MM/dd/yyyy"];
    for (int i=0; i<[mArr count]; i++) {
        JMessage *info=[[JMessage alloc] init];
        object=[mArr objectAtIndex:i];
        
        info.message = [object valueForKey:@"message"];
        info.type = [object valueForKey:@"type"];
        info.createdAt= [[object valueForKey:@"createdAt"] intValue];
        info.userId = [object valueForKey:@"user"];
        info.roomID = [object valueForKey:@"roomID"];
        
        if((info.createdAt - mLastTimestamp)<60*60*2)
        {
            [[mArrChatMsg lastObject] addObject: info];
        }
        else
        {
            NSMutableArray *arr = [[NSMutableArray alloc] init];
            [arr addObject: info];
            [mArrChatMsg addObject: arr];
        }
        
        mLastTimestamp = info.createdAt;
        mLastMessageId = info.userId;
    }
}

-(void)addNewMessageWithDataFromServer:(NSDictionary*)dataDict withDate:(NSDate*)date
{
    JMessage *info=[[JMessage alloc] init];
    
    info.message = [dataDict objectForKey:kMessagesMessage];
    info.type = [dataDict objectForKey:kMessagesType];
//    NSDate *dt;
    if (date) {
        info.createdAt= [date  timeIntervalSince1970];
    }
    else
    {
        info.createdAt= [[dataDict objectForKey:kCreatedAt] intValue];
    }
    info.userId = [dataDict objectForKey:kUserId];
    info.roomID = [dataDict objectForKey:kMessagesRoomID];
    
    [self saveMessageToCoreData:info];
    [self addMessageToChatArr:info];
}

-(void)saveMessageToCoreData:(JMessage*)info
{
    NSManagedObject *messageInfo= [NSEntityDescription
                                   insertNewObjectForEntityForName:@"Messages"
                                   inManagedObjectContext:context];
    
    [messageInfo setValue: info.message  forKey: kMessagesMessage];
    [messageInfo setValue: info.type forKey:kMessagesType];
    [messageInfo setValue: info.roomID forKey:kMessagesRoomID];
    [messageInfo setValue: [NSNumber numberWithInt: info.createdAt] forKey:kCreatedAt];
    [messageInfo setValue: info.userId forKey:kUserId];
    
    NSError *error;
    if (![context save:&error]) {
        NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
    }
}

-(void)addMessageToChatArr:(JMessage*)info
{
    if((info.createdAt - mLastTimestamp)<60*60*2)
    {
        [[mArrChatMsg lastObject] addObject: info];
    }
    else
    {
        NSMutableArray *arr = [[NSMutableArray alloc] init];
        [arr addObject: info];//[NSString stringWithFormat:@"%@",date]] ;
        
        [mArrChatMsg addObject: arr];
    }
    
    mLastTimestamp = info.createdAt;
}

-(void)processMessages:(NSArray*)messages saveToCoreData:(BOOL)saveToCoreData
{
    
//    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
//    [formatter setDateFormat: @"MM/dd/yyyy"];
    
    
    for (int i=0; i<[messages count]; i++) {
        JMessage *info=[[JMessage alloc] init];
        NSObject *objectData = [messages objectAtIndex:i];
        
        if ([objectData isKindOfClass:[NSManagedObject class]]) {
            NSManagedObject *object;
            object=(NSManagedObject*)objectData;

            info.message = [object valueForKey:kMessagesMessage];
            info.type = [object valueForKey:kMessagesType];
            info.createdAt= [[object valueForKey:kCreatedAt] intValue];
            info.userId = [object valueForKey:kUserId];
//            info.objectId = [object valueForKey:@"objectId"];
            info.roomID = [object valueForKey:kMessagesRoomID];
        }
        else if([objectData isKindOfClass:[JMessage class]])
        {
            JMessage *object;
            object=(JMessage*)objectData;
            
            info.message = object.message;
            info.type = object.type;
            info.createdAt= object.createdAt;
            info.userId = object.userId;
            info.roomID = object.roomID;
        }
        
        
        
        if (saveToCoreData) {
            [self saveMessageToCoreData:info];
        }
        //        [mArrChatMsg addObject:info];
        
        //        NSTimeInterval epoch = [info.mTimeStamp doubleValue];
        //        NSDate * date = [NSDate dateWithTimeIntervalSince1970:epoch];
        
        [self addMessageToChatArr:info];
//        mLastMessageId = info.userId;
        //        chatPartner.mPointer=mLastTimestamp;
    }
}
//
//-(void)loadPastChats
//{
//    
//    PFQuery *query=[PFQuery queryWithClassName:kClassMessages];
////    [query whereKey:kMessagesRoomID equalTo:roomID];
////    if (mLastTimestamp > 0) {
////        [query whereKey:kCreatedAt greaterThan: [NSDate dateWithTimeIntervalSince1970:mLastTimestamp]];
////    }
//    
//    [query orderByAscending:kCreatedAt];
//    
//    [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
//        if(objects && [objects count] > 0)
//        {
//            [self processMessages:objects saveToCoreData:true];
//        }
//    }];
//}

-(void)initUser
{
    
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

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
}
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear: animated];
    tryHideKeyboardBool=NO;
    
    
//    mIsRunning=TRUE;
//    current_Run++;
    [self initView];
    
    if (_mPerson) {
        [self initPersonInfo];
    }
//    [mTView reloadData];
}

- ( void ) viewWillDisappear : ( BOOL ) _animated
{
    [ super viewWillDisappear : _animated ] ;
    
}
-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}


- (void)initView
{
//    isKeyboardUp=NO;
//    //    isKeyboardHiding=NO;
//    
//    mIsPause=NO;

//    mLastTimestamp=0;
//    mLastMessageId=@"";
//    mIsRunning = YES;
//    requestSent=0;

    [textView setText:@""];
    [textView refreshHeight];
    
    
    [textView setHidden:NO];
    
    [mTView reloadData];
    
    [mBtnSend setEnabled:NO];
    
    if([mArrChatMsg count]>0)
    {
        NSIndexPath *topIndexPath = [NSIndexPath indexPathForRow:[[mArrChatMsg lastObject] count] - 1
                                                       inSection: [mArrChatMsg count] - 1];
        
        [mTView scrollToRowAtIndexPath:topIndexPath
                      atScrollPosition:UITableViewScrollPositionMiddle
                              animated:NO];
    }
    else
    {
        [mTView scrollRectToVisible:CGRectMake(0, 0, mTView.frame.size.width, 10) animated:NO];
    }
    
//    first_message=0;
}

-(void)onTapBackground:(id)sender
{
    [mViewForChat endEditing:YES];
}

//-(void)tryHideKeyboard:(id)sender
//{
//    tryHideKeyboardBool=YES;
//    [mViewForChat endEditing:YES];
//    [NSThread detachNewThreadSelector:@selector(changeUIAfterInactive:) toTarget:self withObject:nil];
//    //    dispatch_async(dispatch_get_main_queue(),  ^ {
//    //    });
//}
//-(void)changeUIAfterInactive:(id)sender
//{
//    CGRect containerFrame = mViewForChat.frame;
//    containerFrame.origin.y = self.view.bounds.size.height - containerFrame.size.height;
//    mViewForChat.frame=containerFrame;
//    
//    [mTView setContentInset:UIEdgeInsetsMake(0, 0,mTView.frame.size.height+mTView.frame.origin.y- containerFrame.origin.y , 0)];
//    mTView.scrollIndicatorInsets = mTView.contentInset;
//    
//}

#pragma mark -
#pragma mark - Call Back Function


-(IBAction)onBtnBack:(id)sender
{
    [self onTouchBtnCancelSendingImage:nil];
    
    if ([[JUser me]._id isEqualToString:listingPosterId]) {
        _mMessageHistory.unreadCountPoster=0;
    }
    else
    {
        _mMessageHistory.unreadCountUser=0;
    }
    [socket disconnect];
    [self.navigationController popViewControllerAnimated:true];
}

- (IBAction)onTouchBtnSend: (id)sender
{
    if ([textView.text isEqualToString:@""]) {
        return;
    }
    [self sendMessage:textView.text messageType:MESSAGE_TYPE_NOTE];
    
    textView.text = @"";
}


-(void)sendMessage:(NSString*)message messageType:(NSString*)messageType
{
    NSString *historyID = @"";
    
    NSString *historyMessage = message;
    if ([messageType isEqualToString:MESSAGE_TYPE_PHOTO]) {
        historyMessage = @"Sent you a photo";
    }
    
    int newMessageIncrease = 1;
    
    if (!_mMessageHistory) {
        NSMutableDictionary *dict=[NSMutableDictionary new];
        [dict setObject:_mListing._id forKey:kChatHistoryListingID];
        [dict setObject:roomID forKey:kChatHistoryRoomID];
        [dict setObject:_mListing.user._id forKey:kChatHistoryListingPosterID];
        [dict setObject:[JUser me]._id forKey:kUserId];
        [dict setObject:historyMessage forKey:kChatHistoryLastMessage];
        
        [dict setObject:@0 forKey:kChatHistoryUnreadCountUser];
        [dict setObject:@1 forKey:kChatHistoryUnreadCountPoster];
        
        [APIClient postMessageHistory:dict success:^(JMessageHistory *messageHistory) {
            _mMessageHistory=messageHistory;
            
            NSDictionary *messageDict = @{kMessagesRoomID:roomID,kUserId:[JUser me]._id,@"receiver":_mPerson._id,kMessagesMessage:message, @"messageHistory":_mMessageHistory._id, kMessagesType: messageType, kChatHistoryListingPosterID: listingPosterId, @"newIncrease": [NSNumber numberWithInt:newMessageIncrease]};
            [socket emit:@"chat" withItems:@[messageDict]];
            
        } failure:^(NSString *errorMessage) {
            [JUtils showMessageAlert:errorMessage];            
        }];
        alreadyDone = true;
    }
    else
    {
        historyID = _mMessageHistory._id;
        _mMessageHistory.lastMessage=historyMessage;
        
        if (!alreadyDone) {
            if ([[JUser me]._id isEqualToString:listingPosterId]) {
                if ([_mMessageHistory.unreadCountUser intValue] == -1) {
                    newMessageIncrease = 2;
                    _mMessageHistory.unreadCountUser=@1;
                }
            }
            else
            {
                if ([_mMessageHistory.unreadCountPoster intValue] == -1) {
                    newMessageIncrease = 2;
                    _mMessageHistory.unreadCountPoster=@1;
                }
            }
            alreadyDone = true;
        }
        NSDictionary *messageDict = @{kMessagesRoomID:roomID,kUserId:[JUser me]._id,@"receiver":_mPerson._id,kMessagesMessage:message, @"messageHistory":historyID, kMessagesType: messageType, kChatHistoryListingPosterID: listingPosterId, @"newIncrease": [NSNumber numberWithInt:newMessageIncrease]};
        [socket emit:@"chat" withItems:@[messageDict]];
    }

}
-(IBAction)onTouchBtnCloseChatbox:(id)sender
{
    textView.text = @"";
    [self.view endEditing:true];
}


#pragma mark - Table view data source



- ( NSInteger ) numberOfSectionsInTableView : ( UITableView* ) _tableView
{
    return [mArrChatMsg count];
}

- (CGFloat)tableView:(UITableView *)_tableView heightForHeaderInSection:(NSInteger)section
{
    return 34;
}

- (UIView *)tableView:(UITableView *)_tableView viewForHeaderInSection:(NSInteger)section
{
    
    UIView *cellView = [[UIView alloc] initWithFrame: CGRectMake(0, 0, mTView.frame.size.width, 34)];
    UILabel *lblDate = [[UILabel alloc] initWithFrame: CGRectMake(90, 18, 140, 14)];
    JMessage *message=[[mArrChatMsg objectAtIndex: section] objectAtIndex:0];
    
    NSTimeInterval epoch = message.createdAt;
    NSDate * date = [NSDate dateWithTimeIntervalSince1970:epoch];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];

    [formatter setTimeStyle:NSDateFormatterShortStyle];
    [formatter setDateStyle:NSDateFormatterMediumStyle];
    
    NSLog(@"%@",[formatter stringFromDate:date]);

    [lblDate setText: [formatter stringFromDate:date]];
    
    [lblDate setTextAlignment: NSTextAlignmentCenter];
    [lblDate setTextColor: [UIColor darkGrayColor]];
    [lblDate setFont:[UIFont systemFontOfSize:11.0]];
    
    [cellView addSubview: lblDate];
    
    return cellView;
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    
    JMessage *info = [[mArrChatMsg objectAtIndex: indexPath.section] objectAtIndex: indexPath.row];
    CGFloat height = 0;
    if ([info.type isEqualToString:MESSAGE_TYPE_NOTE]) {
        height =[self messageSize:info.message].height + 35;
    }
    else if ([info.type isEqualToString:MESSAGE_TYPE_PHOTO])
    {
        height = 100 + 35;
    }
    else
    {
        height = 50;
    }
    
    return height;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[mArrChatMsg objectAtIndex: section] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    JMessage* info=[[mArrChatMsg objectAtIndex: indexPath.section] objectAtIndex: indexPath.row];

    UITableViewCell *cell = [mTView dequeueReusableCellWithIdentifier:@"messageCell"];
    [cell.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.backgroundColor = [UIColor clearColor];
    
    UILabel *mLblMessage;
    UIImageView *mImgMessageBg = [[UIImageView alloc] init];
    
    UIView *mMessageView = [[UIView alloc] init];
    [cell addSubview:mMessageView];
    [mMessageView addSubview:mImgMessageBg];

    
    UIImageView *mImgViewPhoto;

    
    CGSize textSize;
    
    if ([info.type isEqualToString:MESSAGE_TYPE_NOTE]) {
        mLblMessage = [[UILabel alloc] init];
        [mMessageView addSubview:mLblMessage];
        mLblMessage.text = info.message;
        mLblMessage.font = FONT_CHAT_MESSAGE;
        mLblMessage.numberOfLines = 0;
        textSize = [self messageSize:info.message];
        textSize.width+=5;
        if(textSize.width>205)
            textSize.width=205;

    }
    else if([info.type isEqualToString:MESSAGE_TYPE_PHOTO])
    {
        textSize = CGSizeMake(100, 100);
        mImgViewPhoto = [[UIImageView alloc] init];
        mImgViewPhoto.contentMode = UIViewContentModeScaleAspectFill;
        mImgViewPhoto.layer.masksToBounds = true;
        mImgViewPhoto.layer.cornerRadius = 8;
        [mImgViewPhoto setImageWithURL:[[JAmazonS3ClientManager defaultManager] cdnUrlForMessagePhotoThumb:info.message]];
        mImgViewPhoto.backgroundColor = MAIN_COLOR_LIGHT_GRAY;
        
        [mMessageView addSubview:mImgViewPhoto];
    }
    
    if ([info.userId isEqualToString:[JUser me]._id])
    {//Me
        if (mLblMessage) {
            [mLblMessage setTextColor:[UIColor whiteColor]];
            mLblMessage.frame = CGRectMake(15, 10, textSize.width+2,textSize.height+5);
        }
        
        if (mImgViewPhoto) {
            mImgViewPhoto.frame=CGRectMake(13,12,100,100);
        }
        
//        mMessageView.frame = CGRectMake((SCREEN_WIDTH-38)-textSize.width-40, 5, textSize.width+30,textSize.height+25);
        mMessageView.frame = CGRectMake((SCREEN_WIDTH-40)-textSize.width, 5, textSize.width+30,textSize.height+25);
        
        mImgMessageBg.image = [[UIImage imageNamed:@"bubbleRight"] resizableImageWithCapInsets:UIEdgeInsetsMake(18, 20, 18, 25)];
    }
    else {
        if (mLblMessage) {
            [mLblMessage setTextColor:[UIColor blackColor]];
            mLblMessage.frame = CGRectMake(21, 10, textSize.width,textSize.height+5);
        }
        
        if (mImgViewPhoto) {
            mImgViewPhoto.frame=CGRectMake(18,12,100,100);
        }

        mMessageView.frame = CGRectMake(5, 7, textSize.width+30,textSize.height+25);
        
        mImgMessageBg.image = [[UIImage imageNamed:@"bubbleLeft"] resizableImageWithCapInsets:UIEdgeInsetsMake(18, 25, 18, 20)];
    }

    [mImgMessageBg setFrame:CGRectMake(0, 0, mMessageView.frame.size.width, mMessageView.frame.size.height)];
    
    
    if (mImgViewPhoto) {
        UITapGestureRecognizer *recognizer=[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTouchBtnImageAction:)];
        recognizer.numberOfTouchesRequired=1;
        recognizer.delegate=self;
        [mMessageView addGestureRecognizer:recognizer];
        mMessageView.tag = indexPath.section * SECTION_MAX_PREF + indexPath.row;
    }
    
    return cell;
}
-(void)onTouchBtnImageAction:(UITapGestureRecognizer*)sender
{
    NSUInteger section = sender.view.tag / SECTION_MAX_PREF;
    NSUInteger row = sender.view.tag % SECTION_MAX_PREF;
    
    JMessage* info=[[mArrChatMsg objectAtIndex: section] objectAtIndex: row];
    
    [self showFullPhoto:info];

}
-(CGSize)messageSize:(NSString*)message {
    return [message boundingRectWithSize:CGSizeMake(200, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:FONT_CHAT_MESSAGE} context:nil].size;
}


#pragma mark -
#pragma mark - User Functions


-(void)moveScrollToBottom
{
    if ([mArrChatMsg count] > 0 && [[mArrChatMsg lastObject] count] > 0) {
        NSIndexPath *topIndexPath = [NSIndexPath indexPathForRow:[[mArrChatMsg lastObject] count] - 1
                                                       inSection: [mArrChatMsg count] - 1];
        [mTView scrollToRowAtIndexPath:topIndexPath
                      atScrollPosition:UITableViewScrollPositionMiddle
                              animated:true];
    }
}


-(void) keyboardWillShow:(NSNotification *)note{
    tryHideKeyboardBool=NO;
    [mTView addGestureRecognizer:recog];
    
    CGRect keyboardBounds;
    [[note.userInfo valueForKey:UIKeyboardFrameEndUserInfoKey] getValue: &keyboardBounds];
    NSNumber *duration = [note.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSNumber *curve = [note.userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey];
    
    // Need to translate the bounds to account for rotation.
    keyboardBounds = [self.view convertRect:keyboardBounds toView:nil];
    
    // get a rect for the textView frame
    CGRect containerFrame = mViewForChat.frame;
    containerFrame.origin.y = self.view.bounds.size.height - (keyboardBounds.size.height + containerFrame.size.height);
    
    float contentoffset=mTView.contentSize.height-(containerFrame.origin.y-mTView.frame.origin.y);
    if(contentoffset<0)
        contentoffset=0;
    
    BOOL alreadyAdjusted=NO;
    NSLog(@"Delta: %f",mTView.contentOffset.y-contentoffset);
    
    mConstraintChatboxBottom.constant = keyboardBounds.size.height;
    [mViewForChat setNeedsUpdateConstraints];
    [UIView animateWithDuration:[duration doubleValue]
                          delay:0.0f
                        options:[curve intValue]<<16
                     animations:^{
                         [self.view layoutIfNeeded];
                         if(alreadyAdjusted)
                         {
                             [mTView setContentInset:UIEdgeInsetsMake(0, 0, mConstraintChatboxBottom.constant + mConstraintChatboxHeight.constant , 0)];
                             mTView.scrollIndicatorInsets = mTView.contentInset;
                             [mTView setContentOffset:CGPointMake(0,contentoffset) animated:NO];
                         }
                     } completion:^(BOOL finished) {
                         if(!alreadyAdjusted)
                         {
                             [mTView setContentInset:UIEdgeInsetsMake(0, 0, mConstraintChatboxBottom.constant + mConstraintChatboxHeight.constant , 0)];
                             mTView.scrollIndicatorInsets = mTView.contentInset;
                         }
                     }];
    
}

-(void) keyboardWillHide:(NSNotification *)note{
    
    [mTView removeGestureRecognizer:recog];
    
    if (tryHideKeyboardBool) {
        tryHideKeyboardBool=NO;
        return;
    }
    NSNumber *duration = [note.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSNumber *curve = [note.userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey];
    CGRect containerFrame = mViewForChat.frame;
    containerFrame.origin.y = self.view.bounds.size.height - containerFrame.size.height;
    mConstraintChatboxBottom.constant = 0;
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:[duration doubleValue]];
    [UIView setAnimationCurve:[curve intValue]];
    [self.view layoutIfNeeded];
    [mTView setContentInset:UIEdgeInsetsMake(0, 0,mViewForChat.frame.size.height , 0)];//mTView.frame.size.height+mTView.frame.origin.y- containerFrame.origin.y
    mTView.scrollIndicatorInsets = mTView.contentInset;
    
    [UIView commitAnimations];
    
}

- (void)growingTextView:(HPGrowingTextView *)growingTextView willChangeHeight:(float)height
{
    float diff = (growingTextView.frame.size.height - height);
    
    CGRect r = mViewForChat.frame;
    r.size.height -= diff;
    r.origin.y += diff;
    mConstraintChatboxHeight.constant -= diff;
    
    [mTView setContentInset:UIEdgeInsetsMake(0, 0, mConstraintChatboxHeight.constant + mConstraintChatboxBottom.constant , 0)];
    mTView.scrollIndicatorInsets = mTView.contentInset;
}

-(void)growingTextViewDidChange:(HPGrowingTextView *)growingTextView
{
    if(!growingTextView.hidden)
    {
        if([growingTextView.text isEqualToString:@""])
        {
            [mBtnSend setEnabled:NO];
        }
        else
        {
            [mBtnSend setEnabled:YES];
        }
    }
}




-(UIImage * )scaleAndRotateImage:(UIImage *)image
{
    image = [JUtils imageWithImage:image scaledToSize:image.size];
    CGImageRef imgRef = image.CGImage;
    
    if ( !image )
        NSLog(@"Image is nil in scaleAndRotateImage");
    
    CGFloat width = CGImageGetWidth(imgRef);
    CGFloat height = CGImageGetHeight(imgRef);
    
    CGAffineTransform transform = CGAffineTransformIdentity;
    CGRect bounds = CGRectMake(0, 0, width, height);

    CGFloat scaleRatio =0;
    CGFloat actualRatio = height / width;
    if(width*PREFERED_RATIO>height)
    {
        if(width>PREFERED_WIDTH)
            bounds.size.width = PREFERED_WIDTH;
        else
            bounds.size.width=width;
        
        bounds.size.height = bounds.size.width*actualRatio;
        
        scaleRatio=bounds.size.width/width;
    }
    else
    {
        if(height>PREFERED_HEIGHT)
            bounds.size.height = PREFERED_HEIGHT;
        else
            bounds.size.height=height;
        
        bounds.size.width =  bounds.size.height/actualRatio;
        scaleRatio=bounds.size.height/height;
        
    }
    bounds.size.width=(int)bounds.size.width;
    bounds.size.height=(int)bounds.size.height;
    
    CGSize imageSize = CGSizeMake(CGImageGetWidth(imgRef), CGImageGetHeight(imgRef));

    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    
    CGContextRef contextBitmap = CGBitmapContextCreate(NULL, bounds.size.width, bounds.size.height, 8, bounds.size.width * 4, colorSpace, (CGBitmapInfo)kCGImageAlphaPremultipliedLast);
    CGColorSpaceRelease(colorSpace);
    
    CGContextScaleCTM(contextBitmap, scaleRatio, scaleRatio);
    
    CGContextDrawImage(contextBitmap, CGRectMake(0, 0, width, height), imgRef);
    
    CGImageRef imageRef = CGBitmapContextCreateImage(contextBitmap);
    UIImage *finalImage = [[UIImage alloc] initWithCGImage:imageRef scale:1 orientation:UIImageOrientationUp];
    CGImageRelease(imageRef);
    CGContextRelease(contextBitmap);
    
    [self setMImageBig:finalImage];
    
    
    
    contextBitmap = CGBitmapContextCreate(NULL, THUMBNAIL_WIDTH,THUMBNAIL_HEIGHT, 8, THUMBNAIL_WIDTH * 4, colorSpace, (CGBitmapInfo)kCGImageAlphaPremultipliedLast);
    CGColorSpaceRelease(colorSpace);
    
    CGContextScaleCTM(contextBitmap, THUMBNAIL_WIDTH/bounds.size.width, THUMBNAIL_WIDTH/bounds.size.width);
    CGContextTranslateCTM(contextBitmap, 0, -(bounds.size.height-bounds.size.width)/2.0);
    CGContextDrawImage(contextBitmap, CGRectMake(0, 0, bounds.size.width, bounds.size.height), finalImage.CGImage);
    
    imageRef = CGBitmapContextCreateImage(contextBitmap);
    finalImage = [[UIImage alloc] initWithCGImage:imageRef scale:1 orientation:UIImageOrientationUp];
    CGImageRelease(imageRef);
    CGContextRelease(contextBitmap);
    
    [self setMImageSmall:finalImage];
    
    
    
    return finalImage;
}

-(IBAction)onTouchBtnCancelSendingImage:(id)sender
{
    if ([mRequestsUploadPool count] > 0) {
        JS3FileUploader *uploader = [mRequestsUploadPool firstObject];
        [uploader cancel];
        [mRequestsUploadPool removeAllObjects];
        mViewImageUploadProgressContainer.hidden = true;
    }
}
- (NSString *)fileKeyForUpload
{
    int time_key=[[NSDate date] timeIntervalSince1970];//*1000;
    NSLog(@"Time Interval: %d",time_key);
    return [NSString stringWithFormat:@"fitbox_%d_%@",time_key,[JUser me]._id];
}
- (void)uploadMessagePhoto:(UIImage*)imageTo quality:(float)quality
{

    [self setMFileNameToUpload:[self fileKeyForUpload]];
    NSLog(@"Profile Photo ID: %@",[self mFileNameToUpload]);
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0),  ^ {
        
        [self scaleAndRotateImage:imageTo];
        
        NSData *data = [NSData dataWithData: UIImageJPEGRepresentation([self mImageSmall],quality)];
        if (data && data.length)
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                mViewImageUploadProgressContainer.hidden = false;
                mBtnPhoto.enabled = false;
            });
            
            JS3FileUploader* uploader=[[JAmazonS3ClientManager defaultManager] uploadMessagePhotoThumbnailData:data fileKey:[self mFileNameToUpload] withProcessBlock:^ (float progress) {
                NSLog(@"Progress: %d", (int)(progress*100));
                dispatch_async(dispatch_get_main_queue(), ^{
                    mConstraintProgressWidth.constant = SCREEN_WIDTH * (progress * 0.2);
                });

            } completeBlock:^ (NSString *obj) {
                [mRequestsUploadPool removeAllObjects];
                if ([obj isKindOfClass:[NSString class]]) {
                    NSData *data = [NSData dataWithData: UIImageJPEGRepresentation([self mImageBig],quality)];
                    
                    
                    JS3FileUploader* uploader1=[[JAmazonS3ClientManager defaultManager] uploadMessagePhotoData:data fileKey:[self mFileNameToUpload] withProcessBlock:^ (float progress) {
                        NSLog(@"Progress: %d", (int)(progress*100));
                        dispatch_async(dispatch_get_main_queue(), ^{
                            mConstraintProgressWidth.constant = SCREEN_WIDTH * 0.2 + SCREEN_WIDTH * (progress * 0.8);
                        });

                    } completeBlock:^ (NSString *obj1) {
                        
                        [mRequestsUploadPool removeAllObjects];
                        
                        dispatch_async(dispatch_get_main_queue(), ^{
                            mViewImageUploadProgressContainer.hidden = true;
                            mBtnPhoto.enabled = true;
                        });
                        if ([obj1 isKindOfClass:[NSString class]]) {
                            [self sendMessage:[NSString stringWithFormat:@"%@.jpg", self.mFileNameToUpload] messageType:MESSAGE_TYPE_PHOTO];
                        }
                        else
                        {
                            [self.navigationController.view makeToast:@"Failed sending photo" duration:1.5 position:CSToastPositionTop];
                        }
                    }];
                    [mRequestsUploadPool addObject:uploader1];
                }
                else
                {
                    mViewImageUploadProgressContainer.hidden = true;
                    mBtnPhoto.enabled = true;
                    [self.navigationController.view makeToast:@"Failed sending photo" duration:1.5 position:CSToastPositionTop];
                }
            }];
            [mRequestsUploadPool addObject:uploader];
            
        }
        else {
            mBtnPhoto.enabled = true;
            [self.navigationController.view makeToast:@"Failed sending photo" duration:1.5 position:CSToastPositionTop];
        }
    });
}



#pragma mark -
#pragma mark - UITapGesture

- (IBAction)onTouchSendPhoto:(id)sender
{
    [mViewForChat endEditing:true];
    JMyActionSheet* actionSheet = [ [ JMyActionSheet alloc ] initWithTitle : @"Add Photo"
                                                                  delegate : self
                                                         cancelButtonTitle : @"Cancel"
                                                    destructiveButtonTitle : @"Camera"
                                                         otherButtonTitles : @"From Photo Library", nil ] ;
    [ actionSheet showInView : mTView] ;
}

#pragma mark - Action Sheet
- (void)actionSheet: (UIActionSheet *) _actionSheet clickedButtonAtIndex : (NSInteger) _buttonIndex
{
    if([_actionSheet.title isEqualToString: @"Add Photo"])
    {
        UIImagePickerController* pickerController = nil;
        
        switch(_buttonIndex)
        {
            case 0: // Camera ;
                if([UIImagePickerController isSourceTypeAvailable: UIImagePickerControllerSourceTypeCamera] == NO)
                {
                    return ;
                }
                [mViewForChat endEditing:YES];
                pickerController = [[UIImagePickerController alloc] init];
                pickerController.delegate  = self;
                pickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
                pickerController.cameraCaptureMode = UIImagePickerControllerCameraCaptureModePhoto;
                
                [self presentViewController: pickerController animated: YES completion: nil];
                [Engine setIsBackAction:YES];
                break ;
                
            case 1: // Photo ;
                [mViewForChat endEditing:YES];
                pickerController = [[UIImagePickerController alloc] init];
                pickerController.delegate = self;
                pickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
                
                [self presentViewController: pickerController animated: YES completion: nil];
                [Engine setIsBackAction:YES];
                break ;
                
            default :
                break ;
        }
    }
}

#pragma mark - Image Picker
- (void)imagePickerController: (UIImagePickerController *) _picker didFinishPickingMediaWithInfo: (NSDictionary *) _info
{
    NSURL *mediaUrl = (NSURL *)[_info valueForKey: UIImagePickerControllerMediaURL];
    
    if(mediaUrl == nil)
    {
        UIImage* img=[_info valueForKey: UIImagePickerControllerOriginalImage];
        
        [_picker dismissViewControllerAnimated : YES completion : ^{
            
        }];
        
        [self uploadMessagePhoto:img quality:0.75];
    }
}




#pragma mark -
#pragma mark - Touch Event
-(void)showFullPhoto:(JMessage*)message
{
    mFullPhoto.image=nil;
    [mViewForChat endEditing:YES];
    
    
    [mFullPhoto setImageWithURL:[[JAmazonS3ClientManager defaultManager] cdnUrlForMessagePhoto:message.message]];
    
    
    if([mFullPhotoView isHidden])
    {
        [mFullPhotoView setHidden:NO];
        mFullPhotoView.transform=CGAffineTransformMakeTranslation(mFullPhotoView.frame.size.width, 0);
        [UIView animateWithDuration:0.2f
                              delay:0.0f
                            options:UIViewAnimationOptionBeginFromCurrentState|UIViewAnimationOptionCurveEaseInOut
                         animations:^{
                             mFullPhotoView.transform=CGAffineTransformIdentity;
                         } completion:^(BOOL finished) {
                             
                         }];
    }
    
}

- (void)closeFullPhotoView: (id)sender
{
    [UIView animateWithDuration:0.2f
                          delay:0.0f
                        options:UIViewAnimationOptionBeginFromCurrentState|UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         mFullPhotoView.transform=CGAffineTransformMakeTranslation(mFullPhotoView.frame.size.width, 0);
                     } completion:^(BOOL finished) {
                         [mFullPhotoView setHidden:YES];
                     }];
}



@end
