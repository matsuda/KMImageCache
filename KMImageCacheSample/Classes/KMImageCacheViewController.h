//
//  KMImageCacheViewController.h
//  KMImageCache
//
//  Created by matsuda on 12/02/07.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface KMImageCacheViewController : UIViewController <NSURLConnectionDataDelegate>
@property (nonatomic, retain) IBOutlet UIImageView *imageView;
@property (nonatomic, retain) IBOutlet UIButton *downloadButton;
@property (nonatomic, retain) IBOutlet UIButton *clearButton;

- (IBAction)downloadImage:(id)sender;
- (IBAction)clearCaches:(id)sender;

@end
