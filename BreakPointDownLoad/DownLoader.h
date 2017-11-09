//
//  DownLoader.h
//  BreakPointDownLoad
//
//  Created by 满艺网 on 2017/11/9.
//  Copyright © 2017年 lvzhenhua. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^loadProgressBlock)(float progress);

@interface DownLoader : NSObject

- (void)downLoadWithURL:(NSURL *)url ;

@property (nonatomic ,copy) loadProgressBlock loadProgress;

- (void)pause;
- (void)resume ;
@end
