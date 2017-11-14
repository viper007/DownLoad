//
//  FileTool.h
//  BreakPointDownLoad
//
//  Created by 满艺网 on 2017/11/9.
//  Copyright © 2017年 lvzhenhua. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FileTool : NSObject

/**
 文件是否存在

 @param filePath 创建的文件的文件路径
 @return BOOL
 */
+ (BOOL)fileExists:(NSString *)filePath;

/**
 获得对应的文件的大小

 @param filePath 文件路径
 @return 得到对应的文件的大小
 */
+ (long long)getFileSize:(NSString *)filePath ;

+ (BOOL)moveFile:(NSString *)fromPath toPath:(NSString *)toPath ;

+ (BOOL)removeFile:(NSString *)filePath ;

+ (BOOL)createDirection:(NSString *)directPath;
@end
