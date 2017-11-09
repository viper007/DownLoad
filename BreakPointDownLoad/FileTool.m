//
//  FileTool.m
//  BreakPointDownLoad
//
//  Created by 满艺网 on 2017/11/9.
//  Copyright © 2017年 lvzhenhua. All rights reserved.
//

#import "FileTool.h"

@implementation FileTool

+ (BOOL)fileExists:(NSString *)filePath {
    return [[NSFileManager defaultManager] fileExistsAtPath:filePath];
}

+ (long long)getFileSize:(NSString *)filePath {
    if (![self fileExists:filePath])return 0;
    return [[[NSFileManager defaultManager] attributesOfFileSystemForPath:filePath error:nil] fileSize];
}

+(BOOL)moveFile:(NSString *)fromPath toPath:(NSString *)toPath {
    if (![self fileExists:fromPath]) return NO;
    NSError *error;
    return [[NSFileManager defaultManager] moveItemAtPath:fromPath toPath:toPath error:&error];
}

+ (BOOL)removeFile:(NSString *)filePath {
    if (![self fileExists:filePath]) return YES;
    return [[NSFileManager defaultManager] removeItemAtPath:filePath error:nil];
}
@end
