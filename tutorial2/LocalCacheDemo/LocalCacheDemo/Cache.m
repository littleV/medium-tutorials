/*   Copyright 2017 Prebid.org, Inc.
 
 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at
 
 http://www.apache.org/licenses/LICENSE-2.0
 
 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.
 */

#import "Cache.h"
#import <WebKit/Webkit.h>

static NSInteger expireCacheMilliSeconds = 300000; // expire content cached longer than 5 minutes

@interface CacheOperation : NSOperation <UIWebViewDelegate, WKNavigationDelegate>
{
    BOOL executing;
    BOOL finished;
}
@property NSInteger loadingCount;
@property NSURL *httpsHost;
@property UIWebView *uiwebviewCache;
@property WKWebView *wkwebviewCache;
@property NSString* htmlToLoad;
@property NSMutableArray *cacheIds;
@property (nonnull) void (^sendCacheIds)(NSError *, NSArray *);
- (instancetype)initWithContentsToCache: (NSArray *)contents forHost: (NSString *) hostURL withComletionHandler:(void (^)(NSError *, NSArray *))completionBlock;
@end

@implementation CacheOperation

- (instancetype)initWithContentsToCache:(NSArray *)contents forHost:(NSString *)hostURL withComletionHandler:(void (^)(NSError *, NSArray *))completionBlock
{
    if (self = [super init]) {
        executing = NO;
        finished = NO;
        self.sendCacheIds = completionBlock;
        if (contents == nil || contents.count == 0) {
            [self finishAndChangeState];
            return self;
        }
        if (hostURL == nil || [hostURL isEqualToString:@""]) {
            [self finishAndChangeState];
            return self;
        }
        long long milliseconds = (long long)([[NSDate date] timeIntervalSince1970] * 1000.0);
        NSMutableString *htmlToLoad = [[NSMutableString alloc] init];
        [htmlToLoad appendString:@"<head>"];
        NSString *scriptString = [NSString stringWithFormat:@"<script>var currentTime = %lld;var toBeDeleted = [];for(i = 0; i< localStorage.length; i ++){if(localStorage.key(i).startsWith('LocalCache_')) {createdTime = localStorage.key(i).split('_')[2];if (( currentTime - createdTime) > %ld){toBeDeleted.push(localStorage.key(i));}}}for ( i = 0; i< toBeDeleted.length; i ++) {localStorage.removeItem(toBeDeleted[i]);}</script>", milliseconds, (long) expireCacheMilliSeconds];
        [htmlToLoad appendString:scriptString];
        self.cacheIds = [[NSMutableArray alloc] init];
        for (NSString *content in contents) {
            NSString *cacheId = [NSString stringWithFormat:@"LocalCache_%@_%lld", [NSString stringWithFormat:@"%08X", arc4random()], milliseconds];
            [self.cacheIds addObject:cacheId];
            [htmlToLoad appendString:[NSString stringWithFormat:@"<script>localStorage.setItem(\"%@\",\"%@\");</script>", cacheId, [self escapeHTML:content]]];
        }
        [htmlToLoad appendString:@"</head>"];
        self.htmlToLoad = htmlToLoad;
        _uiwebviewCache = [[UIWebView alloc] init];
        _uiwebviewCache.frame = CGRectZero;
        _uiwebviewCache.delegate = self;
        _wkwebviewCache = [[WKWebView alloc] init];
        _wkwebviewCache.frame = CGRectZero;
        _wkwebviewCache.navigationDelegate = self;
        _httpsHost = [NSURL URLWithString:hostURL];
        _loadingCount = 2;
    }
    return self;
}

-(void)start
{
    if ([self isCancelled])
    {
        // Must move the operation to the finished state if it is canceled.
        [self willChangeValueForKey:@"isFinished"];
        finished = YES;
        [self didChangeValueForKey:@"isFinished"];
        return;
    }
    // If the operation is not canceled, begin executing the task.
    [self willChangeValueForKey:@"isExecuting"];
    [NSThread detachNewThreadSelector:@selector(main) toTarget:self withObject:nil];
    executing = YES;
    [self didChangeValueForKey:@"isExecuting"];
}

