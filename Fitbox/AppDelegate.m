//
//  AppDelegate.m
//  Fitbox
//
//  Created by Khatib H. on 11/8/15.
//  
//

#import "AppDelegate.h"
#import "JPushAlertView.h"
#import "JSingleViewController.h"
#import "JPushMethods.h"

#import "Stripe.h"
#import <AVFoundation/AVFoundation.h>

//@import CoreLocation;
//@import SystemConfiguration;
//@import AVFoundation;
//@import ImageIO;

#import <OneSignal/OneSignal.h>

@interface AppDelegate ()//<PushNotificationDelegate>
{
    NSTimer *timerListingCount;
}

@end

@implementation AppDelegate

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;




- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
//    [Stripe setDefaultPublishableKey:STRIPE_PUBLISHABLE_KEY_TEST];
    [Stripe setDefaultPublishableKey:STRIPE_PUBLISHABLE_KEY_LIVE];
    
    [application registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeSound | UIUserNotificationTypeAlert | UIUserNotificationTypeBadge) categories:nil]];
    [application registerForRemoteNotifications];

    [UINavigationBar appearance].barTintColor = [UIColor whiteColor];
    [UINavigationBar appearance].tintColor = [UIColor blackColor];
    [UINavigationBar appearance].titleTextAttributes = [NSDictionary dictionaryWithObjectsAndKeys: [UIColor blackColor], NSForegroundColorAttributeName, [UIFont fontWithName:FONT_NAME_LULO_CLEAN size:13], NSFontAttributeName,  nil];

    

    [[UIBarButtonItem appearance] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys: [UIFont fontWithName:FONT_NAME_AAUX_PROREGULAR size:11], NSFontAttributeName, nil] forState:UIControlStateNormal];
    [UITabBar appearance].tintColor = MAIN_COLOR_PINK;
//    [[UIView appearanceWhenContainedIn:[UITabBar class], nil] setTintColor:[UIColor blackColor]];
//    [UITabBar appearance].selectedImageTintColor
//    [UITabBar appearance].barTintColor = [UIColor bla];
    
    NSString* documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *dataPath = [documentsPath stringByAppendingPathComponent:@"/media"];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:dataPath])
        [[NSFileManager defaultManager] createDirectoryAtPath:dataPath withIntermediateDirectories:NO attributes:nil error:nil];
    
    [Engine setMyLocation: CLLocationCoordinate2DMake(0.0, 0.0)];
    [self setupLocationService:nil];
    
    NSError *sessionError = nil;
    NSError *activationError = nil;
    [[AVAudioSession sharedInstance] setCategory: AVAudioSessionCategoryPlayback error:&sessionError];
    [[AVAudioSession sharedInstance] setActive: YES error: &activationError];
    
    [self createListingTimer];
    
    
//    [OneSignal setLogLevel:ONE_S_LL_DEBUG visualLevel:ONE_S_LL_DEBUG];
    [OneSignal initWithLaunchOptions:launchOptions appId:ONESIGNAL_APP_ID];
    
    
    [OneSignal IdsAvailable:^(NSString* userId, NSString* pushToken) {
        NSLog(@"UserId:%@", userId);
        [Engine setGPushId:userId];
        [APIClient registerPush];
        if (pushToken != nil)
            NSLog(@"pushToken:%@", pushToken);
    }];
    
//    
//    //-----------PUSHWOOSH PART-----------
//    // set custom delegate for push handling, in our case - view controller
//    PushNotificationManager * pushManager = [PushNotificationManager pushManager];
//    pushManager.delegate = self;
//    
//    // handling push on app start
//    [[PushNotificationManager pushManager] handlePushReceived:launchOptions];
//    
//    // make sure we count app open in Pushwoosh stats
//    [[PushNotificationManager pushManager] sendAppOpen];
//    
//    // register for push notifications!
//    [[PushNotificationManager pushManager] registerForPushNotifications];
    
    
    
    return YES;
}
-(void)destroyListingTimer
{
    if (timerListingCount) {
        [timerListingCount invalidate];
        timerListingCount = nil;
    }
}
-(void)createListingTimer
{
    [self destroyListingTimer];
    timerListingCount = [NSTimer scheduledTimerWithTimeInterval:60*60 target:self selector:@selector(timerListingCountAction) userInfo:nil repeats:true];
//    timerListingCount = [NSTimer scheduledTimerWithTimeInterval:10.0 target:self selector:@selector(timerListingCountAction) userInfo:nil repeats:true];
}
-(void)timerListingCountAction
{
    [APIClient checkListingCount];
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    [self destroyListingTimer];
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    [self createListingTimer];
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
//    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
//    if (currentInstallation.badge != 0) {
//        currentInstallation.badge = 0;
//        [currentInstallation saveEventually];
//    }
    
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    NSLog(@"didRegisterForRemoteNotificationsWithDeviceToken: %@",deviceToken);
//    [[PushNotificationManager pushManager] handlePushRegistration:deviceToken];
}
//
// system push notification registration error callback, delegate to pushManager
- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
//    [[PushNotificationManager pushManager] handlePushRegistrationFailure:error];
    NSLog(@"didRegisterForRemoteNotificationsWithDeviceToken: %@",error);
}
//
//// system push notifications callback, delegate to pushManager
//- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
//    [[PushNotificationManager pushManager] handlePushReceived:userInfo];
//}

