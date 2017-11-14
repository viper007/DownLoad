//
//  DownLoader.m
//  BreakPointDownLoad
//
//  Created by 满艺网 on 2017/11/9.
//  Copyright © 2017年 lvzhenhua. All rights reserved.
//

#define KcachePath NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES).firstObject
#define KtempPath NSTemporaryDirectory()

#import "DownLoader.h"
#import "FileTool.h"

@interface DownLoader ()  <NSURLSessionDownloadDelegate>
{
    long long _totalBytes;
    long long _receivedBytes;
    NSString  *_downLoadingPath;
    NSString  *_downLoadedPath;
    NSTimeInterval _speedTime; //记录上一次的时间
    int64_t _lastReceivedBytes;
}

@property (nonatomic ,strong) NSURLSession *session ;
@property (nonatomic ,strong) NSOutputStream *outStream;
@property (nonatomic ,weak) NSURLSessionTask *task;

@end

@implementation DownLoader

- (void)downLoadWithURL:(NSURL *)url {
    NSString *fileName = url.lastPathComponent;
    _downLoadingPath = [KtempPath stringByAppendingPathComponent:fileName];
    _downLoadedPath = [KcachePath stringByAppendingPathComponent:fileName];
    NSLog(@"%@",_downLoadedPath);
    //1.判断是否下载完成
    if([FileTool fileExists:_downLoadedPath]) {
        NSLog(@"已经下载过了");
        return;
    }
    //2.下载
    _receivedBytes = [FileTool getFileSize:_downLoadingPath];
    [self downLoadFileWith:url offSet:_receivedBytes];
    //
    _speedTime = [[NSDate date] timeIntervalSince1970] ;
    _lastReceivedBytes = 0;
}

- (void)downLoadFileWith:(NSURL *)url offSet:(unsigned long long)offset {
    //
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:0];
    [request setValue:[NSString stringWithFormat:@"bytes=%lld-",offset] forHTTPHeaderField:@"Range"];
    NSURLSessionDownloadTask *dataTask = [self.session downloadTaskWithRequest:request];
    self.task = dataTask ;
    self.outStream = [NSOutputStream outputStreamToFileAtPath:_downLoadingPath append:YES];
    [dataTask resume];
}
#pragma mark - NSURLSessionDataDelegate
/**
 *  请求头信息，然后根据请求头信息去做处理
 */
- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask
didReceiveResponse:(NSURLResponse *)response
 completionHandler:(void (^)(NSURLSessionResponseDisposition disposition))completionHandler {
    NSHTTPURLResponse *httpRespnse = (NSHTTPURLResponse *)response;
    //计算对应的总大小
    _totalBytes = [httpRespnse.allHeaderFields[@"Content-Length"] longLongValue];
    if (httpRespnse.allHeaderFields[@"Content-Range"]) {
        NSString *rangeStr = httpRespnse.allHeaderFields[@"Content-Range"];
        _totalBytes = [[[rangeStr componentsSeparatedByString:@"/"]lastObject]longLongValue];
    }
    if (_receivedBytes == _totalBytes) {
        NSLog(@"下载完成了");
        [FileTool moveFile:KtempPath toPath:KcachePath];//NOTE：可能在移动的时候出错，或者操作的不及时等信息
        completionHandler(NSURLSessionResponseCancel);
        return;
    }
    if (_receivedBytes > _totalBytes) {
        //重新下载
        [FileTool removeFile:_downLoadingPath];
        completionHandler(NSURLSessionResponseCancel);
        [self downLoadWithURL:[NSURL URLWithString:@""]];
        return;
    }
    //
    self.outStream = [NSOutputStream outputStreamToFileAtPath:_downLoadingPath append:YES];
    [self.outStream open];
    completionHandler(NSURLSessionResponseAllow);

}

/**
 * 开始接收数据
 */
- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask
    didReceiveData:(NSData *)data {
    //在这里去计算对应的进度条
    NSLog(@"正在努力下载中");
    [self.outStream write:data.bytes maxLength:data.length];
}

/**
 *  请求完成，或者是取消请求都会走这个方法
 */
- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task
didCompleteWithError:(nullable NSError *)error {
    if (error == nil) {
        [FileTool moveFile:_downLoadingPath toPath:_downLoadedPath];
        NSLog(@"下载成功");
    }else {
        NSLog(@"下载失败");
        //点击按钮恢复上次下载的对应的记录
    }
}

#pragma mark - NSURLSessionDownloadDelegate

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask
didFinishDownloadingToURL:(NSURL *)downloadURL {
    NSLog(@"downLoad--location%@\n",downloadURL);
    NSLog(@"downLoad--location%@\n",downloadURL.absoluteString);
    NSFileManager *fileManager = [NSFileManager defaultManager];

    NSArray *URLs = [fileManager URLsForDirectory:NSCachesDirectory inDomains:NSUserDomainMask];
    NSURL *cacheDirectory = [URLs objectAtIndex:0];

    NSURL *originalURL = [[downloadTask originalRequest] URL];
    NSURL *destinationURL = [cacheDirectory URLByAppendingPathComponent:[originalURL lastPathComponent]];
    NSError *errorCopy;
    [fileManager removeItemAtURL:destinationURL error:NULL];//这个是判断原理的文件里面是否有对应的这个文件
    BOOL success = [fileManager copyItemAtURL:downloadURL toURL:destinationURL error:&errorCopy];
    if (success) {
        NSLog(@"移动成功");
    }else {
        NSLog(@"移动失败");
    }
}

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask
      didWriteData:(int64_t)bytesWritten
 totalBytesWritten:(int64_t)totalBytesWritten
totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite {

   //1. 计算下载速度
    [self calcuteLoadSpeed:totalBytesWritten];
   //2. 下载进度条
    float progress = totalBytesWritten * 1.0 / totalBytesExpectedToWrite;
    if (self.loadProgress) {
        self.loadProgress(progress);
    }
}


#pragma mark - lazy Load
- (NSURLSession *)session {
    if (!_session) {
        NSURLSessionConfiguration *conf = [NSURLSessionConfiguration backgroundSessionConfigurationWithIdentifier:@"back.downLoad"];
        _session = [NSURLSession sessionWithConfiguration:conf delegate:self delegateQueue:nil];
    }
    return _session ;
}

- (void)cancel {
    [self.session invalidateAndCancel];
    self.session = nil;
}

- (void)pause {

    [self.task suspend];
}

- (void)resume {
    [self.task resume];
}

#pragma mark - private method
- (void)calcuteLoadSpeed:(int64_t)totalBytesWritten {
    NSTimeInterval nowDate = [[NSDate date] timeIntervalSince1970];
    if (nowDate - _speedTime > 1.0) {
        int64_t middleBytes = totalBytesWritten - _lastReceivedBytes;

        double timeInterval = (nowDate - _speedTime);
        if (timeInterval <= 0.0) {//防止除数为0
            timeInterval = 1.0;
        }

        double speed_KB = middleBytes/timeInterval / 1024;
        double speed_MB = speed_KB / 1024.0;
        double speed_GB = speed_MB / 1024.0;

        double speed = speed_KB;
        NSString *speed_Unit = @"KB/S";
        if (speed_GB > 1.0) {
            speed_Unit = @"GB/S";
            speed = speed_GB;
        }else if (speed_MB > 1.0) {
            speed_Unit = @"MB/S";
            speed = speed_MB;
        }
        if (self.speed) {
            self.speed([NSString stringWithFormat:@"%.2f%@",speed,speed_Unit]);
        }

        _speedTime = nowDate;
        _lastReceivedBytes = totalBytesWritten;
    }
}
@end
