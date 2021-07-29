//
//  JS3FileUploader.h
//  Zold
//
//  Created by Khatib H. on 9/2/14.
//  
//

#import <Foundation/Foundation.h>
#import <AWSRuntime/AWSRuntime.h>
#import "Constants.h"

@interface JS3FileUploader : NSOperation<AmazonServiceRequestDelegate>
{
    
}
@property (copy) J_DID_COMPLETE_CALL_BACK_BLOCK           completeBlock2;

- (id)initWithData:(NSData *)data bucketName:(NSString *)bucketName fileKey:(NSString*)fileKey fileExtension:(NSString *)extension publicAccessAble:(BOOL)isPublic inProgressBlock:(J_IN_PROGRESS_CALL_BACK_BLOCK)progressBlock completedBlock:(J_DID_COMPLETE_CALL_BACK_BLOCK)completeBlock;

@end
