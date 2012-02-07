//
//  CachedImage.m
//  KMImageCache
//
//  Created by matsuda on 12/02/07.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "CachedImage.h"
#import "MojoDatabase.h"

@interface NSArray (KMImageCache)
- (id)firstObject;
@end

@implementation NSArray (KMImageCache)
- (id)firstObject
{
    if ([self count] < 1) return nil;
    return [self objectAtIndex:0];
}
@end


@interface CachedImage ()
+ (NSNumber *)numberWithTimeIntervalSinceNow:(NSTimeInterval)seconds;
+ (CachedImage *)findSQL:(NSString *)sql byURL:(NSString *)url andTimeInterval:(NSTimeInterval)seconds;
@end

@implementation CachedImage

@synthesize url = _url;
@synthesize createdAt = _createdAt;

- (void)dealloc
{
    [_url release], _url = nil;
    [_createdAt release], _createdAt = nil;
    [super dealloc];
}

#pragma markk - Private

+ (NSNumber *)numberWithTimeIntervalSinceNow:(NSTimeInterval)seconds
{
    NSDate *date = [NSDate dateWithTimeIntervalSinceNow:seconds];
    NSNumber *numDate = [NSNumber numberWithDouble:[date timeIntervalSince1970]];
    return numDate;
}

+ (CachedImage *)findSQL:(NSString *)sql byURL:(NSString *)url andTimeInterval:(NSTimeInterval)seconds
{
    NSNumber *numDate = [self numberWithTimeIntervalSinceNow:seconds];
    return [[self findWithSqlWithParameters:sql, url, numDate, nil] firstObject];
}

#pragma mark - Public

+ (NSUInteger)countAll
{
    NSString *sql = [NSString stringWithFormat:@"SELECT COUNT() FROM %@", [self tableName]];
    NSArray* results = [[self database] executeSqlWithParameters:sql, nil];
    NSDictionary* result = [results firstObject];
    return [[result objectForKey:@"COUNT()"] unsignedIntValue];
}

+ (NSArray *)findAllOrderByCreatedAtAndLimit:(NSUInteger)limit
{
    NSString *sql = [NSString stringWithFormat:@"SELECT * FROM %@ ORDER BY createdAt LIMIT ?", [self tableName]];
    return [self findWithSqlWithParameters:sql, [NSNumber numberWithInt:limit], nil];
}

+ (CachedImage *)findByURL:(NSString *)url
{
    return [[self findByColumn:@"url" value:url] firstObject];
}

+ (void)deleteByURL:(NSString *)url
{
    CachedImage *cachedImage = [self findByURL:url];
    if (cachedImage) [cachedImage delete];
}

+ (NSArray *)findAllOverTimeInterval:(NSTimeInterval)seconds
{
    NSString *sql = [NSString stringWithFormat:@"SELECT * FROM %@ WHERE createdAt < ?", [self tableName]];
    NSNumber *numDate = [self numberWithTimeIntervalSinceNow:seconds];
    return [self findWithSqlWithParameters:sql, numDate, nil];
}

/******************************************

+ (CachedImage *)findByURL:(NSString *)url withinTimeInterval:(NSTimeInterval)seconds
{
    NSString *sql = [NSString stringWithFormat:@"SELECT * FROM %@ WHERE url = ? AND createdAt >= ?", [self tableName]];
    return [self findSQL:sql byURL:url andTimeInterval:seconds];
}

+ (CachedImage *)findByURL:(NSString *)url overTimeInterval:(NSTimeInterval)seconds
{
    NSString *sql = [NSString stringWithFormat:@"SELECT * FROM %@ WHERE url = ? AND createdAt < ?", [self tableName]];
    return [self findSQL:sql byURL:url andTimeInterval:seconds];
}

+ (void)deleteByURL:(NSString *)url overTimeInterval:(NSTimeInterval)seconds
{
    CachedImage *cachedImage = [self findByURL:url overTimeInterval:seconds];
    if (cachedImage) [cachedImage delete];
}

+ (void)deleteOverTimeInterval:(NSTimeInterval)seconds
{
    NSString *sql = [NSString stringWithFormat:@"DELETE FROM %@ WHERE createdAt < ?", [self tableName]];
    NSNumber *numDate = [self numberWithTimeIntervalSinceNow:seconds];
    MojoDatabase *database = [self database];
    [database executeSqlWithParameters:sql, numDate, nil];
}

 ******************************************/

@end
