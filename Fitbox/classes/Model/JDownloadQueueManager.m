//
//  JDownloadQueueManager.m
//  TwinPoint
//
//  Created by Khatib H. on 3/12/15.
//  
//

#import "JDownloadQueueManager.h"
#import "JAmazonS3ClientManager.h"
@implementation JDownloadQueueManager
+ (id)defaultManager {
    static JDownloadQueueManager * instance = nil;
    if (!instance) {
        instance = [[JDownloadQueueManager alloc] init];
    }
    return instance;
}

-(id)init
{
    self.mDownloadArray = [[NSMutableArray alloc] init];
    self.mDownloadDict = [[NSMutableDictionary alloc] init];
    return self;
}
-(void)requestNewDownload:(NSString*)videoId
{
    if ([self checkCurrentlyDownloading:videoId]) {
    }
    else
    {
        [self.mDownloadArray addObject:videoId];
        [self.mDownloadDict setObject:videoId forKey:videoId];
        if([self.mDownloadArray count]==1)
        {
            [self startDownloading];
        }
    }
}

-(void)startDownloading
{
    if([self.mDownloadArray count]==0)
    {
        return;
    }
    NSString *mCurrentDownload = [self.mDownloadArray objectAtIndex:0];
    
//    [[JFeedInfo gDownloadDict] setObject:@"downloading" forKey:mCurrentDownload.mMedia];
    [[JAmazonS3ClientManager defaultManager] downloadVideoData:mCurrentDownload withProcessBlock:^(float progress) {
        NSLog(@"Progress: %f", progress);
    } completeBlock:^(NSString *obj) {
        if([obj isKindOfClass:[NSData class]])
        {
            NSData *mData=(NSData*)obj;
            [mData writeToFile:[JUtils getTemporaryURL:mCurrentDownload] atomically:YES];
            NSLog(@"Succeed: %@  Media Type: Video", mCurrentDownload);
        }
        else
        {
            NSLog(@"Error: %@  Media Type: Video", mCurrentDownload);
        }
        
        [self.mDownloadDict removeObjectForKey:mCurrentDownload];
        [self.mDownloadArray removeObject:mCurrentDownload];
        
        [[JDownloadQueueManager defaultManager] startDownloading];
//        [[JFeedInfo gDownloadDict] removeObjectForKey:self.mMedia];

    }];
    
}
-(BOOL)checkCurrentlyDownloading:(NSString*)videoId
{
    return [self.mDownloadDict objectForKey:videoId]!=nil;
}
@end
