//
//  RootViewController.h
//  SVWebViewController
//
//  Created by Sam Vermette on 21.02.11.
//  Copyright 2011 Sam Vermette. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RootViewController.h"

@interface WebViewController : UIViewController
- (IBAction)pushWebViewController;
- (IBAction)presentWebViewController;
- (void)presentWebViewController:(NSDictionary*) dict;
-(NSString *) YY_GetConnectDate;
+ (UIViewController*)WebViewcurrentActiveViewController;
@end
