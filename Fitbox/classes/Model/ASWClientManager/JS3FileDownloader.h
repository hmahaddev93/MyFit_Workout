//
//  SBS3FileDownloader.h
//  TwinPoint
//
//  Created by Khatib H. on 11/12/14.
//  
//

#import <Foundation/Foundation.h>
#import <AWSRuntime/AWSRuntime.h>

@interface JS3FileDownloader : NSOperation<AmazonServiceRequestDelegate>
@property (copy) J_DID_COMPLETE_CALL_BACK_BLOCK           completeBlock2;

- (id)initWithBucketName:(NSString *)bucketName fileKey:(NSString*)fileKey fileExtension:(NSString *)extension publicAccessAble:(BOOL)isPublic inProgressBlock:(J_IN_PROGRESS_CALL_BACK_BLOCK)progressBlock completedBlock:(J_DID_COMPLETE_CALL_BACK_BLOCK)completeBlock;
@end
