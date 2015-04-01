//
//  PS_LoginViewController.m
//  iPhotoSocial
//
//  Created by lisongrc on 15-4-1.
//  Copyright (c) 2015年 Chen.Liu. All rights reserved.
//

#import "PS_LoginViewController.h"

@interface PS_LoginViewController ()<UIWebViewDelegate>

@end

@implementation PS_LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    UIWebView *web = [[UIWebView alloc] initWithFrame:self.view.bounds];
    web.delegate = self;
    [self.view addSubview:web];
    
    NSURL *url = [NSURL URLWithString:self.urlStr];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [web loadRequest:request];
}

#pragma mark -- UIWebViewDelegate --
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    NSLog(@"%s,%ld",__FUNCTION__,navigationType);
//    NSLog(@"request = %@",request);
    
    if (navigationType == UIWebViewNavigationTypeFormSubmitted && [request.URL.absoluteString rangeOfString:@"access_token="].length > 0) {
        [self dismissViewControllerAnimated:YES completion:^{
            NSString *tokenStr = [[request.URL.absoluteString componentsSeparatedByString:@"access_token="] lastObject];
            NSLog(@"%@ %ld",tokenStr,tokenStr.length);
        }];
        return NO;
    }
    return YES;
}

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    NSLog(@"%s",__FUNCTION__);
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    NSLog(@"%s",__FUNCTION__);
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    NSLog(@"%s",__FUNCTION__);
    NSLog(@"%@",error.localizedDescription);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
