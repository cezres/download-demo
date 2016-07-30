//
//  ViewController.m
//  download demo
//
//  Created by 翟泉 on 2016/7/30.
//  Copyright © 2016年 云之彼端. All rights reserved.
//

#import "ViewController.h"
#import "DownloadManager.h"

@interface ViewController ()

@property (weak, nonatomic) IBOutlet UILabel *titleLabel1;
@property (weak, nonatomic) IBOutlet UIProgressView *progressView1;

@property (weak, nonatomic) IBOutlet UILabel *titleLabel2;
@property (weak, nonatomic) IBOutlet UIProgressView *progressView2;

@property (weak, nonatomic) IBOutlet UILabel *titleLabel3;
@property (weak, nonatomic) IBOutlet UIProgressView *progressView3;

@property (strong, nonatomic) NSArray *urls;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    
    _urls = @[
              [NSURL URLWithString:@"http://cc-zjhz6-dx.acgvideo.com/vg20/d/43/8961631-1.mp4?expires=1469874900&ssig=S1sDZlOqZhaoL1HR9V1R4g&oi=1018873918&internal=1&rate=0"],
              
              [NSURL URLWithString:@"https://github.com/facebook/fishhook/blob/master/LICENSE"],
              
              [NSURL URLWithString:@"http://cn-zjhz2-dx.acgvideo.com/vg7/d/69/8980857-1.mp4?expires=1469882700&ssig=EASmHrIaRlnF60UqP8d4oQ&oi=1018873918&internal=1&rate=0"],
              [NSURL URLWithString:@"http://cn-zjhz5-dx.acgvideo.com/vg20/c/a4/8969753-1.mp4?expires=1469883000&ssig=dknPon57jyX0l_ebmly0iA&oi=1018873918&internal=1&rate=0"],
              ];
    
//    NSOperation
    
}

- (IBAction)start:(UIButton *)sender {
    DownloadOperation *operation = [[DownloadManager manager] downloadOperationWithURL:_urls[sender.tag]];
    [operation start];
    if (sender.tag == 0) {
        
    }
}
- (IBAction)stop:(UIButton *)sender {
    if (sender.tag == 0) {
        
    }
    DownloadOperation *operation = [[DownloadManager manager] downloadOperationWithURL:_urls[sender.tag]];
    [operation stop];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
