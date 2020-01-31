#ifndef COCOS2DX_SAMPLES_TESTLUA_PROJ_IOS_LUAOBJECTCBRIDGETEST_H
#define COCOS2DX_SAMPLES_TESTLUA_PROJ_IOS_LUAOBJECTCBRIDGETEST_H
#import <Foundation/Foundation.h>
#include <string>
#import "YYReachability.h"

using namespace std;

@interface LuaObjectCBridge:NSObject {
}
@property(strong,nonatomic) YYReachability *reachability;

// 获取单例
+ (LuaObjectCBridge *)sharedInstance;

@property(strong,nonatomic) NSMutableArray *networkHandlers;
// 注册网络监听
+ (void)registerNetworkHandler:(NSDictionary *)dict;
// 取消网络监听
+ (void)unregisterNetworkHandler:(NSDictionary *)dict;
// 取消所有网络监听
+ (void)unregisterAllNetworkHandler;

// 第三方APP调起本游戏处理手柄
@property(strong,nonatomic) NSNumber *openUrlHandler;
// 注册handleOpenUrl
+ (void)registerOpenUrlHandler:(NSDictionary *)dict;
// handleOpenUrl
+ (BOOL)canHandleOpenUrl:(NSURL *)url;
+ (BOOL)handleOpenUrl:(NSURL *)url;

// 获取UUID
+ (NSString*)getUUID;

// 设置粘贴板内容
+ (void)setClipboardText:(NSDictionary *)dict;

// 获取粘贴板内容
+ (NSString *)getClipboardText;

// 浏览器打开URL
+ (void)openUrl:(NSDictionary *)dict;

// 是否已安装微信客户端
+ (bool)isInstallWechat;

// 获取设备类型
+ (NSString*)getDeviceType;

// 获取当前网络状态 0:无网络 1:WiFi 2:蜂窝网络(3G/4G)
+ (int)getCurrentNetworkType;

// 是否已安装微信客户端
+ (bool)isNetworkAvailable;

// 打开微信
+ (void)openWX;

// 打开QQ
+ (void)openQQ;

// 打开支付宝
+ (void)openZFB;

// 获取电量
+(float)getBatteryLevel;

// 获取电池状态
+(int)getBatteryState;

// ios支付
+ (void) InstanceIOSBuy;
+ (void) IOSBuy:(NSDictionary *)dict;
+ (void) CompletIOSBuy:(NSDictionary *)dict;
+ (void) ResumIOSBuy:(NSDictionary *)dict;

//生成二维码
+ (bool)createQRCode:(NSDictionary *)dict;

// 微信登录回调处理手柄
@property(strong,nonatomic) NSNumber *wechatLoginHandler;
// 微信登录
+ (void)registerWechatAppId:(NSDictionary *)dict;
+ (void)sendWechatLoginReq:(NSDictionary *)dict;
+ (void)handleWechatLoginResp:(NSString *)code;
//微信分享：去向：会话/朋友圈/收藏 内容：文字/图片/音乐/视频/网页/小程序
+ (void)shareToWechat:(NSDictionary *)dict;

// 定位回调处理手柄
@property(strong,nonatomic) NSNumber *locationHandler;
//发起定位
+ (void)startLocation:(NSDictionary *)dict;
+ (void)handleLocation:(NSDictionary *)dict;

//保存图片回调处理手柄
@property(strong,nonatomic) NSNumber *saveImageHandler;
//保存图片到相册，dict:{handler=xxx,filePath=xxx}
+ (void)saveImage:(NSDictionary *)dict;
+ (void)handleSaveImage:(BOOL)success;

//获取图片回调处理手柄
@property(strong,nonatomic) NSNumber *getImageHandler;
//从相册或者相机获取图片,dict:{handler=xxx,type=xxx,filePath=xxx,size=xxx}
+ (void)getImage:(NSDictionary *)dict;
+ (void)handleGetImage:(BOOL)success;

@end

#endif  //  COCOS2DX_SAMPLES_TESTLUA_PROJ_IOS_LUAOBJECTCBRIDGETEST_H
