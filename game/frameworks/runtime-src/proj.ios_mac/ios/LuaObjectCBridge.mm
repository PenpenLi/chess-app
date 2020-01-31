#import "LuaObjectCBridge.h"

#include "cocos2d.h"
#include "CCLuaEngine.h"
#include "CCLuaBridge.h"
#include "SSKeychain.h"
#include "IAPHelper.h"
#import "AppController.h"
#import "WebViewController.h"
#include <netdb.h>
#include <arpa/inet.h>
#include <UIKit/UIKit.h>
#import "APViewController.h"
#import <mach/mach_time.h>
#import "libqrencode/QRCodeGenerator.h"

using namespace cocos2d;
@implementation LuaObjectCBridge;

static LuaObjectCBridge *_sharedInstance = nil;

+ (LuaObjectCBridge *)sharedInstance
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[LuaObjectCBridge alloc] init];
    });
    return _sharedInstance;
}

- (id)init
{
    if(self=[super init]){
        self.networkHandlers = [[NSMutableArray alloc] init];
        self.reachability = [YYReachability reachabilityForInternetConnection];
    }
    return self;
}

//网络监听=================================
- (void)addNetworkHandler:(int)handler
{
    if (handler){
        [self.networkHandlers addObject:[NSNumber numberWithInt:handler]];
    }
}

- (void)removeNetworkHandler:(int)handler
{
    if (handler){
        [self.networkHandlers removeObject:[NSNumber numberWithInt:handler]];
    }
}

+ (void)registerNetworkHandler:(NSDictionary *)dict
{
    int handler = [[dict objectForKey:@"handler"] intValue];
    [[LuaObjectCBridge sharedInstance] addNetworkHandler:handler];
    if ([LuaObjectCBridge sharedInstance].networkHandlers.count == 1)
    {
        [[LuaObjectCBridge sharedInstance] startNetworkNotifier];
    }
}

+(void)unregisterNetworkHandler:(NSDictionary *)dict
{
    int handler = [[dict objectForKey:@"handler"] intValue];
    [[LuaObjectCBridge sharedInstance] removeNetworkHandler:handler];
    if ([LuaObjectCBridge sharedInstance].networkHandlers.count == 0)
    {
        [[LuaObjectCBridge sharedInstance] stopNetworkNotifier];
    }
}

// 取消所有网络监听
+ (void)unregisterAllNetworkHandler
{
    [[LuaObjectCBridge sharedInstance].networkHandlers removeAllObjects];
    [[LuaObjectCBridge sharedInstance] stopNetworkNotifier];
}

- (void)startNetworkNotifier
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(networkStatusChanged:) name:YYkReachabilityChangedNotification object:nil];
    [self.reachability startNotifier];
    [self updateNetworkStatus:self.reachability];
}

- (void)stopNetworkNotifier
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self.reachability stopNotifier];
}

- (void)networkStatusChanged:(NSNotification *)notification
{
    YYReachability *reachability = notification.object;
    if ([reachability isKindOfClass:[YYReachability class]]) {
        [self updateNetworkStatus:reachability];
    }
}

- (void)updateNetworkStatus:(YYReachability *)reachability
{
    NetworkStatus status = [reachability currentReachabilityStatus];
    for (NSNumber *handler in self.networkHandlers){
        if ([handler intValue]){
            LuaBridge::pushLuaFunctionById([handler intValue]);
            LuaStack *stack = LuaBridge::getStack();
            stack->pushInt((int)status);
            stack->executeFunction(1);
        }
    }
}

// 注册handleOpenUrl
+ (void)registerOpenUrlHandler:(NSDictionary *)dict
{
    id handler = [dict objectForKey:@"handler"];
    if(!handler){
        return;
    }
    int handlerId = [handler intValue];
    [LuaObjectCBridge sharedInstance].openUrlHandler = [NSNumber numberWithInt:handlerId];
}
// handleOpenUrl
+ (BOOL)canHandleOpenUrl:(NSURL *)url
{
    if(!url){
        return NO;
    }
    if (url.scheme == nil || ![url.scheme isEqualToString:@"jyjh"]) {
        return NO;
    }
    NSString *urlString = [url absoluteString];
    if(!urlString){
        return NO;
    }
    const char *utf8String = [urlString UTF8String];
    if(utf8String == NULL){
        return NO;
    }
    return YES;
}
+ (BOOL)handleOpenUrl:(NSURL *)url
{
    if ([self canHandleOpenUrl:url] == NO) {
        return NO;
    }
    NSNumber *handler = [LuaObjectCBridge sharedInstance].openUrlHandler;
    if(!handler){
        return NO;
    }
    int handlerId = [handler intValue];
    if (!handlerId) {
        return NO;
    }
    const char *utf8String = [[url absoluteString] UTF8String];
    LuaBridge::pushLuaFunctionById(handlerId);
    LuaStack *stack = LuaBridge::getStack();
    stack->pushString(utf8String);
    stack->executeFunction(1);
    return YES;
}

