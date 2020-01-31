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

#import <UIKit/UIKit.h>
#import "cocos2d.h"

#import "AppController.h"
#import "AppDelegate.h"
#import "RootViewController.h"
#import "platform/ios/CCEAGLView-ios.h"
#import "LuaObjectCBridge.h"

@implementation AppController

#pragma mark -
#pragma mark Application lifecycle

// cocos2d application instance
static AppDelegate s_sharedApplication;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    cocos2d::Application *app = cocos2d::Application::getInstance();
    app->initGLContextAttrs();
    cocos2d::GLViewImpl::convertAttrs();

    // Override point for customization after application launch.

    // Add the view controller's view to the window and display.
    window = [[UIWindow alloc] initWithFrame: [[UIScreen mainScreen] bounds]];
    CCEAGLView *eaglView = [CCEAGLView viewWithFrame: [window bounds]
                                     pixelFormat: (NSString*)cocos2d::GLViewImpl::_pixelFormat
                                     depthFormat: cocos2d::GLViewImpl::_depthFormat
                              preserveBackbuffer: NO
                                      sharegroup: nil
                                   multiSampling: NO
                                 numberOfSamples: 0 ];

    [eaglView setMultipleTouchEnabled:YES];
    
    // Use RootViewController manage CCEAGLView
    viewController = [[RootViewController alloc] initWithNibName:nil bundle:nil];
    viewController.wantsFullScreenLayout = YES;
    viewController.view = eaglView;

    // Set RootViewController to window
    if ( [[UIDevice currentDevice].systemVersion floatValue] < 6.0)
    {
        // warning: addSubView doesn't work on iOS6
        [window addSubview: viewController.view];
    }
    else
    {
        // use this method on ios6
        [window setRootViewController:viewController];
    }
    
    [window makeKeyAndVisible];

    [[UIApplication sharedApplication] setStatusBarHidden: YES];
    //关闭系统自动锁屏
    [[UIApplication sharedApplication] setIdleTimerDisabled:YES];

    // IMPORTANT: Setting the GLView should be done after creating the RootViewController
    cocos2d::GLView *glview = cocos2d::GLViewImpl::createWithEAGLView(eaglView);
    cocos2d::Director::getInstance()->setOpenGLView(glview);

    app->run();
    
    return YES;
}

//注册微信APPID
- (void)registerWechatAppId:(NSString *)appId
{
    NSLog(@"====registerWechatAppId:%@",appId);
    [WXApi registerApp:appId enableMTA:NO];
}

//发起微信登录
- (void)sendWechatLoginReq
{
    SendAuthReq *req = [[[SendAuthReq alloc] init] autorelease];
    req.scope = @"snsapi_userinfo";
    req.state = @"login";
    [WXApi sendReq:req];
}

//微信分享：
- (void)shareToWechat:(NSDictionary *)dict
{
    if (dict == nil || [dict objectForKey:@"type"] == nil || [dict objectForKey:@"scene"] == nil) {
        return;
    }
    int scene = [[dict objectForKey:@"scene"] intValue];
    if (scene < WXSceneSession || scene > WXSceneSpecifiedSession) {
        return;
    }
    int type = [[dict objectForKey:@"type"] intValue];
    if (type == 1) {
        [self shareTextToWechat:dict scene:(WXScene)scene];
    }
    else if (type == 2){
        [self shareImageToWechat:dict scene:(WXScene)scene];
    }
    else if (type == 3){
        [self shareMusicToWechat:dict scene:(WXScene)scene];
    }
    else if (type == 4){
        [self shareVideoToWechat:dict scene:(WXScene)scene];
    }
    else if (type == 5){
        [self shareWebpageToWechat:dict scene:(WXScene)scene];
    }
    else if (type == 6){
        [self shareMiniProgramToWechat:dict scene:(WXScene)scene];
    }
}

//微信分享文字1
- (void)shareTextToWechat:(NSDictionary *)dict scene:(WXScene)scene
{
    SendMessageToWXReq *req = [[SendMessageToWXReq alloc] init];
    req.bText = YES;
    req.text = [dict objectForKey:@"text"];
    req.scene = scene;
    [WXApi sendReq:req];
}

