//
//  DownloadManager.m
//  download demo
//
//  Created by 翟泉 on 2016/7/30.
//  Copyright © 2016年 云之彼端. All rights reserved.
//

#import "DownloadManager.h"

@interface DownloadManager ()
<NSURLSessionDataDelegate>

@property (strong, nonatomic) NSMutableArray<DownloadOperation *> *operations;

@property (strong, nonatomic) NSURLSession *session;

@end

@implementation DownloadManager


+ (instancetype)manager {
    static id sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}


- (instancetype)init {
    if (self = [super init]) {
        NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
        config.allowsCellularAccess = NO;
        _session = [NSURLSession sessionWithConfiguration:config delegate:self delegateQueue:[[NSOperationQueue alloc] init]];
        _operations = [NSMutableArray array];
        
        _downloadDirectory = @"/Users/cezr/Desktop/Download";
        BOOL isDirectory;
        [[NSFileManager defaultManager] fileExistsAtPath:_downloadDirectory isDirectory:&isDirectory];
        if (!isDirectory) {
            [[NSFileManager defaultManager] createDirectoryAtPath:_downloadDirectory withIntermediateDirectories:YES attributes:NULL error:NULL];
        }
    }
    return self;
}


- (DownloadOperation *)downloadOperationWithURL:(NSURL *)url {
    __block DownloadOperation *operation;
    
    [_operations enumerateObjectsUsingBlock:^(DownloadOperation * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj.url isEqual:url]) {
            operation = obj;
            *stop = YES;
        }
    }];
    if (!operation) {
        operation = [DownloadOperation operationWithURL:url urlSession:_session];
        [_operations addObject:operation];
    }
    
    return operation;
}


#pragma mark - NSURLSessionTaskDelegate

/**
 *  收到 response
 */
- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveResponse:(NSURLResponse *)response completionHandler:(void (^)(NSURLSessionResponseDisposition disposition))completionHandler {
    // 如果是视频文件
    if ([response.MIMEType rangeOfString:@"video"].length) {
        // 继续
        completionHandler(NSURLSessionResponseAllow);
    }
    else {
        // 取消
        completionHandler(NSURLSessionResponseCancel);
        NSLog(@"response.MIMEType %@", response.MIMEType);
    }
}


- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task willPerformHTTPRedirection:(NSHTTPURLResponse *)response newRequest:(NSURLRequest *)request completionHandler:(void (^)(NSURLRequest * _Nullable))completionHandler {
    completionHandler(request);
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(nullable NSError *)error {
    [task.operation completeWithError:error];
    [_operations removeObject:task.operation];
}


#pragma mark - NSURLSessionDataDelegate

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data {
    [dataTask.operation receiveData:data];
}


@end