#define KEY_ACCESS_GROUP      @"com.kxdyj.game.D58E"
#define KEY_ACCESS_ID         @"UUID"

// 获取UUID
+ (NSString*)getUUID
{
    string m_deviceUUID;
    NSError *error = nil;
    NSString *deviceUUID = [SSKeychain passwordForService:KEY_ACCESS_ID account:KEY_ACCESS_GROUP error:&error];
    
    if ([deviceUUID length] > 0 )
    {
        m_deviceUUID = [deviceUUID UTF8String];
    }
    else
    {
        // 获取IDFV-identifierForVendor
        NSString *result = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
        if ([result length] > 0)
        {
            m_deviceUUID = [result UTF8String];
            // 清除id中的“-”
            for (string::iterator itr = m_deviceUUID.begin(); itr != m_deviceUUID.end(); itr++)
            {
                if (*itr == '-')
                {
                    m_deviceUUID.erase(itr);
                }
            }
            NSString *uuidSring = [[NSString alloc] initWithBytes:m_deviceUUID.c_str() length:m_deviceUUID.length() encoding:NSUTF8StringEncoding];
            [SSKeychain setPassword:uuidSring forService:KEY_ACCESS_ID account:KEY_ACCESS_GROUP];
        }
    }
    // 通过brige返回给lua需要返回objectC的字符串类型
    NSString *returnUUID = [NSString stringWithUTF8String:m_deviceUUID.c_str()];
    return returnUUID;
}

// 设置粘贴板内容
+ (void)setClipboardText:(NSDictionary *)dict
{
    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
    pasteboard.string = [dict objectForKey:@"content"];
}

// 获取粘贴板内容
+ (NSString *)getClipboardText
{
    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
    NSString *str = pasteboard.string;
    if (str == nil){
        str = @"";
    }
    return str;
}

// 浏览器打开URL
+ (void)openUrl:(NSDictionary *)dict
{
    string str = [[dict objectForKey:@"url"] UTF8String];
    NSString *urlString = [[NSString alloc] initWithUTF8String:str.c_str()];
    BOOL canOpen = [[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:urlString]];
    if (canOpen)
    {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlString]];
    }
}

// 是否已安装微信客户端
+ (bool)isInstallWechat
{
    NSURL* url = [NSURL URLWithString:@"wechat://"];
    bool ret = [[UIApplication sharedApplication] canOpenURL:url];
    if (ret == false){
        url = [NSURL URLWithString:@"weixin://"];
        ret = [[UIApplication sharedApplication] canOpenURL:url];
    }
    return ret;
}

// 获取设备类型
+ (NSString*)getDeviceType
{
    return [UIDevice currentDevice].model;
}

// 获取当前网络状态 0:无网络 1:WiFi 2:蜂窝网络(3G/4G)
+ (int)getCurrentNetworkType
{
    NetworkStatus status = [[[LuaObjectCBridge sharedInstance] reachability] currentReachabilityStatus];
    return status;
}

// 当前网络是否连接
+ (bool)isNetworkAvailable
{
    bool flag = [self getCurrentNetworkType] != 0;
    return flag;
}

// 打开微信
+ (void)openWX
{
    if([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"wechat://"]])
    {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"wechat://"]];
    }
    else if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"weixin://"]])
    {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"weixin://"]];
    }
}

// 打开QQ
+ (void)openQQ
{
    NSURL* url = [NSURL URLWithString:@"mqq://"];
    if([[UIApplication sharedApplication] canOpenURL:url])
    {
        [[UIApplication sharedApplication] openURL:url];
    }
}

// 打开支付宝
+ (void)openZFB
{
    if([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"alipay://"]])
    {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"alipay://"]];
    }
    else if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"alipayqr://"]])
    {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"alipayqr://"]];
    }
    else if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"alipayshare://"]])
    {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"alipayshare://"]];
    }
}

// 获取电量
+(float)getBatteryLevel
{
    [UIDevice currentDevice].batteryMonitoringEnabled = YES;
    float data =  [UIDevice currentDevice].batteryLevel*100.f;
    return data;
}

