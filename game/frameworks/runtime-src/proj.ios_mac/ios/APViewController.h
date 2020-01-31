//
//  APViewController.h
//  AliSDKDemo
//
//  Created by 方彬 on 11/29/13.
//  Copyright (c) 2013 Alipay.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CommonCrypto/CommonDigest.h>

@interface APViewController : UIViewController<UITableViewDelegate, UITableViewDataSource>
{
    int requesttype;
}
//@property (strong,nonatomic) PaytendPayApi * payApi;
//@property (weak, nonatomic) IBOutlet UITableView *productTableView;
//@property(nonatomic, strong)NSMutableArray *productList;
+(APViewController*) getInstance;
- (void)DoHYWPay;
- (void)BeginDoHYWPay:(NSString *)requireurl paytype:(int)paytype;
-(NSString *)getOrderInfo:(NSString *)urldz;
- (NSString *)dictionaryWithJsonString:(NSString *)jsonString;
-(UIViewController*)WebViewcurrentActiveViewController;
- (void)alertMsg:(NSString *)msg;
@end
