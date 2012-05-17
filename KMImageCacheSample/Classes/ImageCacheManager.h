//
//  ImageCacheManager.h
//  KMImageCache
//
//  Created by matsuda on 12/02/07.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ImageCacheManager : NSObject

+ (ImageCacheManager *)sharedManager;

/*
 KMImageCache
 */
// 指定されたURLに該当するキャッシュデータを返す
- (UIImage *)imageWithURL:(NSString *)url;

// 指定されたURLをキーに画像を保存する
- (void)storeImage:(UIImage *)image withURL:(NSString *)url;
- (void)storeData:(NSData *)data withURL:(NSString *)url;

// キャッシュをクリア
- (void)removeAll;
- (void)removeAllOverTimeInterval:(NSTimeInterval)interval;
- (void)removeAllOverCapacity:(NSUInteger)count;

@end
