//
//  AppDatabase+KMImageCache.m
//  KMImageCache
//
//  Created by matsuda on 12/02/07.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "AppDatabase+KMImageCache.h"

@interface AppDatabase(PrivateMethods)
-(void)runMigrations;
-(NSUInteger)databaseVersion;
-(void)setDatabaseVersion:(NSUInteger)newVersionNumber;

// Migration steps - v1
-(void)createApplicationPropertiesTable;
-(void)createCachedImageTable;

// Migration steps - v2 .. vN
@end

@implementation AppDatabase (KMImageCache)

-(void)runMigrations {
	[self beginTransaction];

	// Turn on Foreign Key support
	[self executeSql:@"PRAGMA foreign_keys = ON"];

	NSArray *tableNames = [self tableNames];

	if (![tableNames containsObject:@"ApplicationProperties"]) {
		[self createApplicationPropertiesTable];
        [self createCachedImageTable];
	}

	if ([self databaseVersion] < 2) {
		// Migrations for database version 1 will run here
        [self setDatabaseVersion:2];
	}

	/*
	 * To upgrade to version 3 of the DB do

     if ([self databaseVersion] < 3) {
     // ...
     [self setDatabaseVersion:3];
     }

	 *
	 */

	[self commit];
}

- (void)createCachedImageTable
{
    [self executeSql:@"CREATE TABLE IF NOT EXISTS CachedImage (primaryKey INTEGER primary key autoincrement, url TEXT, createdAt REAL)"];
}

@end
