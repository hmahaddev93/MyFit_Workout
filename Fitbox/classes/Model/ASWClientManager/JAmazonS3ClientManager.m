//
//  JAmazonS3ClientManager.m
//  Zold
//
//  Created by Khatib H. on 9/2/14.
//  
//

#import "JAmazonS3ClientManager.h"
#import "JS3FileUploader.h"
#import "Constants.h"


@interface JAmazonS3ClientManager (Private)

- (NSURL *)preSignedUrlForItem:(NSString *)itemKey itemType:(NSString *)type inBucket:(NSString *)bucket;

@end

@implementation JAmazonS3ClientManager
{
    NSOperationQueue *_mainQueue;
    AmazonS3Client *_s3Client;
    S3TransferManager *_s3TManager;
    
    NSMutableDictionary *_preSignedUrlDict;
}

static JAmazonS3ClientManager *_manager = nil;
+ (JAmazonS3ClientManager *)defaultManager
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _manager = [[JAmazonS3ClientManager alloc] init];
    });
    return _manager;
}

- (id)init
{
    if (self = [super init]) {
        _s3Client = [[AmazonS3Client alloc] initWithAccessKey:AWS_ACCESS_KEY_ID withSecretKey:AWS_SECRET_KEY];
        _mainQueue = [[NSOperationQueue alloc] init];
        _preSignedUrlDict = [[NSMutableDictionary alloc] init];
//        [self loadSavedPreSignedUrls];
    }
    return self;
}

- (AmazonS3Client *)client
{
    return _s3Client;
}
- (S3TransferManager *)tm
{
    return _s3TManager;
}

#pragma mark cdn url methods

//dme9ix4jr4arm.cloudfront.net   fitbox.photo.s3.amazonaws.com
//
//dzi53am79k9h.cloudfront.net    fitbox.photo.thumb.s3.amazonaws.com
//
//d3is8xvw6a8myj.cloudfront.net    fitbox.profile.bg.s3.amazonaws.com
//
//d2u28wjawbjsan.cloudfront.net    fitbox.profile.photo.s3.amazonaws.com
//
//dfutcwclslauk.cloudfront.net     fitbox.profile.photo.thumb.s3.amazonaws.com
//
//drd9lscllos0m.cloudfront.net      fitbox.video.s3.amazonaws.com
//
//d1ru8cpl9l7c2g.cloudfront.net     fitbox.video.thumb.s3.amazonaws.com
//
//d1ssizpgnomgrd.cloudfront.net      fitbox.message.photo.s3.amazonaws.com
//
//d9oy34ri4qtrt.cloudfront.net       fitbox.message.photo.thumb.s3.amazonaws.com


//Second One is the New Amazon CDN URLs

- (NSURL *)cdnUrlForItemPhoto:(NSString *)itemKey
{
//    return [NSURL URLWithString:[NSString stringWithFormat:@"http://d37udvqqaz64vn.cloudfront.net/%@.jpg", itemKey]];
    return [NSURL URLWithString:[NSString stringWithFormat:@"http://dme9ix4jr4arm.cloudfront.net/%@", itemKey]];
}
- (NSURL *)cdnUrlForItemPhotoThumb:(NSString *)itemKey
{
//    return [NSURL URLWithString:[NSString stringWithFormat:@"http://d88sjs3b5zzuh.cloudfront.net/%@.jpg", itemKey]];
    return [NSURL URLWithString:[NSString stringWithFormat:@"http://dzi53am79k9h.cloudfront.net/%@", itemKey]];
}
- (NSURL *)cdnUrlForItemVideo:(NSString *)itemKey
{
//    return [NSURL URLWithString:[NSString stringWithFormat:@"http://d88sjs3b5zzuh.cloudfront.net/%@.jpg", itemKey]];
    return [NSURL URLWithString:[NSString stringWithFormat:@"http://drd9lscllos0m.cloudfront.net/%@", itemKey]];
}
- (NSURL *)cdnUrlForItemVideoThumb:(NSString *)itemKey
{
//    return [NSURL URLWithString:[NSString stringWithFormat:@"http://ds52dwkoraiak.cloudfront.net/%@.jpg", itemKey]];
    return [NSURL URLWithString:[NSString stringWithFormat:@"http://d1ru8cpl9l7c2g.cloudfront.net/%@", itemKey]];
}


- (NSURL *)cdnUrlForMessagePhoto:(NSString *)itemKey
{
    return [NSURL URLWithString:[NSString stringWithFormat:@"http://d1ssizpgnomgrd.cloudfront.net/%@", itemKey]];
}
- (NSURL *)cdnUrlForMessagePhotoThumb:(NSString *)itemKey
{
    return [NSURL URLWithString:[NSString stringWithFormat:@"http://d9oy34ri4qtrt.cloudfront.net/%@", itemKey]];
}



