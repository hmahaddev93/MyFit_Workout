//
//  JAmazonS3ClientManager.h
//  Zold
//
//  Created by Khatib H. on 9/2/14.
//  
//

#import <Foundation/Foundation.h>
#import <AWSS3/AWSS3.h>
#import "Constants.h"
#import "JS3FileUploader.h"
#import "JS3FileDownloader.h"


@interface JAmazonS3ClientManager : NSObject

+ (JAmazonS3ClientManager *)defaultManager;
- (AmazonS3Client *)client;
- (S3TransferManager *)tm;

#pragma mark cdn url methods

- (NSURL *)cdnUrlForItemPhoto:(NSString *)itemKey;
- (NSURL *)cdnUrlForItemPhotoThumb:(NSString *)itemKey;


- (NSURL *)cdnUrlForItemVideo:(NSString *)itemKey;
- (NSURL *)cdnUrlForItemVideoThumb:(NSString *)itemKey;

- (NSURL *)cdnUrlForProfilePhoto:(NSString *)itemKey;
- (NSURL *)cdnUrlForProfilePhotoThumb:(NSString *)itemKey;
- (NSURL *)cdnUrlForProfileBackground:(NSString *)itemKey;

- (NSURL *)cdnUrlForMessagePhoto:(NSString *)itemKey;
- (NSURL *)cdnUrlForMessagePhotoThumb:(NSString *)itemKey;

#pragma mark Methods for Pre-signed Url

#pragma mark Methods for Upload


- (JS3FileUploader *)uploadItemPhotoData:(NSData *)data fileKey:(NSString*)fileKey withProcessBlock:(J_IN_PROGRESS_CALL_BACK_BLOCK)progress completeBlock:(J_DID_COMPLETE_CALL_BACK_BLOCK)complete;

- (JS3FileUploader *)uploadItemPhotoThumbnailData:(NSData *)data fileKey:(NSString*)fileKey withProcessBlock:(J_IN_PROGRESS_CALL_BACK_BLOCK)progress completeBlock:(J_DID_COMPLETE_CALL_BACK_BLOCK)complete;

- (JS3FileUploader *)uploadItemVideoData:(NSData *)data fileKey:(NSString*)fileKey withProcessBlock:(J_IN_PROGRESS_CALL_BACK_BLOCK)progress completeBlock:(J_DID_COMPLETE_CALL_BACK_BLOCK)complete;

- (JS3FileUploader *)uploadItemVideoThumbnailData:(NSData *)data fileKey:(NSString*)fileKey withProcessBlock:(J_IN_PROGRESS_CALL_BACK_BLOCK)progress completeBlock:(J_DID_COMPLETE_CALL_BACK_BLOCK)complete;


- (JS3FileUploader *)uploadMessagePhotoData:(NSData *)data fileKey:(NSString*)fileKey withProcessBlock:(J_IN_PROGRESS_CALL_BACK_BLOCK)progress completeBlock:(J_DID_COMPLETE_CALL_BACK_BLOCK)complete;

- (JS3FileUploader *)uploadMessagePhotoThumbnailData:(NSData *)data fileKey:(NSString*)fileKey withProcessBlock:(J_IN_PROGRESS_CALL_BACK_BLOCK)progress completeBlock:(J_DID_COMPLETE_CALL_BACK_BLOCK)complete;


- (JS3FileUploader *)uploadProfilePhotoData:(NSData *)data fileKey:(NSString*)fileKey withProcessBlock:(J_IN_PROGRESS_CALL_BACK_BLOCK)progress completeBlock:(J_DID_COMPLETE_CALL_BACK_BLOCK)complete;

- (JS3FileUploader *)uploadProfilePhotoThumbnailData:(NSData *)data fileKey:(NSString*)fileKey withProcessBlock:(J_IN_PROGRESS_CALL_BACK_BLOCK)progress completeBlock:(J_DID_COMPLETE_CALL_BACK_BLOCK)complete;
- (JS3FileUploader *)uploadProfileBgPhotoData:(NSData *)data fileKey:(NSString*)fileKey withProcessBlock:(J_IN_PROGRESS_CALL_BACK_BLOCK)progress completeBlock:(J_DID_COMPLETE_CALL_BACK_BLOCK)complete;

- (JS3FileDownloader *)downloadVideoData:(NSString*)fileKey withProcessBlock:(J_IN_PROGRESS_CALL_BACK_BLOCK)progress completeBlock:(J_DID_COMPLETE_CALL_BACK_BLOCK)complete;

- (void)deleteFile:(NSString*)bucketName keyName:(NSString*)keyName;



@end
