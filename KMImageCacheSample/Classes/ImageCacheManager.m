//
//  ImageCacheManager.m
//  KMImageCache
//
//  Created by matsuda on 12/02/07.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "ImageCacheManager.h"
#import "CachedImage.h"
#import "KMImageCache.h"

static NSTimeInterval const kImageCacheManagerExpireInterval = 24 * 60 * 60; // 24 hours
static NSTimeInterval const kImageCacheManagerMaxCount = 300;

@interface ImageCacheManager ()
@property (nonatomic, assign) NSTimeInterval expireInterval;
@property (nonatomic, retain) NSTimer *maintenanceTimer;
- (void)registerNotifications;
- (void)removeNotifications;
- (id)initWithTimeInterval:(NSTimeInterval)seconds;
- (void)removeAllCaches:(NSArray *)caches;
@end

@implementation ImageCacheManager

@synthesize expireInterval = _expireInterval;
@synthesize maintenanceTimer = _maintenanceTimer;

#pragma mark - Lifecycle

- (void)dealloc
{
    [self removeNotifications];
    if (_maintenanceTimer) {
        [_maintenanceTimer invalidate];
    }
    [_maintenanceTimer release], _maintenanceTimer = nil;

    [super dealloc];
}

+ (ImageCacheManager *)sharedManager
{
    static ImageCacheManager *_sharedManager = nil;
    static dispatch_once_t oncePredicate;
    dispatch_once(&oncePredicate, ^{
        _sharedManager = [[self alloc] initWithTimeInterval:-kImageCacheManagerExpireInterval];
    });

    return _sharedManager;
}

- (id)initWithTimeInterval:(NSTimeInterval)seconds
{
    self = [super init];
    if (self) {
        self.expireInterval = seconds;
        self.maintenanceTimer = [NSTimer scheduledTimerWithTimeInterval:1*60 target:self selector:@selector(maintenanceCacheCapacity:) userInfo:nil repeats:YES];
        [self registerNotifications];
    }
    return self;
}

/*
 KMImageCache
 */
- (UIImage *)imageWithURL:(NSString *)url
{
    return [[KMImageCache sharedCache] cachedImageWithURL:url];
}

- (void)storeImage:(UIImage *)image withURL:(NSString *)url
{
    CachedImage *cachedImage = [CachedImage findByURL:url];
    if (cachedImage) {
        [[KMImageCache sharedCache] removeWithURL:url];
    } else {
        cachedImage = [[[CachedImage alloc] init] autorelease];
        cachedImage.url = url;
    }
    cachedImage.createdAt = [NSDate date];
    [cachedImage save];
    [[KMImageCache sharedCache] storeImage:image withURL:url];
}

- (void)storeData:(NSData *)data withURL:(NSString *)url
{
    CachedImage *cachedImage = [CachedImage findByURL:url];
    if (cachedImage) {
        [[KMImageCache sharedCache] removeWithURL:url];
    } else {
        cachedImage = [[[CachedImage alloc] init] autorelease];
        cachedImage.url = url;
    }
    cachedImage.createdAt = [NSDate date];
    [cachedImage save];
    [[KMImageCache sharedCache] storeData:data withURL:url];
}

- (void)removeAll
{
    [[KMImageCache sharedCache] removeAll];
    [CachedImage deleteAll];
}

- (void)removeAllOverTimeInterval:(NSTimeInterval)interval
{
    NSArray *expiredCaches = [CachedImage findAllOverTimeInterval:interval];
    [self removeAllCaches:expiredCaches];
}

- (void)removeAllOverCapacity:(NSUInteger)count
{
    NSArray *expiredCaches = [CachedImage findAllOrderByCreatedAtAndLimit:count];
    [self removeAllCaches:expiredCaches];
}

#pragma mark - Private

- (void)registerNotifications
{
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center addObserver:self selector:@selector(maintenanceCache:) name:UIApplicationDidBecomeActiveNotification object:nil];
    [center addObserver:self selector:@selector(maintenanceCache:) name:UIApplicationDidEnterBackgroundNotification object:nil];
}

- (void)removeNotifications
{
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center removeObserver:self name:UIApplicationDidBecomeActiveNotification object:nil];
    [center removeObserver:self name:UIApplicationDidEnterBackgroundNotification object:nil];
}

- (void)maintenanceCache:(NSNotification *)aNotification
{
    [self removeAllOverTimeInterval:-kImageCacheManagerExpireInterval];
}

- (void)removeAllCaches:(NSArray *)caches
{
    NSEnumerator *enumerator = [caches objectEnumerator];
    CachedImage *cache;
    while ((cache = [enumerator nextObject])) {
        NSString *url = cache.url;
        [[KMImageCache sharedCache] removeWithURL:url];
        [cache delete];
    }
}

- (void)maintenanceCacheCapacity:(NSTimer *)timer
{
    NSUInteger count = [CachedImage countAll];
    if (count <= kImageCacheManagerMaxCount) return;

    NSUInteger overCount = count - kImageCacheManagerMaxCount;
    [self removeAllOverCapacity:overCount];
}

@end