- (NSURL *)cdnUrlForProfilePhoto:(NSString *)itemKey
{
    return [NSURL URLWithString:[NSString stringWithFormat:@"http://d2u28wjawbjsan.cloudfront.net/%@", itemKey]];
}
- (NSURL *)cdnUrlForProfilePhotoThumb:(NSString *)itemKey
{
    return [NSURL URLWithString:[NSString stringWithFormat:@"http://d2u28wjawbjsan.cloudfront.net/%@", itemKey]];
//    return [NSURL URLWithString:[NSString stringWithFormat:@"http://dfutcwclslauk.cloudfront.net/%@.jpg", itemKey]];
}
- (NSURL *)cdnUrlForProfileBackground:(NSString *)itemKey
{
    return [NSURL URLWithString:[NSString stringWithFormat:@"http://d3is8xvw6a8myj.cloudfront.net/%@", itemKey]];
}
#pragma mark Methods for Pre-signed Url

- (NSString *)urlLocalFilePath
{
    return [NSString stringWithFormat:@"%@preSignedUrls.plist", NSTemporaryDirectory()];
}

- (void)loadSavedPreSignedUrls
{
    NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:[self urlLocalFilePath]];
    if (dict) {
        [_preSignedUrlDict setDictionary:dict];
    }
}

- (void)savePreSignedUrls
{
    [_preSignedUrlDict writeToFile:[self urlLocalFilePath] atomically:NO];
}

- (NSURL *)preSignedUrlForItem:(NSString *)itemKey itemType:(NSString *)type inBucket:(NSString *)bucket
{
    if (!itemKey) {
        return nil;
    }
    if ([_preSignedUrlDict objectForKey:itemKey]) {
        return [NSURL URLWithString:[_preSignedUrlDict objectForKey:itemKey]];
    }
    S3ResponseHeaderOverrides *override = [[S3ResponseHeaderOverrides alloc] init];
    override.contentType = type;
    S3GetPreSignedURLRequest *gpsur = [[S3GetPreSignedURLRequest alloc] init];
    gpsur.key     = itemKey;
    gpsur.bucket  = bucket;
    gpsur.expires = [NSDate dateWithTimeIntervalSinceNow:(NSTimeInterval) 3600 * 24 * 30 * 120];  // keep alive for ten years
    gpsur.responseHeaderOverrides = override;
    NSURL *url = [_s3Client getPreSignedURL:gpsur];
    [_preSignedUrlDict setObject:url.absoluteString forKey:itemKey];
    [self savePreSignedUrls];
    //NSLog(@"presigned url for type : %@ \n %@",type, url.description);
    return url;
}

- (NSURL *)preSignedUrlForPostPhoto:(NSString *)itemKey
{
    return [self preSignedUrlForItem:itemKey itemType:@"image/jpeg" inBucket:J_ITEM_PHOTO_LIB_BUCKET];
}

#pragma mark Methods for Delete

- (void)deleteFile:(NSString*)bucketName keyName:(NSString*)keyName
{
    [_s3Client deleteObjectWithKey:keyName withBucket:bucketName];
//    s3Clie
}
                                       
#pragma mark Methods for Upload


- (JS3FileUploader *)uploadItemPhotoData:(NSData *)data fileKey:(NSString*)fileKey withProcessBlock:(J_IN_PROGRESS_CALL_BACK_BLOCK)progress completeBlock:(J_DID_COMPLETE_CALL_BACK_BLOCK)complete
{
    return [self uploadData:data bucketName:J_ITEM_PHOTO_LIB_BUCKET fileKey:fileKey inProgress:progress completed:complete];
}

- (JS3FileUploader *)uploadItemPhotoThumbnailData:(NSData *)data fileKey:(NSString*)fileKey withProcessBlock:(J_IN_PROGRESS_CALL_BACK_BLOCK)progress completeBlock:(J_DID_COMPLETE_CALL_BACK_BLOCK)complete
{
    return [self uploadData:data bucketName:J_ITEM_PHOTO_THUMB_LIB_BUCKET fileKey:fileKey inProgress:progress completed:complete];
}


- (JS3FileUploader *)uploadItemVideoData:(NSData *)data fileKey:(NSString*)fileKey withProcessBlock:(J_IN_PROGRESS_CALL_BACK_BLOCK)progress completeBlock:(J_DID_COMPLETE_CALL_BACK_BLOCK)complete
{
    return [self uploadData:data bucketName:J_ITEM_VIDEO_LIB_BUCKET fileKey:fileKey inProgress:progress completed:complete];
}

- (JS3FileUploader *)uploadItemVideoThumbnailData:(NSData *)data fileKey:(NSString*)fileKey withProcessBlock:(J_IN_PROGRESS_CALL_BACK_BLOCK)progress completeBlock:(J_DID_COMPLETE_CALL_BACK_BLOCK)complete
{
    return [self uploadData:data bucketName:J_ITEM_VIDEO_THUMB_LIB_BUCKET fileKey:fileKey inProgress:progress completed:complete];
}


- (JS3FileUploader *)uploadMessagePhotoData:(NSData *)data fileKey:(NSString*)fileKey withProcessBlock:(J_IN_PROGRESS_CALL_BACK_BLOCK)progress completeBlock:(J_DID_COMPLETE_CALL_BACK_BLOCK)complete
{
    return [self uploadData:data bucketName:J_MESSAGE_PHOTO_LIB_BUCKET fileKey:fileKey inProgress:progress completed:complete];
}