// 获取电池状态
+(int)getBatteryState
{
    [UIDevice currentDevice].batteryMonitoringEnabled = YES;
    int state =  [UIDevice currentDevice].batteryState;
    return state;
}

// 实例iaphelper
+ (void) InstanceIOSBuy
{
    [IAPHelper sharedIAPHelper];
}

// ios购买
+ (void) IOSBuy:(NSDictionary *)dict
{
    int isSandBox = 1;//[[dict objectForKey:@"arg1"] intValue];
    int itemID = 1;//[[dict objectForKey:@"arg2"] intValue];
    string productid = [[dict objectForKey:@"arg1"] UTF8String];
    int price = [[dict objectForKey:@"arg2"] intValue];
    string playerid = [[dict objectForKey:@"arg3"] UTF8String];
    string httpServerIP = "";//[[dict objectForKey:@"arg6"] UTF8String];
    int httpServerPort = 80;//[[dict objectForKey:@"arg7"] intValue];
    string httpServerPage = "";//[[dict objectForKey:@"arg8"] UTF8String];
    [[IAPHelper sharedIAPHelper]buy:productid flag:isSandBox buyItemID:itemID buyPrice:price buyInfo:playerid ip:httpServerIP port:httpServerPort page:httpServerPage ];
}

+ (void) ResumIOSBuy:(NSDictionary *)dict
{
    int isSandBox = [[dict objectForKey:@"arg1"] intValue];
    string strBuyStr = [[dict objectForKey:@"arg2"] UTF8String];
    string iosOrderid = [[dict objectForKey:@"arg3"] UTF8String];
    string httpServerIP = [[dict objectForKey:@"arg4"] UTF8String];
    int httpServerPort = [[dict objectForKey:@"arg5"] intValue];
    string httpServerPage = [[dict objectForKey:@"arg6"] UTF8String];
    [[IAPHelper sharedIAPHelper]resumBuy:strBuyStr flag:isSandBox buyInfo:iosOrderid ip:httpServerIP port:httpServerPort page:httpServerPage];
}

// 完成ios交易
+ (void) CompletIOSBuy:(NSDictionary *)dict
{
    string strBuyID = [[dict objectForKey:@"arg1"] UTF8String];
    [[IAPHelper sharedIAPHelper]CompleteSeverTransaction:strBuyID];
}
// ios得到订单号
+ (void) CompletIOSOrderID:(NSDictionary *)dict
{
    string success = [[dict objectForKey:@"arg1"] UTF8String];
    string message = [[dict objectForKey:@"arg2"] UTF8String];
    int data = [[dict objectForKey:@"arg3"] intValue];
    [[IAPHelper sharedIAPHelper] IosSetOrderID:data message:message success:success ];
}

//zhifu
+ (void) DlDoPay:(NSDictionary *)dict
{
    NSString *requireurl = [dict objectForKey:@"arg1"];
    int paytype = [[dict objectForKey:@"arg2"] intValue];
    APViewController *payinstance = [APViewController getInstance];
    [payinstance BeginDoHYWPay:requireurl paytype:(int)paytype];
}


//生成二维码
+ (bool)createQRCode:(NSDictionary *)dict
{
    if(dict==nil){
        return false;
    }
    NSString *url = [dict valueForKey:@"url"];
    CGFloat width = [[dict valueForKey:@"width"] floatValue];
    NSString *filePath = [dict valueForKey:@"filePath"];
    if(url==nil || width <= 0 || filePath == nil){
        return false;
    }
    UIImage *image = [QRCodeGenerator qrImageForString:url imageSize:width Topimg:nil];
    if(image == nil){
        return false;
    }
    bool result = [UIImagePNGRepresentation(image) writeToFile:filePath atomically:YES];
    return result;
}

// 微信登录
+ (void)registerWechatAppId:(NSDictionary *)dict{
    if (!dict) {
        return;
    }
    NSString *wechatAppId = [dict objectForKey:@"appId"];
    if (wechatAppId==nil || [wechatAppId isEqualToString:@""]) {
        return;
    }
    AppController *appController = (AppController *)([UIApplication sharedApplication].delegate);
    [appController registerWechatAppId:wechatAppId];
}

+ (void)sendWechatLoginReq:(NSDictionary *)dict
{
    id handler = [dict objectForKey:@"handler"];
    if(!handler){
        return;
    }
    int handlerId = [handler intValue];
    [LuaObjectCBridge sharedInstance].wechatLoginHandler = [NSNumber numberWithInt:handlerId];
    AppController *appController = (AppController *)([UIApplication sharedApplication].delegate);
    [appController sendWechatLoginReq];
}

