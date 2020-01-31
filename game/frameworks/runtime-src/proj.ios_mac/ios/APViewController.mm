//
//  APViewController.m
//

#import "APViewController.h"
//#import "Order.h"
//#import "DataSigner.h"
#include "../../Classes/SDK/SPlatform.h"
#include "../../Classes/SDK/SInstance.h"
#include "../../Classes/CallLuaFunction.h"
#import "AppController.h"
#import "WebViewController.h"
#import "LuaObjectCBridge.h"
using namespace SDK;
//@implementation Product


//@end

@interface APViewController ()
@property (nonatomic,strong) UIAlertView * mAlert;
@property (nonatomic, retain) NSString *Requireurl;
@end

@implementation APViewController


static APViewController *APViewControllerHelper = nil;

+(APViewController*) getInstance
{
    if (APViewControllerHelper == nil)
    {
        APViewControllerHelper = [[APViewController alloc] init];
    }
    return APViewControllerHelper;
}

#pragma mark -
#pragma mark   ==============产生随机订单号==============

//
//- (NSString *)generateTradeNO
//{
//	static int kNumber = 15;
//	
//	NSString *sourceStr = @"0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ";
//	NSMutableString *resultStr = [[NSMutableString alloc] init];
//	srand((unsigned)time(0));
//	for (int i = 0; i < kNumber; i++)
//	{
//		unsigned index = rand() % [sourceStr length];
//		NSString *oneStr = [sourceStr substringWithRange:NSMakeRange(index, 1)];
//		[resultStr appendString:oneStr];
//	}
//	return resultStr;
//}
//#pragma mark -
//#pragma mark UITableViewDelegate
//- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
//{
//	return 55.0f;
//}

#pragma mark -
#pragma mark UITableViewDataSource
//- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
//{
//	return [self.productList count];
//}

#pragma mark -
#pragma mark   ==============点击订单模拟支付行为==============
//
-(NSString *)getOrderInfo:(NSString *)urldz
{
    //第一步，创建URL
    NSURL *url = [NSURL URLWithString:urldz];
    
    //第二步，通过URL创建网络请求
    NSURLRequest *request = [[NSURLRequest alloc]initWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:10];
    //NSURLRequest初始化方法第一个参数：请求访问路径，第二个参数：缓存协议，第三个参数：网络请求超时时间（秒）
    /*其中缓存协议是个枚举类型包含：
     NSURLRequestUseProtocolCachePolicy（基础策略）
     NSURLRequestReloadIgnoringLocalCacheData（忽略本地缓存）
     NSURLRequestReturnCacheDataElseLoad（首先使用缓存，如果没有本地缓存，才从原地址下载）
     NSURLRequestReturnCacheDataDontLoad（使用本地缓存，从不下载，如果本地没有缓存，则请求失败，此策略多用于离线操作）
     NSURLRequestReloadIgnoringLocalAndRemoteCacheData（无视任何缓存策略，无论是本地的还是远程的，总是从原地址重新下载）
     NSURLRequestReloadRevalidatingCacheData（如果本地缓存是有效的则不下载，其他任何情况都从原地址重新下载）*/
    //第三步，连接服务器
    NSData *received = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
    
    NSString *str = [[NSString alloc]initWithData:received encoding:NSUTF8StringEncoding];
    NSLog(@"%@",str);
    return str;
}
- (NSString *)dictionaryWithJsonString:(NSString *)jsonString
    {
        
        if (jsonString == nil) {
            
            return @"";
            
            
            
        }
        
        
        
        NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
        
        NSError *err;
        
        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData
                             
                                                            options:NSJSONReadingMutableContainers
                             
                                                              error:&err];
        
        //    if(err) {
        //
        //        NSLog(@"json解析失败：%@",err);
        //        
        //        return @"";
        //        
        //    }
        
        return [dic objectForKey:@"data"];
        
    }

- (void)showAlertWait:(NSString *)title {
    _mAlert = [[UIAlertView alloc] initWithTitle:title message:nil delegate:self cancelButtonTitle:nil otherButtonTitles: nil];
    [_mAlert show];
    UIActivityIndicatorView* aiv = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    aiv.center = CGPointMake(_mAlert.frame.size.width / 2.0f - 15, _mAlert.frame.size.height / 2.0f + 10 );
    [aiv startAnimating];
    [_mAlert addSubview:aiv];
}
- (void)hideAlertWait {
    if (_mAlert != nil){
        [_mAlert dismissWithClickedButtonIndex:0 animated:YES];
        _mAlert = nil;
    }
}

- (void)alertMsg:(NSString *)msg
{
    UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"提示" message:msg delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    [alert show];
}

- (void)BeginDoHYWPay:(NSString *)requireurl paytype:(int)paytype
{
    [self showAlertWait:@"正在创建预支付单,请稍后"];
    requesttype = paytype;
    self.Requireurl = requireurl;
    [self performSelector:@selector(DoHYWPay) withObject:nil afterDelay:0.5];
}

- (void)DoHYWPay
{
    NSString *_url   = self.Requireurl;
    NSString *urlString = [_url stringByAppendingString:@"&ver=2.0"];
    //解析服务端返回json数据
    NSError *error;
    //加载一个NSURL对象
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:urlString]];
    //将请求的url数据放到NSData对象中
    NSData *response = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
    if ( response != nil) {
        NSMutableDictionary *dict = NULL;
        dict = [NSJSONSerialization JSONObjectWithData:response options:NSJSONReadingMutableLeaves error:&error];
        //NSString *RequestDate = [self getOrderInfo:urlString];
        NSLog(@"url:%@",urlString);
        if(dict != nil){
            NSMutableString *retcode = [dict objectForKey:@"success"];
            if (retcode.boolValue == true){
                NSMutableDictionary *params = [dict objectForKey:@"data"];
                //调起支付
                NSString * headstr = params[@"payhead"];
                if ([headstr  isEqual: @"H5"])
                {    /*NSDictionary *tempdict = [NSDictionary dictionaryWithObject:@"htt p://baidu.com" forKey:@"arg1"];
                    WebViewController* controller = [WebViewController new];
                    [controller presentWebViewController:tempdict];
                    [self hideAlertWait];*/
                    NSDictionary *tempdict = [NSDictionary dictionaryWithObject:params[@"url"] forKey:@"arg1"];
                    WebViewController* controller = [WebViewController new];
                    [controller presentWebViewController:tempdict];
                    [self hideAlertWait];
                }
                
            }else{
                [self hideAlertWait];
                [self alertMsg:[dict objectForKey:@"message"]];
            }
        }else{
            //return @"服务器返回错误，未获取到json对象";
            [self hideAlertWait];
            [self alertMsg:@"服务器返回错误"];
        }
    }else{
        [self hideAlertWait];
        [self alertMsg:@"服务器返回错误"];
    }
    
    INSTANCE(CallLuaFunction)->SendEventToLua("setPayBtnClicked");
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    
}
-(UIViewController*)WebViewcurrentActiveViewController
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
@end
