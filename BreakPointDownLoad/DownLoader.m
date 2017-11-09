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
    //
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
    NSURL *documentsDirectory = [URLs objectAtIndex:0];

    NSURL *originalURL = [[downloadTask originalRequest] URL];
    NSURL *destinationURL = [documentsDirectory URLByAppendingPathComponent:[originalURL lastPathComponent]];
    NSError *errorCopy;

    [fileManager removeItemAtURL:destinationURL error:NULL];
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
    //下载过程不断回调
    float progress = totalBytesWritten * 1.0 / totalBytesExpectedToWrite;
    NSLog(@"当前进度%f%%",progress);
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
}

- (void)pause {

    [self.task suspend];
}

- (void)resume {
    [self.task resume];
}
@end