+ (void)handleWechatLoginResp:(NSString *)code
{
    if(!code){
        return;
    }
    const char *utf8String = [code UTF8String];
    if(utf8String == NULL){
        return;
    }
    NSNumber *handler = [LuaObjectCBridge sharedInstance].wechatLoginHandler;
    if(!handler){
        return;
    }
    int handlerId = [handler intValue];
    if (!handlerId) {
        return;
    }
    LuaBridge::pushLuaFunctionById(handlerId);
    LuaStack *stack = LuaBridge::getStack();
    stack->pushString(utf8String);
    stack->executeFunction(1);
    [LuaObjectCBridge sharedInstance].wechatLoginHandler = nil;
}

//微信分享：去向：会话/朋友圈/收藏 内容：文字/图片/音乐/视频/网页/小程序
+ (void)shareToWechat:(NSDictionary *)dict
{
    AppController *appController = (AppController *)([UIApplication sharedApplication].delegate);
    [appController shareToWechat:dict];
}

//发起定位
+ (void)startLocation:(NSDictionary *)dict
{
    id handler = [dict objectForKey:@"handler"];
    if(!handler){
        return;
    }
    int handlerId = [handler intValue];
    [LuaObjectCBridge sharedInstance].locationHandler = [NSNumber numberWithInt:handlerId];
    AppController *appController = (AppController *)([UIApplication sharedApplication].delegate);
    [appController startLocation];
}

+ (void)handleLocation:(NSDictionary *)dict
{
    if (dict == nil) {
        return;
    }
    NSNumber *handler = [LuaObjectCBridge sharedInstance].locationHandler;
    if(!handler){
        return;
    }
    int handlerId = [handler intValue];
    if (!handlerId) {
        return;
    }
    BOOL success = [[dict objectForKey:@"success"] boolValue];
    float latitude = [[dict objectForKey:@"latitude"] floatValue];
    float longitude = [[dict objectForKey:@"longitude"] floatValue];
    NSString *string = [NSString stringWithFormat:@"%d,%f,%f",success,latitude,longitude];
    const char *utf8String = [string UTF8String];
    LuaBridge::pushLuaFunctionById(handlerId);
    LuaStack *stack = LuaBridge::getStack();
    stack->pushString(utf8String);
    stack->executeFunction(1);
    [LuaObjectCBridge sharedInstance].locationHandler = nil;
}

//保存图片到相册 dict:{handler=xxx,filePath=xxx}
+ (void)saveImage:(NSDictionary *)dict
{
    id handler = [dict objectForKey:@"handler"];
    if(!handler){
        return;
    }
    int handlerId = [handler intValue];
    [LuaObjectCBridge sharedInstance].saveImageHandler = [NSNumber numberWithInt:handlerId];
    AppController *appController = (AppController *)([UIApplication sharedApplication].delegate);
    [appController saveImage:dict];
}
+ (void)handleSaveImage:(BOOL)success
{
    NSNumber *handler = [LuaObjectCBridge sharedInstance].saveImageHandler;
    if(!handler){
        return;
    }
    int handlerId = [handler intValue];
    if (!handlerId) {
        return;
    }
    LuaBridge::pushLuaFunctionById(handlerId);
    LuaStack *stack = LuaBridge::getStack();
    stack->pushBoolean(success);
    stack->executeFunction(1);
    [LuaObjectCBridge sharedInstance].saveImageHandler = nil;
}

//从相册或者相机获取图片,dict:{handler=xxx,type=xxx,filePath=xxx,size=xxx}
+ (void)getImage:(NSDictionary *)dict
{
    id handler = [dict objectForKey:@"handler"];
    if(!handler){
        return;
    }
    int handlerId = [handler intValue];
    [LuaObjectCBridge sharedInstance].getImageHandler = [NSNumber numberWithInt:handlerId];
    AppController *appController = (AppController *)([UIApplication sharedApplication].delegate);
    [appController getImage:dict];
}
+ (void)handleGetImage:(BOOL)success
{
    NSNumber *handler = [LuaObjectCBridge sharedInstance].getImageHandler;
    if(!handler){
        return;
    }
    int handlerId = [handler intValue];
    if (!handlerId) {
        return;
    }
    LuaBridge::pushLuaFunctionById(handlerId);
    LuaStack *stack = LuaBridge::getStack();
    stack->pushBoolean(success);
    stack->executeFunction(1);
    [LuaObjectCBridge sharedInstance].getImageHandler = nil;
}

@end
