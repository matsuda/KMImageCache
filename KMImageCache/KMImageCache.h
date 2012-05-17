//
//  KMImageCache.h
//  KMImageCache
//
//  Created by matsuda on 12/02/07.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface KMImageCache : NSObject

/*
 Class methods
 */
+ (KMImageCache *)sharedCache;

// キャッシュパス
+ (NSString *)defaultCacheDir;

// キャッシュされている画像を全て削除
+ (void)removeAll;

// キャッシュファイルのキー（MD5変換された文字列）
+ (NSString *)cacheKeyForURL:(NSString *)url;

/*
 Instance methods
 */
// 指定されたURLに該当するキャッシュデータを返す
//- (UIImage *)imageWithURL:(NSString *)url;
- (UIImage *)cachedImageWithURL:(NSString *)url;

// 指定されたURLをキーに画像を保存する
- (void)storeImage:(UIImage *)image withURL:(NSString *)url;
- (void)storeData:(NSData *)data withURL:(NSString *)url;

// 指定されたURLに該当するキャッシュデータを削除
- (void)removeWithURL:(NSString *)url;

// キャッシュされている画像を全て削除
- (void)removeAll;

@end
