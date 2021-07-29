//
//  AppEngine.m
//  Zold
//
//  Created by Khatib H. on 9/2/14.
//  

#import "AppEngine.h"

#import "NSData+Base64.h"

@implementation AppEngine

@synthesize languages       = _languages;
@synthesize currentLang     = _currentLang;
@synthesize currentBundle   = _currentBundle;


@synthesize gSrvTime        = _gSrvTime;
@synthesize gSearchEth      = _gSearchEth;

@synthesize isFirstRun;

#pragma mark singleton

+ (id)getInstance {
    static AppEngine * instance = nil;
    if (!instance) {
        instance = [[AppEngine alloc] init];


    }
    return instance;
}

#pragma mark getters/setters

- (void)setCurrentLang:(NSString *)lang {
    _currentLang = lang;
    _currentBundle = [[NSBundle alloc] initWithPath:[[NSBundle mainBundle] pathForResource:self.currentLang ofType:@"lproj"]];
    
    [[NSUserDefaults standardUserDefaults] setObject:self.currentLang forKey:kUserDefaultsCurrentLanguageKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}


#pragma mark init

- (id)init {
    if (self = [super init]) {
        self.languages = kLanguages;
        NSString * lang = [[NSUserDefaults standardUserDefaults] valueForKey:kUserDefaultsCurrentLanguageKey];
        self.currentLang = lang ? lang : kDefaultLanguage;
        
//        self.gPersonsDict=[[NSMutableDictionary alloc] init];
//        self.gListingsDict=[[NSMutableDictionary alloc] init];
        self.gShoppingCart=[[NSMutableArray alloc] init];
        
//        self.gChatHistoryDictWithID = [[NSMutableDictionary alloc] init];
//        self.gChatHistoryDictWithRoom = [[NSMutableDictionary alloc] init];
        

//        _gFeedDict=[[NSMutableDictionary alloc] init];
//        _gFeedList=[[NSMutableArray alloc] init];
        _gSearchResult=[[NSMutableArray alloc] init];

        _gSizeList=@[@"XS", @"S", @"M", @"L", @"XL"];
        _gSoundCloudPlayLists = [[NSMutableArray alloc] init];
        _gSoundCloudPlayDict = [[NSMutableDictionary alloc] init];

        self.likeItems=[[NSMutableArray alloc] init];
        
        self.gFlashDict=[[NSMutableDictionary alloc] init];
        self.gSizeInfo=[[NSMutableDictionary alloc] initWithDictionary:@{SIZE_TOPS:@"L", SIZE_BOTTOMS:@"L"}];
        
        self.isFirstRun=YES;
        
        self.WISH_LIST_NEED_UPDATE=YES;
        self.gStatusForPush=NO;
        self.newMessage=0;

        self.gColorList=[[NSArray alloc] initWithObjects:@"Red", @"#ff0000", @"Purple", @"#9103ff", @"Orange", @"#ffb006", @"Black", @"#000000", @"Yellow", @"#fbff07", @"White", @"#ffffff", @"Camo", @"#12345", @"Gray", @"#818181", @"Green", @"#39bf1f", @"Tan", @"#d0b590" , @"Olive", @"#5d6d54", @"Gold", @"d4af37", @"Navy", @"#241782", @"Silver", @"#dad8d6", nil];

    }
    return self;
}

-(void)saveInfoToUserDefault
{
    if (![[JUser me] isAuthorized]) {
        return;
    }
    NSMutableDictionary *mDict = [[NSMutableDictionary alloc] init];
    
    if (_gCreditCard) {
        [mDict setObject:[_gCreditCard toDictionary] forKey:@"creditInfo"];
    }
    if (_gAddress) {
        [mDict setObject:[_gAddress toDictionary] forKey:@"addressInfo"];
    }
    if (_gSizeInfo) {
        [mDict setObject:_gSizeInfo forKey:SIZE_INFO];
    }

    [[NSUserDefaults standardUserDefaults] setObject:mDict forKey:[JUser me]._id];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

-(void)loadInfoFromUserDefaults
{
    if (![[JUser me] isAuthorized]) {
        return;
    }
    
    NSDictionary *mDict = (NSDictionary*)[[NSUserDefaults standardUserDefaults] objectForKey:[JUser me]._id];

    if ([mDict objectForKey:@"creditInfo"]) {
        _gCreditCard = [[JCreditCardInfo alloc] init];
        [_gCreditCard setWithDictionary:[mDict objectForKey:@"creditInfo"]];
    }
    
    if ([mDict objectForKey:@"addressInfo"]) {
        _gAddress = [[JAddressInfo alloc] init];
        [_gAddress setWithDictionary:[mDict objectForKey:@"addressInfo"]];
    }
    
    if ([mDict objectForKey:SIZE_INFO]) {
        _gSizeInfo = [[NSMutableDictionary alloc] initWithDictionary:[mDict objectForKey:SIZE_INFO]];
    }
}


-(void)actionAfterLogin
{
    [self loadInfoFromUserDefaults];
}
-(void)actionAfterLogout
{
    _gCreditCard = nil;
    _gAddress = nil;
}

#pragma mark memory management

- (void)dealloc {
}

#pragma mark -
#pragma mark BLL general

- (void)setValue:(id)value forKey:(NSString *)key {
    [[NSUserDefaults standardUserDefaults] setValue:value forKey:key];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (id)valueForKey:(NSString *)key {
    return [[NSUserDefaults standardUserDefaults] valueForKey:key];
}

#pragma mark -
#pragma mark - Base64

- (NSString *)base64Encode:(NSString *)plainText
{
    NSData *plainTextData = [plainText dataUsingEncoding:NSUTF8StringEncoding];
    NSString *base64String = [plainTextData base64EncodedString];
    return base64String;
}

- (NSString *)base64Decode:(NSString *)base64String
{
    NSData *plainTextData = [NSData dataFromBase64String:base64String];
    NSString *plainText = [[NSString alloc] initWithData:plainTextData encoding:NSUTF8StringEncoding];
    return plainText;
}













+ (UIColor *) colorFromString:(NSString *)colorStr
{
    NSScanner *scanner=[NSScanner scannerWithString:colorStr];
    unsigned int colorInt;
    [scanner setScanLocation:1];
    [scanner scanHexInt:&colorInt];
    UIColor *color=[UIColor colorWithRed:colorInt/256/256/255.0 green:((colorInt/256)%256)/255.0 blue:(colorInt%256)/255.0
                                   alpha:1.0];
    return color;
}



+ (NSURL *)testingLocalMovieUrl
{
    return [NSURL fileURLWithPath:@"/Users/Eric/Desktop/testvideo/video.mov"];
}

+ (NSURL *)testingLocalAudioUrl
{
    return [NSURL fileURLWithPath:@"/Users/Eric/Desktop/testvideo/audio.wav"];
}

#pragma mark Reachability methods

- (void)checkNetworkReachability
{
}

- (void) reachabilityChanged: (NSNotification* )note
{
//    NSLog(@"reachabilityChanged");
}

#pragma mark methods for current user

-(void)showAlertViewForLogin
{
    UIAlertView *mAlertView=[[UIAlertView alloc] initWithTitle:APP_NAME message:@"Please sign up to get your Fitbox account to access" delegate:self cancelButtonTitle:@"No, Thanks" otherButtonTitles:@"Login/Signup", nil];
    [mAlertView show];
}
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(buttonIndex==1)
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:BACK_TO_LOGIN_VIEW object:nil];
    }
}
@end

