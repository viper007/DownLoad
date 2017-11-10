//
//  FileTool.h
//  BreakPointDownLoad
//
//  Created by 满艺网 on 2017/11/9.
//  Copyright © 2017年 lvzhenhua. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FileTool : NSObject

+ (BOOL)fileExists:(NSString *)filePath;

+ (long long)getFileSize:(NSString *)filePath ;

+ (BOOL)moveFile:(NSString *)fromPath toPath:(NSString *)toPath ;

+ (BOOL)removeFile:(NSString *)filePath ;

+ (BOOL)createDirection:(NSString *)directPath;
@end
