//
//  DownloadManager.h
//  download demo
//
//  Created by 翟泉 on 2016/7/30.
//  Copyright © 2016年 云之彼端. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DownloadOperation.h"

@interface DownloadManager : NSObject

@property (strong, nonatomic) NSString *downloadDirectory;

+ (instancetype)manager;

- (DownloadOperation *)downloadOperationWithURL:(NSURL *)url;

@end