- (JS3FileUploader *)uploadMessagePhotoThumbnailData:(NSData *)data fileKey:(NSString*)fileKey withProcessBlock:(J_IN_PROGRESS_CALL_BACK_BLOCK)progress completeBlock:(J_DID_COMPLETE_CALL_BACK_BLOCK)complete
{
    return [self uploadData:data bucketName:J_MESSAGE_PHOTO_THUMB_LIB_BUCKET fileKey:fileKey inProgress:progress completed:complete];
}



- (JS3FileUploader *)uploadProfilePhotoData:(NSData *)data fileKey:(NSString*)fileKey withProcessBlock:(J_IN_PROGRESS_CALL_BACK_BLOCK)progress completeBlock:(J_DID_COMPLETE_CALL_BACK_BLOCK)complete
{
    return [self uploadData:data bucketName:J_PROFILE_PHOTO_LIB_BUCKET fileKey:fileKey inProgress:progress completed:complete];
}

- (JS3FileUploader *)uploadProfilePhotoThumbnailData:(NSData *)data fileKey:(NSString*)fileKey withProcessBlock:(J_IN_PROGRESS_CALL_BACK_BLOCK)progress completeBlock:(J_DID_COMPLETE_CALL_BACK_BLOCK)complete
{
    return [self uploadData:data bucketName:J_PROFILE_PHOTO_THUMB_LIB_BUCKET fileKey:fileKey inProgress:progress completed:complete];
}
- (JS3FileUploader *)uploadProfileBgPhotoData:(NSData *)data fileKey:(NSString*)fileKey withProcessBlock:(J_IN_PROGRESS_CALL_BACK_BLOCK)progress completeBlock:(J_DID_COMPLETE_CALL_BACK_BLOCK)complete
{
    return [self uploadData:data bucketName:J_PROFILE_BG_LIB_BUCKET fileKey:fileKey inProgress:progress completed:complete];
}

- (JS3FileUploader *)uploadData:(NSData *)data bucketName:(NSString *)bucketName fileKey:(NSString*)fileKey inProgress:(J_IN_PROGRESS_CALL_BACK_BLOCK)progress completed:(J_DID_COMPLETE_CALL_BACK_BLOCK)completed
{
    if (!data || !data.length) {
/*        if (completed) {
            completed([NSError errorWithDomain:@"www.lognllc.com" code:-1 userInfo:nil]);
        }*/
        return nil;
    }
    NSString *extension = [bucketName isEqualToString:J_ITEM_VIDEO_LIB_BUCKET] ? @"mp4" : @"jpg";
//    NSString *extension =@"jpg";
    JS3FileUploader *uploader = [[JS3FileUploader alloc] initWithData:data bucketName:bucketName fileKey:fileKey fileExtension:extension publicAccessAble:YES inProgressBlock:progress completedBlock:completed];
    [_mainQueue addOperation:uploader];
    return uploader;
}



- (JS3FileDownloader *)downloadVideoData:(NSString*)fileKey withProcessBlock:(J_IN_PROGRESS_CALL_BACK_BLOCK)progress completeBlock:(J_DID_COMPLETE_CALL_BACK_BLOCK)complete
{
//    if([mediaType isEqualToString:MEDIA_TYPE_PHOTO])
//    {
//        return [self downloadData:J_POST_PHOTO_LIB_BUCKET fileKey:fileKey inProgress:progress completed:complete];
//    }
    return [self downloadData:J_ITEM_VIDEO_LIB_BUCKET fileKey:fileKey inProgress:progress completed:complete];
}
//- (JS3FileDownloader *)downloadPhotoData:(NSString*)fileKey withProcessBlock:(J_IN_PROGRESS_CALL_BACK_BLOCK)progress completeBlock:(J_DID_COMPLETE_CALL_BACK_BLOCK)complete
//{
//    return [self downloadData:J_POST_PHOTO_LIB_BUCKET fileKey:fileKey inProgress:progress completed:complete];
//}
- (JS3FileDownloader *)downloadData:(NSString *)bucketName fileKey:(NSString*)fileKey inProgress:(J_IN_PROGRESS_CALL_BACK_BLOCK)progress completed:(J_DID_COMPLETE_CALL_BACK_BLOCK)completed
{
    NSString *extension = [bucketName isEqualToString:J_ITEM_VIDEO_LIB_BUCKET] ? @"mp4" : @"jpg";
    NSArray *mArr = [fileKey componentsSeparatedByString:@"."];
    if ([mArr count]>1) {
        extension = [mArr lastObject];
        NSMutableArray *mNewArr = [[NSMutableArray alloc] initWithArray:mArr];
        [mNewArr removeLastObject];
        fileKey = [mNewArr componentsJoinedByString:@"."];
    }
    JS3FileDownloader *downloader=[[JS3FileDownloader alloc] initWithBucketName:bucketName fileKey:fileKey fileExtension:extension publicAccessAble:YES inProgressBlock:progress completedBlock:completed];
    [_mainQueue addOperation:downloader];
    return downloader;
}


@end