-(void)setupLocationService:(id)sender
{
    [Engine setLocationManager:[[CLLocationManager alloc] init]];
    [Engine locationManager].distanceFilter=200.0f;
    
#ifdef __IPHONE_8_0
    if(IS_OS_8_OR_LATER) {
        [[Engine locationManager] requestWhenInUseAuthorization];
    }
#endif
    [Engine locationManager].desiredAccuracy=kCLLocationAccuracyKilometer;
    [Engine locationManager].delegate=self;
    [[Engine locationManager] startUpdatingLocation];
}


- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    CLLocation *currentLocation = [locations objectAtIndex:0];
    //    myLocation=currentLocation.coordinate;
    [Engine setMyLocation :currentLocation.coordinate];
}


-(void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    NSLog(@"Location Error : %@",error);
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}



- (void)application:(UIApplication *)application didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings
{
    //register to receive notifications
    //    [application registerForRemoteNotifications];
}

- (void)application:(UIApplication *)application handleActionWithIdentifier:(NSString *)identifier forRemoteNotification:(NSDictionary *)userInfo completionHandler:(void(^)())completionHandler
{
    if([Engine gStatusForPush])
    {
        if(application.applicationState==UIApplicationStateInactive)
        {
        }
        else
        {
            [JPushMethods handlePushUserInfo:userInfo withAlertDelegate:self];
        }
    }
    
}

//
//- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo{
//    if([Engine gStatusForPush])
//    {
//        
//        if(application.applicationState==UIApplicationStateInactive)
//        {
//        }
//        else
//        {
//            [JPushMethods handlePushUserInfo:userInfo withAlertDelegate:self];
//        }
//    }
//}





#pragma mark UIAlertDelegate & handle methods for push notification

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0 || ![alertView isKindOfClass:[JPushAlertView class]] /*|| !_tabBarController*/) {
        return;
    }
    JPushAlertView *pushAlert = (JPushAlertView *)alertView;
    NSDictionary *userInfo = pushAlert.pushUserInfo;
    NSString* mNotifType = [userInfo objectForKey:kPushType];
}

- (void)saveContext
{
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}


#pragma mark - Core Data stack

// Returns the managed object context for the application.
// If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
- (NSManagedObjectContext *)managedObjectContext
{
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        _managedObjectContext = [[NSManagedObjectContext alloc] init];
        [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    return _managedObjectContext;
}

// Returns the managed object model for the application.
// If the model doesn't already exist, it is created from the application's model.
- (NSManagedObjectModel *)managedObjectModel
{
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"Data" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

// Returns the persistent store coordinator for the application.
// If the coordinator doesn't already exist, it is created and the application's store added to it.
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"Fitbox.sqlite"];
    NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:
                             [NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption,
                             [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption, nil];
    NSError *error = nil;
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:options error:&error]) {
        /*
         Replace this implementation with code to handle the error appropriately.
         
         abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
         
         Typical reasons for an error here include:
         * The persistent store is not accessible;
         * The schema for the persistent store is incompatible with current managed object model.
         Check the error message to determine what the actual problem was.
         
         
         If the persistent store is not accessible, there is typically something wrong with the file path. Often, a file URL is pointing into the application's resources directory instead of a writeable directory.
         
         If you encounter schema incompatibility errors during development, you can reduce their frequency by:
         * Simply deleting the existing store:
         [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil]
         
         * Performing automatic lightweight migration by passing the following dictionary as the options parameter:
         @{NSMigratePersistentStoresAutomaticallyOption:@YES, NSInferMappingModelAutomaticallyOption:@YES}
         
         Lightweight migration will only work for a limited set of schema changes; consult "Core Data Model Versioning and Data Migration Programming Guide" for details.
         
         */
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return _persistentStoreCoordinator;
}


#pragma mark - Application's Documents directory

// Returns the URL to the application's Documents directory.
- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}



@end
