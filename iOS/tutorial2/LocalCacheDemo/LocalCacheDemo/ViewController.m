//
//  ViewController.m
//  LocalCacheDemo
//
//  Created by Wei Zhang on 9/21/18.
//  Copyright © 2018 VeraZhang. All rights reserved.
//

#import "ViewController.h"
#import <WebKit/WebKit.h>
#import "Cache.h"

@interface ViewController () <UITextViewDelegate>
@property UIView *webviewHolder;
@property UISegmentedControl *webviewSwitch;
@property UITextView *input;
@property NSString *cacheId;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Add a title to the view
    UINavigationBar *navigationBar = [[UINavigationBar alloc] initWithFrame:CGRectMake(0, 40, self.view.frame.size.width, 60)];
    UINavigationItem *navigationItem = [[UINavigationItem alloc] init];
    navigationItem.title = @"Local Cache Demo";
    navigationBar.items = @[navigationItem];
    [self.view addSubview:navigationBar];
    // Add a toggle to choose between UIWebview and WkWebview
    NSArray *itemArray = @[@"WkWebview",@"UIWebview"];
    self.webviewSwitch = [[UISegmentedControl alloc] initWithItems:itemArray];
    self.webviewSwitch.selectedSegmentIndex = 0;
    self.webviewSwitch.tintColor = [UIColor blueColor];
    self.webviewSwitch.backgroundColor = [UIColor whiteColor];
    self.webviewSwitch.layer.cornerRadius = 5.0;
    [self.webviewSwitch addTarget:self action:@selector(controlSwitch:) forControlEvents:UIControlEventValueChanged];
    self.webviewSwitch.frame = CGRectMake(20, 100, self.view.frame.size.width -40, 35);
    [self.view addSubview:self.webviewSwitch];
    // Add a container to hold the webview
    self.webviewHolder = [[UIView alloc] initWithFrame:CGRectMake(0, 150, self.view.frame.size.width, 300)];
    self.webviewHolder.layer.borderColor = [[UIColor blueColor] CGColor];
    self.webviewHolder.layer.borderWidth = 1.0f;
    [self.view addSubview:self.webviewHolder];
    // Initialize the content
    self.cacheId = @"random";
    [self addWkWebview];
    // Add a content input text view
    self.input = [[UITextView alloc] initWithFrame:CGRectMake(0, 465, self.view.frame.size.width, 50)];
    self.input.layer.borderColor = [[UIColor blueColor] CGColor];
    self.input.layer.borderWidth = 1.0f;
    self.input.text = @"Tap to edit";
    self.input.font = [UIFont systemFontOfSize:20.0f];
    self.input.textColor = [UIColor lightGrayColor];
    self.input.delegate = self;
    [self.view addSubview:self.input];
    // Add a button to send the data from text view to webview
    UIButton *cache = [[UIButton alloc] initWithFrame:CGRectMake(20, 530, self.view.frame.size.width-40, 35)];
    cache.backgroundColor = [UIColor blueColor];
    cache.layer.cornerRadius = 10.0f;
    [cache setTitle:@"Cache Input Text" forState:UIControlStateNormal];
    [cache addTarget:self action:@selector(cacheButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:cache];
}

- (void) cacheButtonPressed: (id) sender
{
    NSString *contentToCache = self.input.text;
    if (![@"Tap to edit" isEqualToString:contentToCache]) {
        NSArray *contents = @[contentToCache];
        NSURLRequest *request = [self getRequestWithQueryString:@"test"];
        [[Cache globalCache] cacheContents:contents forHost:request.URL.absoluteString withCompletionBlock:^(NSError *error, NSArray *cacheIds) {
            if (error) {
                self.cacheId = @"failedToCache";
            } else {
                self.cacheId = cacheIds[0];
            }
            [self controlSwitch:self.webviewSwitch];
        }];
    } else {
        self.cacheId = @"haha";
        [self controlSwitch:self.webviewSwitch];
    }
}

- (void)textViewDidBeginEditing:(UITextView *)textView
{
    if ([textView.text isEqualToString:@"Tap to edit"]) {
        textView.text = @"";
        textView.textColor = [UIColor blackColor]; //optional
    }
    [textView becomeFirstResponder];
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
    if ([textView.text isEqualToString:@""]) {
        textView.text = @"Tap to edit";
        textView.textColor = [UIColor lightGrayColor]; //optional
    }
    [textView resignFirstResponder];
}

- (void)controlSwitch: (UISegmentedControl *) control
{
    if (control.selected == 0) {
        [self addWkWebview];
    } else {
        [self addUIWebview];
    }
}

- (void) addWkWebview
{
    for(UIView *sub in self.webviewHolder.subviews) {
        [sub removeFromSuperview];
    }
    WKWebView *content = [[WKWebView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 300)];
    [self.webviewHolder addSubview:content];
    [content loadRequest:[self getRequestWithQueryString: self.cacheId]];
}

- (void) addUIWebview
{
    for(UIView *sub in self.webviewHolder.subviews) {
        [sub removeFromSuperview];
    }
    UIWebView *content = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 300)];
    [self.webviewHolder addSubview:content];
    [content loadRequest:[self getRequestWithQueryString: self.cacheId]];
}

- (NSURLRequest *) getRequestWithQueryString: (NSString *) key
{
    NSString * filePath = [[NSBundle mainBundle] pathForResource:@"index" ofType:@"html"];
    NSURL *filePathURL = [NSURL fileURLWithPath:filePath];
    NSURLComponents *components = [NSURLComponents componentsWithURL:filePathURL resolvingAgainstBaseURL:NO];
    [components setQuery: [NSString stringWithFormat:@"q=%@", key]];
    NSURLRequest *request = [NSURLRequest requestWithURL:[components URL]];
    return [request copy];
}


@end
