/****************************************************************************
 Copyright (c) 2010-2013 cocos2d-x.org
 Copyright (c) 2013-2014 Chukong Technologies Inc.

 http://www.cocos2d-x.org

 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:

 The above copyright notice and this permission notice shall be included in
 all copies or substantial portions of the Software.

 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 THE SOFTWARE.
 ****************************************************************************/

#import "WeChatSDK/WXApi.h"
#import <CoreLocation/CoreLocation.h>

@class RootViewController;

@interface AppController : NSObject <UIApplicationDelegate,WXApiDelegate,CLLocationManagerDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate>
{
    UIWindow *window;
    RootViewController *viewController;
}
@property(strong,nonatomic) NSURL *openUrl;
@property(strong,nonatomic) CLLocationManager *locationManager;
@property(strong,nonatomic) NSDictionary *getImageDict;

//注册微信APPID
- (void)registerWechatAppId:(NSString *)appId;

//发起微信登录
- (void)sendWechatLoginReq;

//微信分享：去向：会话/朋友圈/收藏 内容：文字/图片/音乐/视频/网页/小程序
- (void)shareToWechat:(NSDictionary *)dict;

//发起定位
- (void)startLocation;

//保存图片到相册，dict:{handler=xxx,filePath=xxx}
- (void)saveImage:(NSDictionary *)dict;

//从相册获取图片,dict:{handler=xxx,type=xxx,filePath=xxx,size=xxx}
- (void)getImage:(NSDictionary *)dict;

@end

