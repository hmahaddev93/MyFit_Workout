//
//  JDownloadQueueManager.h
//  TwinPoint
//
//  Created by Khatib H. on 3/12/15.
//  
//

#import <Foundation/Foundation.h>

@interface JDownloadQueueManager : NSObject

@property (nonatomic, retain) NSMutableDictionary    *mDownloadDict;
@property (nonatomic, retain) NSMutableArray    *mDownloadArray;

-(void)requestNewDownload:(NSString*)videoId;


+ (JDownloadQueueManager*)defaultManager;

-(id)init;
-(void)startDownloading;
-(BOOL)checkCurrentlyDownloading:(NSString*)videoId;
@end
