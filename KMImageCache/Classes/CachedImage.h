//
//  CachedImage.h
//  KMImageCache
//
//  Created by matsuda on 12/02/07.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MojoModel.h"

@interface CachedImage : MojoModel

@property (nonatomic, copy) NSString *url;
@property (nonatomic, retain) NSDate *createdAt;

// 全件
+ (NSUInteger)countAll;

/**********
 with URL
 **********/

+ (CachedImage *)findByURL:(NSString *)url;

+ (NSArray *)findAllOrderByCreatedAtAndLimit:(NSUInteger)limit;

+ (void)deleteByURL:(NSString *)url;


/**********
 with TimeInterval
 **********/

// 〜秒以降のデータ全件
+ (NSArray *)findAllOverTimeInterval:(NSTimeInterval)seconds;

/******************************************

// 〜秒以内のデータ
+ (CachedImage *)findByURL:(NSString *)url withinTimeInterval:(NSTimeInterval)seconds;

// 〜秒以降のデータ
+ (CachedImage *)findByURL:(NSString *)url overTimeInterval:(NSTimeInterval)seconds;

// 〜秒以降のデータを削除
+ (void)deleteByURL:(NSString *)url overTimeInterval:(NSTimeInterval)seconds;

// 〜秒以降のデータを削除
+ (void)deleteOverTimeInterval:(NSTimeInterval)seconds;

 ******************************************/

@end
