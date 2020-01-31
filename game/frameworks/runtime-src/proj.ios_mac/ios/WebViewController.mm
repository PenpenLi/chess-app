//
//  RootViewController.m
//  SVWebViewController
//
//  Created by Sam Vermette on 21.02.11.
//  Copyright 2011 Sam Vermette. All rights reserved.
//

#import "WebViewController.h"
#import "SVWebViewController.h"
#import "SVModalWebViewController.h"
#import "YYReachability.h"
#import "AppController.h"
@implementation WebViewController


- (void)pushWebViewController {
    NSURL *URL = [NSURL URLWithString:@"http:www.apple.com"];
	SVWebViewController *webViewController = [[SVWebViewController alloc] initWithURL:URL];
	[self.navigationController pushViewController:webViewController animated:YES];
}


- (void)presentWebViewController:(NSDictionary*) dict
{
    NSString *showurl = [dict objectForKey:@"arg1"];
    float point_w = 1.00;//[[dict objectForKey:@"arg2"] floatValue];
    float point_h = 1.00;//[[dict objectForKey:@"arg3"] floatValue];
	NSURL *URL = [NSURL URLWithString:showurl];
	SVModalWebViewController *webViewController = [[SVModalWebViewController alloc] initWithURL:URL];
    webViewController.navigationController.navigationBar.barTintColor = [UIColor redColor];
    [webViewController.navigationController.navigationBar setBarTintColor:[UIColor redColor]];
    [webViewController.navigationController setNavigationBarHidden:YES animated:YES];
    webViewController.navigationController.navigationBar.hidden = YES;
    [webViewController setModalPresentationStyle:UIModalPresentationFormSheet];
    [webViewController setModalTransitionStyle:UIModalTransitionStyleCrossDissolve];
    UIViewController *showview = [WebViewController WebViewcurrentActiveViewController];
    [showview presentViewController:webViewController animated:YES completion:NULL];
    float pointwidth = point_w;
    float pointheight = point_h;
    CGRect r = [ UIScreen mainScreen ].bounds;
    float tip_width = r.size.height*pointwidth;
    float tip_height = r.size.width*pointheight;
    webViewController.view.superview.frame = CGRectMake((r.size.height - tip_width)/2, (r.size.width - tip_height)/2, tip_width, tip_height);
    //webViewController.view.backgroundColor = [UIColor redColor];
    webViewController.navigationController.navigationBar.hidden = YES;
    //webViewController.view.superview.center = showview.view.center;
    //[webViewController dismissModalViewControllerAnimated:YES];
    //[self dismissViewControllerAnimated:YES];
    
}
+(UIViewController*)WebViewcurrentActiveViewController
{
    UIViewController *result = nil;
    
    UIWindow * window = [[UIApplication sharedApplication] keyWindow];
    if (window.windowLevel != UIWindowLevelNormal)
    {
        NSArray *windows = [[UIApplication sharedApplication] windows];
        for(UIWindow * tmpWin in windows)
        {
            if (tmpWin.windowLevel == UIWindowLevelNormal)
            {
                window = tmpWin;
                break;
            }
        }
    }
    
    UIView *frontView = [[window subviews] objectAtIndex:0];
    id nextResponder = [frontView nextResponder];
    
    if ([nextResponder isKindOfClass:[UIViewController class]])
        result = nextResponder;
    else
        result = window.rootViewController;
    
    return result;
}
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	return YES;
}
-(NSString *) YY_GetConnectDate
{
    NSString *remoteHostName = @"www.apple.com";
    YYReachability* hostReachability = [YYReachability reachabilityWithHostName:remoteHostName];
    NetworkStatus netStatus = [hostReachability currentReachabilityStatus];
    NSString *date = @"0";
    //1是WIFI 2是3G 0是初始状态
    switch (netStatus)
    {
        case NotReachable:        {
            date = @"0";
            break;
        }
            
        case ReachableViaWWAN:        {
            date = @"2";
            break;
        }
        case ReachableViaWiFi:        {
            date = @"1";
            break;
        }
    }
    return date;
}

@end

