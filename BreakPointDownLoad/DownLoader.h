//
//  DownLoader.h
//  BreakPointDownLoad
//
//  Created by 满艺网 on 2017/11/9.
//  Copyright © 2017年 lvzhenhua. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^loadProgressBlock)(float progress);
typedef void(^speedBlock)(NSString *speed);
@interface DownLoader : NSObject

- (void)downLoadWithURL:(NSURL *)url ;

@property (nonatomic ,copy) loadProgressBlock loadProgress;
@property (nonatomic ,copy) speedBlock speed;
- (void)pause;
- (void)resume ;
@end