//微信分享图片2
- (void)shareImageToWechat:(NSDictionary *)dict scene:(WXScene)scene
{
    WXMediaMessage *message = [WXMediaMessage message];
    message.title = [dict objectForKey:@"title"];
    message.description = [dict objectForKey:@"description"];
    
    WXImageObject *ext = [WXImageObject object];
    NSString *imagePath = [dict objectForKey:@"imagePath"];
    NSLog(@"imagePath :%@",imagePath);
    ext.imageData = [NSData dataWithContentsOfFile:imagePath];
    UIImage* image = [UIImage imageWithData:ext.imageData];
    ext.imageData = UIImagePNGRepresentation(image);
    
    message.mediaObject = ext;
    
    SendMessageToWXReq* req = [[[SendMessageToWXReq alloc] init]autorelease];
    req.bText = NO;
    req.message = message;
    req.scene = scene;
    
    [WXApi sendReq:req];
}

//微信分享音乐3
- (void)shareMusicToWechat:(NSDictionary *)dict scene:(WXScene)scene
{
    WXMediaMessage *message = [WXMediaMessage message];
    message.title = [dict objectForKey:@"title"];
    message.description = [dict objectForKey:@"description"];
    //图片
    NSString *imagePath = [dict objectForKey:@"imagePath"];
    NSLog(@"imagePath :%@",imagePath);
    NSData *data = [NSData dataWithContentsOfFile:imagePath];
    [message setThumbImage:[UIImage imageWithData:data]];
    WXMusicObject *ext = [WXMusicObject object];
    ext.musicUrl = [dict objectForKey:@"musicUrl"];
    ext.musicDataUrl = [dict objectForKey:@"musicDataUrl"];
    
    message.mediaObject = ext;
    
    SendMessageToWXReq* req = [[[SendMessageToWXReq alloc] init]autorelease];
    req.bText = NO;
    req.message = message;
    req.scene = scene;
    
    [WXApi sendReq:req];
}

//微信分享视频4
- (void)shareVideoToWechat:(NSDictionary *)dict scene:(WXScene)scene
{
    WXMediaMessage *message = [WXMediaMessage message];
    message.title = [dict objectForKey:@"title"];
    message.description = [dict objectForKey:@"description"];
    //图片
    NSString *imagePath = [dict objectForKey:@"imagePath"];
    NSLog(@"imagePath :%@",imagePath);
    NSData *data = [NSData dataWithContentsOfFile:imagePath];
    [message setThumbImage:[UIImage imageWithData:data]];
    
    WXVideoObject *ext = [WXVideoObject object];
    ext.videoUrl = [dict objectForKey:@"videoUrl"];
    
    message.mediaObject = ext;
    
    SendMessageToWXReq* req = [[[SendMessageToWXReq alloc] init]autorelease];
    req.bText = NO;
    req.message = message;
    req.scene = scene;
    
    [WXApi sendReq:req];
}

//微信分享网页5
- (void)shareWebpageToWechat:(NSDictionary *)dict scene:(WXScene)scene
{
    WXMediaMessage *message = [WXMediaMessage message];
    message.title = [dict objectForKey:@"title"];
    message.description = [dict objectForKey:@"description"];
    //图片
    NSString *imagePath = [dict objectForKey:@"imagePath"];
    NSLog(@"imagePath :%@",imagePath);
    NSData *data = [NSData dataWithContentsOfFile:imagePath];
    [message setThumbImage:[UIImage imageWithData:data]];
    
    WXWebpageObject *ext = [WXWebpageObject object];
    ext.webpageUrl = [dict objectForKey:@"webpageUrl"];
    
    message.mediaObject = ext;
    
    SendMessageToWXReq* req = [[[SendMessageToWXReq alloc] init]autorelease];
    req.bText = NO;
    req.message = message;
    req.scene = scene;
    
    [WXApi sendReq:req];
}

