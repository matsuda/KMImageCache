//
//  KMImageCacheViewController.m
//  KMImageCache
//
//  Created by matsuda on 12/02/07.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "KMImageCacheViewController.h"
#import "ImageCacheManager.h"

static NSString * kImageUrl = @"http://matsuda.me/images/logo.png";

@interface KMImageCacheViewController ()
@property (nonatomic, retain) NSURLConnection *connection;
@property (nonatomic, retain) NSMutableData *data;
@property (nonatomic, retain) UIActivityIndicatorView *indicator;
- (void)requestDownload;
- (void)clearCaches;
- (void)cancel;
@end


@implementation KMImageCacheViewController

@synthesize imageView = _imageView;
@synthesize downloadButton = _downloadButton;
@synthesize clearButton = _clearButton;

@synthesize connection = _connection;
@synthesize data = _data;
@synthesize indicator = _indicator;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];

    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    UIImage *cachedImage = [[ImageCacheManager sharedManager] imageWithURL:kImageUrl];
    if (cachedImage) {
        self.imageView.image = cachedImage;
    } else {
        [self requestDownload];
    }
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    self.imageView = nil;
    self.downloadButton = nil;
    self.clearButton = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)dealloc
{
    [_imageView release], _imageView = nil;
    [_clearButton release], _clearButton = nil;
    [_connection release], _connection = nil;
    [_data release], _data = nil;
    [_indicator release], _indicator = nil;
    [super dealloc];
}

- (void)requestDownload
{
    [self cancel];
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:kImageUrl] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:30.0];
    self.connection = [[[NSURLConnection alloc] initWithRequest:request delegate:self] autorelease];
}

- (void)clearCaches
{
    [[ImageCacheManager sharedManager] removeAll];
    self.imageView.image = nil;
    [self.imageView setNeedsLayout];
}

- (void)cancel
{
    if (_connection) {
        [_connection cancel];
        [_connection release], _connection = nil;
    }
}

- (IBAction)downloadImage:(id)sender
{
    [self requestDownload];
}

- (IBAction)clearCaches:(id)sender
{
    [self clearCaches];
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    self.data = [NSMutableData data];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [self.data appendData:data];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    [self cancel];
}

//- (void)connectionDidFinishLoading:(NSURLConnection *)connection
//{
//    [self cancel];
//    UIImage *image = [UIImage imageWithData:self.data];
//    self.imageView.image = image;
//    [self.imageView setNeedsLayout];
//    [[ImageCacheManager sharedManager] storeImage:image withURL:kImageUrl];
//    self.data = nil;
//}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    [self cancel];
    ImageCacheManager *manager = [ImageCacheManager sharedManager];
    [manager storeData:self.data withURL:kImageUrl];
    self.data = nil;
    UIImage *image = [manager imageWithURL:kImageUrl];
    self.imageView.image = image;
    [self.imageView setNeedsLayout];
}

@end
