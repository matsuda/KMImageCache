//
//  KMImageCache.m
//  KMImageCache
//
//  Created by matsuda on 12/02/07.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "KMImageCache.h"
#import <CommonCrypto/CommonDigest.h>

/*
 http://labs.torques.jp/2011/01/14/1596/
 */
@interface NSString (DCImageCache)
- (NSString *)MD5String;
@end

@implementation NSString (DCImageCache)
- (NSString *)MD5String
{
    const char *cStr = [self UTF8String];
    unsigned char r[CC_MD5_DIGEST_LENGTH];
    CC_MD5( cStr, strlen(cStr), r);
    return [NSString stringWithFormat:@"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
            r[0], r[1], r[2], r[3], r[4], r[5], r[6], r[7], r[8], r[9], r[10], r[11], r[12], r[13], r[14], r[15]];
}
@end


@interface KMImageCache ()

@property (nonatomic, retain) NSCache *cache;

- (id)initWithCacheDir:(NSString *)cacheDir;
+ (void)createDirectoryIfNotExist:(NSString *)dir;
+ (NSString *)cacheDir;
+ (NSString *)cachePathForURL:(NSString *)url;
+ (void)removeAtPath:(NSString *)path;
+ (BOOL)isExistImage:(NSString *)path;

@end


@implementation KMImageCache

#pragma mark - Lifecycle

@synthesize cache = _cache;

- (id)init
{
    self = [super init];
    if (self) {
        self.cache = [[[NSCache alloc] init] autorelease];
    }
    return self;
}

- (id)initWithCacheDir:(NSString *)cacheDir
{
    self = [self init];
    if (self) {
        [[self class] createDirectoryIfNotExist:cacheDir];
    }
    return self;
}

- (void)dealloc
{
    [_cache release];

    [super dealloc];
}

#pragma mark - Private

+ (void)createDirectoryIfNotExist:(NSString *)dir
{
	NSFileManager *fm = [NSFileManager defaultManager];
	BOOL isExist = [fm fileExistsAtPath:dir];
	if (!isExist) {
		[fm createDirectoryAtPath:dir withIntermediateDirectories:YES attributes:nil error:nil];
	}
}

+ (NSString *)cacheDir
{
	NSString *cacheDir = [self defaultCacheDir];
	[self createDirectoryIfNotExist:cacheDir];
	return cacheDir;
}

+ (NSString *)cachePathForURL:(NSString *)url
{
    NSString *key = [self cacheKeyForURL:url];
	NSString *cacheDir = [self cacheDir];
	return [cacheDir stringByAppendingPathComponent:key];
}

+ (void)removeAtPath:(NSString *)path
{
    if (!path || [path length] <= 0) return;

	NSFileManager *fm = [NSFileManager defaultManager];
	if ([fm fileExistsAtPath:path])
		[fm removeItemAtPath:path error:nil];
}

+ (BOOL)isExistImage:(NSString *)path
{
	NSFileManager *fm = [NSFileManager defaultManager];
	return [fm fileExistsAtPath:path];
}

#pragma mark - Public

/*
 Class methods
 */
+ (KMImageCache *)sharedCache
{
    static KMImageCache *_sharedCache = nil;
    static dispatch_once_t oncePredicate;
    dispatch_once(&oncePredicate, ^{
        _sharedCache = [[self alloc] initWithCacheDir:[self defaultCacheDir]];
    });

    return _sharedCache;
}

+ (NSString *)defaultCacheDir
{
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
	NSString *cacheDirPath = [paths objectAtIndex:0];
	return [cacheDirPath stringByAppendingPathComponent:NSStringFromClass(self)];
}

+ (void)removeAll
{
    [self removeAtPath:[self cacheDir]];
}

+ (NSString *)cacheKeyForURL:(NSString *)url
{
    return [url MD5String];
}

/*
 Instance methods
 */
//- (UIImage *)imageWithURL:(NSString *)url
//{
//    if (!url || [url length] <= 0) return nil;
//
//	NSString *path = [[self class] cachePathForURL:url];
//
//	NSFileManager *fm = [NSFileManager defaultManager];
//	if (![fm fileExistsAtPath:path]) return nil;
//
//	UIImage *img = [UIImage imageWithContentsOfFile:path];
//	return img;
//}

- (UIImage *)cachedImageWithURL:(NSString *)url
{
    if (!url || [url length] <= 0) return nil;

	NSString *path = [[self class] cachePathForURL:url];
    UIImage *image = [_cache objectForKey:path];
    if (image) return image;

	NSFileManager *fm = [NSFileManager defaultManager];
	if (![fm fileExistsAtPath:path]) return nil;

    NSData *data = [NSData dataWithContentsOfFile:path];
    image = [UIImage imageWithData:data];
    if (image) {
        [_cache setObject:image forKey:path];
    }
    return image;
}

- (void)storeImage:(UIImage *)image withURL:(NSString *)url
{
    if (!url || [url length] <= 0) return;

	NSString *path = [[self class] cachePathForURL:url];

	NSFileManager *fm = [NSFileManager defaultManager];
	if ([fm fileExistsAtPath:path])
		[fm removeItemAtPath:path error:nil];

	NSData *data = [NSData dataWithData:UIImageJPEGRepresentation(image, 1.0)];

	[fm createFileAtPath:path contents:data attributes:nil];
}

- (void)storeData:(NSData *)data withURL:(NSString *)url
{
    if (!url || [url length] <= 0) return;

	NSString *path = [[self class] cachePathForURL:url];

	NSFileManager *fm = [NSFileManager defaultManager];
	if ([fm fileExistsAtPath:path])
		[fm removeItemAtPath:path error:nil];

	[fm createFileAtPath:path contents:data attributes:nil];

    UIImage *image = [UIImage imageWithData:data];
    [_cache setObject:image forKey:data];
}

- (void)removeWithURL:(NSString *)url
{
    NSString *path = [[self class] cachePathForURL:url];
    [[self class] removeAtPath:path];
    [_cache removeObjectForKey:path];
}

- (void)removeAll
{
    [[self class] removeAll];
    [_cache removeAllObjects];
}

@end
