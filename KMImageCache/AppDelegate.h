//
//  AppDelegate.h
//  KMImageCache
//
//  Created by matsuda on 12/02/07.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MojoDatabase;

@interface AppDelegate : UIResponder <UIApplicationDelegate> {
    MojoDatabase *_database;
}

@property (strong, nonatomic) UIWindow *window;
@property (nonatomic, retain) MojoDatabase *database;

- (void)clearAllCaches;

@end
