//
//  DownloadOperation.h
//  download demo
//
//  Created by 翟泉 on 2016/7/30.
//  Copyright © 2016年 云之彼端. All rights reserved.
//

#import <Foundation/Foundation.h>

@class DownloadOperation;

@interface NSURLSessionTask (__Download)

@property (weak, nonatomic, nullable) DownloadOperation *operation;

@end


typedef NS_ENUM(NSInteger, DownloadOperationStatus) {
    DownloadOperationStatusNone,
    DownloadOperationStatusWaiting,
    DownloadOperationStatusRuning,
    DownloadOperationStatusPause,
    DownloadOperationStatusSuccess,
    DownloadOperationStatusFailure,
};

@interface DownloadOperation : NSObject

@property (strong, nonatomic, readonly, nonnull) NSURL *url;

@property (assign, nonatomic, readonly) unsigned long long countOfBytesReceived;

@property (assign, nonatomic, readonly) unsigned long long countOfBytesExpectedToReceive;


+ (nonnull instancetype)operationWithURL:(nonnull NSURL *)url urlSession:(nonnull NSURLSession *)session;

- (void)start;

- (void)pause;

- (void)stop;



- (void)receiveData:(nonnull NSData *)data;

- (void)completeWithError:(nullable NSError *)error;

@end

