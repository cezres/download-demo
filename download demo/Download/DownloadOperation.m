//
//  DownloadOperation.m
//  download demo
//
//  Created by 翟泉 on 2016/7/30.
//  Copyright © 2016年 云之彼端. All rights reserved.
//

#import "DownloadOperation.h"
#import <CommonCrypto/CommonDigest.h>
#import <objc/runtime.h>
#import "DownloadManager.h"

NSString * MD5(NSString *str) {
    const char *cStr = [str UTF8String];
    unsigned char digest[CC_MD5_DIGEST_LENGTH];
    CC_MD5( cStr, (unsigned int)strlen(cStr), digest );
    NSMutableString *output = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    for(int i = 0; i < CC_MD5_DIGEST_LENGTH; i++)
        [output appendFormat:@"%02x", digest[i]];
    return output;
}


@implementation NSURLSessionTask (__Download)

- (void)dealloc {
    printf("%s\n", __FUNCTION__);
}

- (void)setOperation:(DownloadOperation *)operation {
    objc_setAssociatedObject(self, @selector(operation), operation, OBJC_ASSOCIATION_ASSIGN);
}
- (DownloadOperation *)operation {
    return objc_getAssociatedObject(self, @selector(operation));
}


@end



@interface DownloadOperation ()

@property (weak, nonatomic) NSURLSession *urlSession;

@property (weak, nonatomic) NSURLSessionDataTask *dataTask;

@property (strong, nonatomic) NSFileHandle *fileHandle;

@property (strong, nonatomic) NSString *filePath;

@property (assign, nonatomic) unsigned long long downloadOffset;



@property (assign, nonatomic) CFAbsoluteTime time;

@property (assign, nonatomic) unsigned long long lastReceivedBytesCount;

@property (assign, nonatomic) double speed;

@end

@implementation DownloadOperation

+ (instancetype)operationWithURL:(NSURL *)url urlSession:(NSURLSession *)session {
    DownloadOperation *operation = [[DownloadOperation alloc] initWithURL:url urlSession:session];
    return operation;
}

- (instancetype)initWithURL:(NSURL *)url urlSession:(NSURLSession *)session {
    if (self = [super init]) {
        _url = [url copy];
        _urlSession = session;
    }
    return self;
}

- (instancetype)init {
    if (self = [super init]) {
        
    }
    return self;
}

- (void)dealloc {
    printf("%s\n", __FUNCTION__);
}

- (void)start {
    if (_dataTask) {
        [_dataTask resume];
    }
    else {
        [self.dataTask resume];
    }
}

- (void)pause {
    [self.dataTask suspend];
}

- (void)stop {
    [self.dataTask cancel];
}




- (void)receiveData:(NSData *)data {
    CFAbsoluteTime currentTime = CFAbsoluteTimeGetCurrent();
    if (currentTime - _time > 1 || _speed == 0) {
        _speed = (self.countOfBytesReceived - _lastReceivedBytesCount) / (currentTime - _time);
        _time = currentTime;
        _lastReceivedBytesCount = self.countOfBytesReceived;
    }
    
    printf("length %llu\tspeed %.1lf KB/s\t\t", (self.countOfBytesReceived - _lastReceivedBytesCount), _speed / 1024);
    
    [_fileHandle writeData:data];
    [_fileHandle seekToEndOfFile];
    printf("File %lld\t\t", _fileHandle.offsetInFile);
    
    double byts =  self.countOfBytesReceived * 1.0 / 1024 / 1024;
    double total = self.countOfBytesExpectedToReceive * 1.0 / 1024 / 1024;
    double progress = self.countOfBytesReceived / (double)self.countOfBytesExpectedToReceive;
    printf("%lf  %.1lfMB/%.1fMB   \n", progress, byts, total);
}

- (void)completeWithError:(NSError *)error {
    if (error) {
        [_fileHandle closeFile];
        [[NSFileManager defaultManager] removeItemAtPath:_filePath error:NULL];
    }
    else {
        [_fileHandle closeFile];
        NSString *toPath = [NSString stringWithFormat:@"%@/%@", [DownloadManager manager].downloadDirectory, _dataTask.response.suggestedFilename];
        NSURL *toURL = [NSURL fileURLWithPath:toPath];
        [[NSFileManager defaultManager] moveItemAtURL:[NSURL fileURLWithPath:_filePath] toURL:toURL error:NULL];
    }
}



- (NSURLSessionDataTask *)dataTask {
    if (!_dataTask) {
        _filePath = [NSString stringWithFormat:@"%@/%@", [DownloadManager manager].downloadDirectory, MD5(_url.absoluteString)];
        if (![[NSFileManager defaultManager] fileExistsAtPath:_filePath]) {
            [[NSFileManager defaultManager] createFileAtPath:_filePath contents:NULL attributes:NULL];
        }
        
        _fileHandle = [NSFileHandle fileHandleForWritingAtPath:self.filePath];
        [_fileHandle seekToEndOfFile];
        _downloadOffset = _fileHandle.offsetInFile;
        
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:self.url];
        NSString *range = [NSString stringWithFormat:@"bytes=%llu-", _downloadOffset];
        [request setValue:range forHTTPHeaderField:@"Range"];
        
        _dataTask = [_urlSession dataTaskWithRequest:request];
        _dataTask.operation = self;
    }
    return _dataTask;
}

- (unsigned long long)countOfBytesReceived {
    return _downloadOffset + _dataTask.countOfBytesReceived;
}

- (unsigned long long)countOfBytesExpectedToReceive {
    return _downloadOffset + _dataTask.countOfBytesExpectedToReceive;
}

@end