//微信分享小程序6
- (void)shareMiniProgramToWechat:(NSDictionary *)dict scene:(WXScene)scene
{
    WXMiniProgramObject *object = [WXMiniProgramObject object];
    object.webpageUrl = [dict objectForKey:@"webpageUrl"];
    object.userName = [dict objectForKey:@"userName"];
    object.path = [dict objectForKey:@"path"];
    
    NSString *imagePath = [dict objectForKey:@"imagePath"];
    NSLog(@"imagePath :%@",imagePath);
    NSData *data = [NSData dataWithContentsOfFile:imagePath];
    UIImage *image = [UIImage imageWithData:data];
    object.hdImageData = UIImagePNGRepresentation(image);
    object.withShareTicket = [[dict objectForKey:@"withShareTicket"] boolValue];
    object.miniProgramType = (WXMiniProgramType)[[dict objectForKey:@"miniProgramType"] intValue];
    
    WXMediaMessage *message = [WXMediaMessage message];
    message.title = [dict objectForKey:@"title"];
    message.description = [dict objectForKey:@"description"];
    message.thumbData = nil;  //兼容旧版本节点的图片，小于32KB，新版本优先
    //使用WXMiniProgramObject的hdImageData属性
    message.mediaObject = object;
    
    SendMessageToWXReq *req = [[SendMessageToWXReq alloc] init];
    req.bText = NO;
    req.message = message;
    req.scene = scene;  //目前只支持会话
    [WXApi sendReq:req];
}

//微信回调第三方应用
- (void)onReq:(BaseReq *)req
{
}

- (void)onResp:(BaseResp *)resp
{
    //微信登录返回
    if([resp isKindOfClass:[SendAuthResp class]])
    {
        SendAuthResp *resp2 = (SendAuthResp *)resp;
        if (resp2.errCode == 0 && resp2.code != nil) {
            [LuaObjectCBridge handleWechatLoginResp:resp2.code];
        }
    }
}

//发起定位
- (void)startLocation
{
    if (self.locationManager == nil) {
        self.locationManager = [[CLLocationManager alloc] init];
        self.locationManager.delegate = self;
        self.locationManager.desiredAccuracy = kCLLocationAccuracyKilometer;
    }
    if ([CLLocationManager locationServicesEnabled] == NO) {
        NSLog(@"locationServicesEnabled == NO");
    }
    [self.locationManager requestWhenInUseAuthorization];
    [self.locationManager startUpdatingLocation];
}

//定位授权变化
- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
    NSLog(@"=================didChangeAuthorizationStatus:%d",status);
}

//定位成功
- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations
{
    NSLog(@"===========================didUpdateLocations===============");
    CLLocation *location = [locations lastObject];
    float latitude = location.coordinate.latitude;
    float longitude = location.coordinate.longitude;
    [self handleLocation:YES latitude:latitude longitude:longitude];
    [self.locationManager stopUpdatingLocation];
}

//定位失败
- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    NSLog(@"===========================didFailWithError===============%@",[error localizedDescription]);
    [self handleLocation:NO latitude:0 longitude:0];
    [self.locationManager stopUpdatingLocation];
}

//处理定位结果
- (void)handleLocation:(BOOL)success latitude:(float)latitude longitude:(float)longitude
{
    NSMutableDictionary *dict = [[[NSMutableDictionary alloc] init] autorelease];
    [dict setObject:[NSNumber numberWithBool:success] forKey:@"success"];
    [dict setObject:[NSNumber numberWithFloat:latitude] forKey:@"latitude"];
    [dict setObject:[NSNumber numberWithFloat:longitude] forKey:@"longitude"];
    [LuaObjectCBridge handleLocation:dict];
}

