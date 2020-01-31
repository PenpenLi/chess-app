package org.cocos2dx.lua;

import com.google.zxing.WriterException;

import java.util.HashMap;

public class LuaJavaBridge
{
    //安装APK
    public static void UpdateApp(int appVer,String appUrl,int handler){
        AppActivity.getInstance().updateApp(appVer,appUrl,handler);
    }

    //是否模拟器
    public static boolean isVm()
    {
        return AppActivity.isEmulator();
    }

    //浏览器打开连接
    public static void OpenUrl(String url)
    {
        AppActivity.getInstance().OpenUrl(url);
    }

    //设置剪切板内容
    public static void SetCopy(String text)
    {
        AppActivity.getInstance().SetCopy(text);
    }

    //获取剪切板内容
    public static String GetCopy()
    {
        return AppActivity.getInstance().GetCopy();
    }

    //获取设备唯一码
    public static String GetUuid()
    {
        return AppActivity.getInstance().GetUuid();
    }

    //是否已安装微信
    public static boolean IsInstallWechat()
    {
        return AppActivity.getInstance().isInstallWechat();
    }

    ///获取设备类型
    public static String GetAndroidDeviceType()
    {
        return AppActivity.getInstance().GetAndroidDeviceType();
    }

    //获取当前网络连接类型
    public static int GetCurrentConnectType()
    {
        return AppActivity.getInstance().GetCurrentConnectType();
    }

    //当前网络是否可用
    public static boolean IsNetworkAvailable()
    {
        return AppActivity.getInstance().IsNetworkAvailable();
    }

    //打开应用
    public static void OpenApp(String packName,String className)
    {
        AppActivity.getInstance().OpenApp(packName,className);
    }

    public static int GetBatteryStatus()
    {
        return AppActivity.getInstance().GetBatteryStatus();
    }

    public static int GetBatteryPercent()
    {
        return AppActivity.getInstance().GetBatteryLevel();
    }

    public static String GetPromotionId()
    {
        return AppActivity.getInstance().GetPromotionId();
    }
	
	//生成二维码
	public static boolean CreateQRCode(String str, int widthAndHeight, String filePath) throws WriterException {//Bitmap String str,int widthAndHeight
		return AppActivity.getInstance().CreateQRCode(str,widthAndHeight,filePath);
	}
	//生成二维码

    //注册OpenUrlhandler
    public static void RegisterOpenUrlHandler(int handler){
        AppActivity.getInstance().RegisterOpenUrlHandler(handler);
    }

    //注册微信APPID
    public static void RegisterWechatAppId(String appId){
        AppActivity.getInstance().RegisterWechatAppId(appId);
    }

    //微信登录
    public static void SendWechatLoginReq(int handler)
    {
        AppActivity.getInstance().SendWechatLoginReq(handler);
    }

    //微信分享
    public static void ShareToWechat(String jsonString){
        AppActivity.getInstance().ShareToWechat(jsonString);
    }

    //发起定位
    public static void StartLocation(int handler){
        AppActivity.getInstance().StartLocation(handler);
    }

    //保存图片到相册
    public static void SaveImage(int handler,String filePath){
        AppActivity.getInstance().SaveImage(handler,filePath);
    }

    //从相册或者相机获取图片
    public static void GetImage(int handler,int type,String filePath,int size){
        AppActivity.getInstance().GetImage(handler,type,filePath,size);
    }
}