-(void)main
{
    @try {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.wkwebviewCache removeFromSuperview];
            UIWindow *window = [[UIApplication sharedApplication] keyWindow];
            [window addSubview:self.wkwebviewCache];
            [self.wkwebviewCache loadHTMLString:self.htmlToLoad baseURL:self.httpsHost];
            [self.uiwebviewCache loadHTMLString:self.htmlToLoad baseURL:self.httpsHost];
        });
    }
    @catch (NSException *exception) {
        NSLog(@"Catch the exception %@",[exception description]);
    }
    @finally {
        NSLog(@"Cache Operation - Main Method - Finally block");
    }
}

-(BOOL)isConcurrent
{
    return YES;    //Default is NO so overriding it to return YES;
}

-(BOOL)isExecuting{
    return executing;
}

-(BOOL)isFinished{
    return finished;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    self.loadingCount--;
    if (self.loadingCount == 0) {
        [self finishAndChangeState];
    }
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation
{
    self.loadingCount--;
    if (self.loadingCount == 0) {
        [self finishAndChangeState];
    }
}

- (void) finishAndChangeState
{
    __weak CacheOperation *weakSelf = self;
        dispatch_async(dispatch_get_main_queue(), ^{
            __strong CacheOperation *strongSelf = weakSelf;
            
            [strongSelf.wkwebviewCache setNavigationDelegate:nil];
            [strongSelf.wkwebviewCache setUIDelegate:nil];
            
            [strongSelf.wkwebviewCache removeFromSuperview];
            strongSelf.wkwebviewCache = nil;
            strongSelf.uiwebviewCache = nil;
            
            if (self.cacheIds != nil && self.cacheIds.count > 0) {
                if (strongSelf.sendCacheIds != nil) {
                    strongSelf.sendCacheIds(nil, self.cacheIds);
                }
            } else {
                if (strongSelf.sendCacheIds != nil) {
                    strongSelf.sendCacheIds([NSError errorWithDomain:self.httpsHost.absoluteString code:0 userInfo:nil], nil);
                }
            }
            
            [strongSelf willChangeValueForKey:@"isExecuting"];
            strongSelf->executing = NO;
            [strongSelf didChangeValueForKey:@"isExecuting"];
            [strongSelf willChangeValueForKey:@"isFinished"];
            strongSelf->finished = YES;
            [strongSelf didChangeValueForKey:@"isFinished"];
            
        });
}

- (NSString *) escapeHTML: (NSString *) aString
{
    NSMutableString *s = [NSMutableString stringWithString:aString];
    
    [s replaceOccurrencesOfString:@"\"" withString:@"&quot;" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [s length])];
    [s replaceOccurrencesOfString:@"&" withString:@"&amp;" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [s length])];
    [s replaceOccurrencesOfString:@"<" withString:@"&lt;" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [s length])];
    [s replaceOccurrencesOfString:@">" withString:@"&gt;" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [s length])];
    return [NSString stringWithString:s];
}
@end

@interface Cache ()
@property NSOperationQueue *cacheQueue;
@end

@implementation Cache

+ (instancetype)globalCache {
    static id instance;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[[self class] alloc] init];
        [instance setupQueue];
    });
    
    return instance;
}

-(void) setupQueue
{
    self.cacheQueue = [NSOperationQueue new];
}

- (void) cacheContents:(NSArray *)contents forHost: (NSString *)hostURL withCompletionBlock:(void (^)(NSError *, NSArray *))completionBlock
{
    CacheOperation *cacheOperation = [[CacheOperation alloc] initWithContentsToCache:contents forHost:hostURL withComletionHandler:completionBlock];
    [self.cacheQueue addOperation:cacheOperation];
}



@end