//保存图片到相册，dict:{handler=xxx,filePath=xxx}
- (void)saveImage:(NSDictionary *)dict
{
    if (dict == nil or [dict objectForKey:@"filePath"] == nil ) {
        [LuaObjectCBridge handleSaveImage:false];
        return;
    }
    NSString *filePath = [dict objectForKey:@"filePath"];
    UIImage *image = [UIImage imageWithContentsOfFile:filePath];
    if (image == nil) {
        [LuaObjectCBridge handleSaveImage:false];
        return;
    }
    UIImageWriteToSavedPhotosAlbum(image, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
}
- (void)image:(UIImage *)image didFinishSavingWithError: (NSError *)error contextInfo:(void*)contextInfo
{
    if (error == NULL) {
        [LuaObjectCBridge handleSaveImage:true];
    }else{
        [LuaObjectCBridge handleSaveImage:false];
    }
}

//从相册或者相机获取图片,dict:{handler=xxx,type=xxx,filePath=xxx,size=xxx}
- (void)getImage:(NSDictionary *)dict
{
    if (dict == nil) {
        [LuaObjectCBridge handleGetImage:false];
        return;
    }
    NSInteger type = [[dict objectForKey:@"type"] integerValue];
    UIImagePickerControllerSourceType sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    if (type == 2) {
        sourceType = UIImagePickerControllerSourceTypeCamera;
    }
    if ([UIImagePickerController isSourceTypeAvailable:sourceType]) {
        self.getImageDict = dict;
        UIImagePickerController *vc = [[UIImagePickerController alloc] init];
        vc.allowsEditing = YES;
        vc.sourceType = sourceType;
        vc.delegate = self;
        [viewController presentViewController:vc animated:YES completion:nil];
    }
    else{
        [LuaObjectCBridge handleGetImage:false];
    }
}

// 操作完成
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info
{
    [picker dismissViewControllerAnimated:NO completion:nil];
    if (self.getImageDict == nil) {
        return;
    }
    UIImage *image = [info valueForKey:UIImagePickerControllerEditedImage];
    // 以下为调整图片角度的部分
    if(image.imageOrientation!=UIImageOrientationUp) {
        UIGraphicsBeginImageContext(image.size);
        [image drawInRect:CGRectMake(0, 0, image.size.width, image.size.height)];
        image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
    }
    NSString *filePath = [self.getImageDict objectForKey:@"filePath"];
    NSInteger size = [[self.getImageDict objectForKey:@"size"] integerValue];
    if (filePath == nil) {
        return;
    }
    if (size == 0) {
        size = 300;
    }
    UIImage *tempImage = [self scaleImage:image toSize:CGSizeMake(size, size)];
    bool result = [UIImagePNGRepresentation(tempImage) writeToFile:filePath atomically:YES];
    [LuaObjectCBridge handleGetImage:result];
    self.getImageDict = nil;
}

- (UIImage *)scaleImage:(UIImage *)image toSize:(CGSize)size
{
    CGSize imgSize = image.size;
    CGFloat wScale = size.width / imgSize.width;
    CGFloat hScale = size.height / imgSize.height;
    CGFloat scale = wScale > hScale ? wScale : hScale;
    UIGraphicsBeginImageContext(CGSizeMake(image.size.width * scale, image.size.height * scale));
    [image drawInRect:CGRectMake(0, 0, image.size.width * scale, image.size.height * scale)];
    UIImage *scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return scaledImage;
}

// 操作取消
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    // 回收图像选取控制器
    [picker dismissViewControllerAnimated:YES completion:nil];
}

//处理openurl
- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url {
    return [self handleOpenUrl:url];
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(nullable NSString *)sourceApplication annotation:(id)annotation
{
    return [self handleOpenUrl:url];
}

- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<UIApplicationOpenURLOptionsKey,id> *)options
{
    return [self handleOpenUrl:url];
}

- (BOOL)handleOpenUrl:(NSURL *)url
{
    BOOL wx = [WXApi handleOpenURL:url delegate:self];
    BOOL jh = NO;
    if(wx==NO){
        if ([UIApplication sharedApplication].applicationState == UIApplicationStateActive) {
            jh = [LuaObjectCBridge handleOpenUrl:url];
        }
        else{
            jh = [LuaObjectCBridge canHandleOpenUrl:url];
            if (jh) {
                self.openUrl = url;
            }
        }
    }
    return wx||jh;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
    cocos2d::Director::getInstance()->pause();
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
    cocos2d::Director::getInstance()->resume();
    //处理openurl
    if (self.openUrl) {
        [LuaObjectCBridge handleOpenUrl:self.openUrl];
        self.openUrl = nil;
    }
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
     If your application supports background execution, called instead of applicationWillTerminate: when the user quits.
     */
    cocos2d::Application::getInstance()->applicationDidEnterBackground();
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    /*
     Called as part of  transition from the background to the inactive state: here you can undo many of the changes made on entering the background.
     */
    cocos2d::Application::getInstance()->applicationWillEnterForeground();
}

- (void)applicationWillTerminate:(UIApplication *)application {
    /*
     Called when the application is about to terminate.
     See also applicationDidEnterBackground:.
     */
}


#pragma mark -
#pragma mark Memory management

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application {
    /*
     Free up as much memory as possible by purging cached data objects that can be recreated (or reloaded from disk) later.
     */
     cocos2d::Director::getInstance()->purgeCachedData();
}


- (void)dealloc {
    [super dealloc];
}


@end

