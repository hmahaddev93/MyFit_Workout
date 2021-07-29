//
//  JS3FileDownloader.m
//  TwinPoint
//
//  Created by Khatib H. on 11/12/14.
//  
//

#import "JS3FileDownloader.h"
#import "JAmazonS3ClientManager.h"

@implementation JS3FileDownloader
{
    BOOL           _isExecuting;
    BOOL           _isFinished;
    
    J_DID_COMPLETE_CALL_BACK_BLOCK _completeBlock2;
    
    J_IN_PROGRESS_CALL_BACK_BLOCK _progressBlock;
    
    NSString *_bucketName;
    NSString *_keyName;
    NSString *_fileKey;
    NSString *_fileExtension;
    BOOL _needPublicAccess;
}
@synthesize completeBlock2=_completeBlock2;

- (id)initWithBucketName:(NSString *)bucketName fileKey:(NSString*)fileKey fileExtension:(NSString *)extension publicAccessAble:(BOOL)isPublic inProgressBlock:(J_IN_PROGRESS_CALL_BACK_BLOCK)progressBlock completedBlock:(J_DID_COMPLETE_CALL_BACK_BLOCK)completeBlock
{
    if (self = [super init]) {
        _isExecuting = NO;
        _isFinished = NO;
        
        _progressBlock = progressBlock;
        //        _completeBlock11 = completeBlock;
        [self setCompleteBlock2:completeBlock];
        _bucketName = bucketName;
        _fileKey=fileKey;
        _fileExtension = extension;
        _needPublicAccess = isPublic;
        _keyName = [NSString stringWithFormat:@"%@.%@",fileKey, _fileExtension];
    }
    return self;
}


-(void)start
{
    if (![NSThread isMainThread])
    {
        [self performSelectorOnMainThread:@selector(start) withObject:nil waitUntilDone:NO];
        return;
    }
    
    [self willChangeValueForKey:@"isExecuting"];
    _isExecuting = YES;
    [self didChangeValueForKey:@"isExecuting"];
    
    S3GetObjectRequest *getObjectRequest = [[S3GetObjectRequest alloc] initWithKey:_keyName withBucket:_bucketName];
    //    getObjectRequest.delegate=
    //    if([_fileExtension isEqualToString:@"jpg"])
    //        getObjectRequest.contentType=@"image/jpeg";
    //    else// if([_fileExtension isEqualToString:@"acc"])
    //        getObjectRequest.contentType=@"audio/mpeg";
    
    getObjectRequest.delegate=self;
    [[[JAmazonS3ClientManager defaultManager] client] getObject:getObjectRequest];
}

-(BOOL)isConcurrent
{
    return YES;
}

-(BOOL)isExecuting
{
    return _isExecuting;
}

-(BOOL)isFinished
{
    return _isFinished;
}

#pragma mark - AmazonServiceRequestDelegate Implementations


-(void)request:(AmazonServiceRequest *)request didSendData:(long long)bytesWritten totalBytesWritten:(long long)totalBytesWritten totalBytesExpectedToWrite:(long long)totalBytesExpectedToWrite
{
    if (_progressBlock) {
        _progressBlock((float)totalBytesWritten / (float)totalBytesExpectedToWrite);
    }
}
-(void)request:(AmazonServiceRequest *)request didCompleteWithResponse:(AmazonServiceResponse *)response
{
    //    NSData *theData=response.body;
    //    [theData writeToFile:[Engine getTemporaryURLFromVideoId:_fileKey] atomically:YES];
    //    S3GetObjectResponse *response=(S3get);
    //    response.
    
    if (_completeBlock2) {
        _completeBlock2((NSString*)response.body);
    }
    [self finish];
}


-(void)request:(AmazonServiceRequest *)request didFailWithError:(NSError *)error
{
    NSLog(@"%@", error);
    if (_completeBlock2) {
        _completeBlock2((NSString*)error);
    }
    [self finish];
}

-(void)request:(AmazonServiceRequest *)request didFailWithServiceException:(NSException *)exception
{
    NSLog(@"%@", exception);
    if (_completeBlock2) {
        _completeBlock2((NSString*)exception);
        //        _completeBlock11(34);
    }
    [self finish];
}

#pragma mark - Helper Methods

-(void)finish
{
    [self willChangeValueForKey:@"isExecuting"];
    [self willChangeValueForKey:@"isFinished"];
    
    _isExecuting = NO;
    _isFinished  = YES;
    
    [self didChangeValueForKey:@"isExecuting"];
    [self didChangeValueForKey:@"isFinished"];
    
    _bucketName = nil;
    _keyName = nil;
    _completeBlock2 = nil;
    _progressBlock = nil;
    _fileKey=nil;
}

@end
