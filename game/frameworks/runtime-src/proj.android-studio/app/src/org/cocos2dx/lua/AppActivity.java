/****************************************************************************
Copyright (c) 2008-2010 Ricardo Quesada
Copyright (c) 2010-2016 cocos2d-x.org
Copyright (c) 2013-2017 Chukong Technologies Inc.
 
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
package org.cocos2dx.lua;

import android.annotation.SuppressLint;
import android.app.DownloadManager;
import android.content.BroadcastReceiver;
import android.content.ClipData;
import android.content.ClipboardManager;
import android.content.ComponentName;
import android.content.ContentValues;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.content.ServiceConnection;
import android.content.pm.PackageInfo;
import android.content.pm.PackageManager;
import android.database.ContentObserver;
import android.database.Cursor;
import android.location.LocationProvider;
import android.net.Uri;
import android.os.BatteryManager;
import android.os.Build;
import android.os.Bundle;
import org.cocos2dx.lib.Cocos2dxActivity;
import android.app.Service;
import android.os.Environment;
import android.os.Handler;
import android.os.IBinder;
import android.os.Message;
import android.os.RemoteException;
import android.provider.MediaStore;
import android.provider.Settings;
import android.support.v4.content.FileProvider;
import android.telephony.TelephonyManager;
import android.text.TextUtils;
import android.util.Log;
import android.widget.Toast;

import java.util.List;
import com.amap.api.location.AMapLocation;
import com.amap.api.location.AMapLocationClient;
import com.amap.api.location.AMapLocationClientOption;
import com.amap.api.location.AMapLocationListener;
import com.hjq.permissions.*;
import org.cocos2dx.lua.WalleChannelReader;
//生成二维码
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import com.google.zxing.BarcodeFormat;
import com.google.zxing.EncodeHintType;
import com.google.zxing.MultiFormatWriter;
import com.google.zxing.WriterException;
import com.google.zxing.common.BitMatrix;
import java.io.File;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.IOException;
import java.util.Hashtable;
import java.util.concurrent.Executors;
import java.util.concurrent.Future;
import java.util.concurrent.ScheduledExecutorService;
import java.util.concurrent.TimeUnit;
//微信登录/分享
import com.happy.winner.wxapi.WXEntryActivity;

import com.jph.takephoto.compress.CompressConfig;
import com.jph.takephoto.model.CropOptions;
import com.jph.takephoto.model.TResult;
import com.jph.takephoto.model.TakePhotoOptions;
import com.liulishuo.filedownloader.BaseDownloadTask;
import com.liulishuo.filedownloader.FileDownloadListener;
import com.liulishuo.filedownloader.FileDownloadSampleListener;
import com.liulishuo.filedownloader.FileDownloader;
import com.liulishuo.filedownloader.util.FileDownloadUtils;
import com.tencent.mm.opensdk.openapi.IWXAPI;
import com.tencent.mm.opensdk.openapi.WXAPIFactory;
import com.tencent.mm.opensdk.modelmsg.SendAuth;
import com.tencent.mm.opensdk.modelmsg.SendMessageToWX;
import com.tencent.mm.opensdk.modelmsg.WXMiniProgramObject;
import com.tencent.mm.opensdk.modelmsg.WXImageObject;
import com.tencent.mm.opensdk.modelmsg.WXMediaMessage;
import com.tencent.mm.opensdk.modelmsg.WXMusicObject;
import com.tencent.mm.opensdk.modelmsg.WXTextObject;
import com.tencent.mm.opensdk.modelmsg.WXVideoObject;
import com.tencent.mm.opensdk.modelmsg.WXWebpageObject;

import org.cocos2dx.lib.Cocos2dxLuaJavaBridge;
import org.json.JSONObject;

public class AppActivity extends Cocos2dxActivity implements AMapLocationListener {
    static boolean n_bIsVm = false;
    private static AppActivity instance;
    private static ClipboardManager cm;

    private IntentFilter batteryfilter;
    //是否退入后台
    private boolean isPasue = false;
    //微信登录lua回调
    private int wechatLoginHandler = 0;
    private boolean needHandleWechatLogin = false;
    private String wechatLoginCode = "";
    //openUrl处理lua回调
    private int openUrlHandler = 0;
    //微信key
    private static String wechatAppId;
    private IWXAPI wxapi;
    private static final int THUMB_SIZE = 150;
    //定位
    //声明mlocationClient对象
    public AMapLocationClient mlocationClient;
    //声明mLocationOption对象
    public AMapLocationClientOption mLocationOption = null;
    private int locationHandler = 0;
    private boolean locationSuccess = false;
    private double locationLatitude = 0;
    private double locationLongitude = 0;
    private boolean neededHandleLocation = false;

    //保存图片/获取图片

    private int saveImageHandler = 0;
    private int getImageHandler = 0;
    private int tempImageSize = 300;
    private String tempImagePath;
    private boolean saveImageSuccess = false;
    private boolean neededHandleSaveImage = false;
    private boolean getImageSuccess = false;
    private boolean neededHandleGetImage = false;

    //更新apk
    private int updateHandler = 0;
    private String appUrl;
    private int appVer = 0;
    private int UPDATE_STATUS_UPDATING = 1;
    private int UPDATE_STATUS_ERROR = 2;
    private int UPDATE_STATUS_FINISHED = 3;
    private DownloadManager downloadManager;
    private long downloadId = -1;
    private final int DOWNLOAD_QUERY = 1000;
    private BroadcastReceiver mDownloaderReceiver = new BroadcastReceiver() {
        @Override
        public void onReceive(Context context, Intent intent) {
            //下载完成
            long completeDownloadId = intent.getLongExtra(DownloadManager.EXTRA_DOWNLOAD_ID, -1);
            if (completeDownloadId == downloadId) {
                stopDownloadTimer();
                DownloadManager.Query query = new DownloadManager.Query().setFilterById(downloadId);
                Cursor cursor = downloadManager.query(query);
                if (cursor != null && cursor.moveToFirst()) {
                    // 获取文件下载路径
                    String fileName = cursor.getString(cursor.getColumnIndex(DownloadManager.COLUMN_LOCAL_URI));
                    if (fileName != null){
                        installApk(context, fileName);
                    }else {
                        downloadByWeb(context,appUrl);
                    }
                }else {
                    downloadByWeb(context,appUrl);
                }
                if (cursor != null){
                    cursor.close();
                }
                AppActivity.this.unregisterReceiver(mDownloaderReceiver);
            }
        }
    };
    private Handler mHandler  = new Handler(new Handler.Callback() {
        @Override
        public boolean handleMessage(Message msg) {
            switch (msg.what) {
                case DOWNLOAD_QUERY:
                    DownloadManager.Query query = new DownloadManager.Query().setFilterById(downloadId);
                    Cursor cursor = downloadManager.query(query);
                    if (cursor != null && cursor.moveToFirst()) {
                        long downSize = cursor.getLong(cursor.getColumnIndexOrThrow(DownloadManager.COLUMN_BYTES_DOWNLOADED_SO_FAR));
                        //获取文件下载总大小
                        long totalSize = cursor.getLong(cursor.getColumnIndex(DownloadManager.COLUMN_TOTAL_SIZE_BYTES));
                        cursor.close();
                        if (totalSize > 0 ) {
                            int percentage = (int) (downSize * 100 / totalSize);
                            handleUpdate(UPDATE_STATUS_UPDATING,"updating",percentage);
                        }
                    }
            }
            return true;
        }
    });

    private ScheduledExecutorService scheduledExecutorService;
    private Future<?> future;

    @Override
    protected void onCreate(Bundle savedInstanceState)
    {
        super.setEnableVirtualButton(false);
        super.onCreate(savedInstanceState);
        // Workaround in https://stackoverflow.com/questions/16283079/re-launch-of-activity-on-home-button-but-only-the-first-time/16447508
        if (!isTaskRoot()) {
            // Android launched another instance of the root activity into an existing task
            //  so just quietly finish and go away, dropping the user back into the activity
            //  at the top of the stack (ie: the last state of this task)
            // Don't need to finish it again since it's finished in super.onCreate .
            finish();
            return;
        }

        // DO OTHER INITIALIZATION BELOW
        instance = this;
        Intent intent = new Intent(AppActivity.this, EmulatorCheckService.class);
        bindService(intent, serviceConnection, Service.BIND_AUTO_CREATE);

        cm = (ClipboardManager) this.getSystemService(Context.CLIPBOARD_SERVICE);

        CheckConnect.Init(this);

        batteryfilter = new IntentFilter(Intent.ACTION_BATTERY_CHANGED);

        //定位
        mlocationClient = new AMapLocationClient(this);
        //初始化定位参数
        mLocationOption = new AMapLocationClientOption();
        //设置定位监听
        mlocationClient.setLocationListener(this);
        //设置定位模式为高精度模式，Battery_Saving为低功耗模式，Device_Sensors是仅设备模式
        mLocationOption.setLocationMode(AMapLocationClientOption.AMapLocationMode.Battery_Saving);
        //设置定位间隔,单位毫秒,默认为2000ms
        mLocationOption.setInterval(2000);
        //设置定位参数
        mlocationClient.setLocationOption(mLocationOption);
    }

    public void updateApp(int appVer,final String appUrl,int handler){
        if (updateHandler != 0){
            Cocos2dxLuaJavaBridge.releaseLuaFunction(updateHandler);
        }
        updateHandler = handler;
        this.appUrl = appUrl;
        this.appVer = appVer;
        Cocos2dxLuaJavaBridge.retainLuaFunction(updateHandler);

        this.runOnUiThread(new Runnable() {
            @Override
            public void run() {
                downloadApkWithFileDownloader(appUrl);
            }
        });
    }

    //使用第三方框架FileDownloader下载
    private void downloadApkWithFileDownloader(final String apkUrl){
        FileDownloader.setup(this);
        String fileName = "v"+appVer+"_" + System.currentTimeMillis() + ".apk";
        String path = FileDownloadUtils.getDefaultSaveRootPath()+ File.separator+"jianghu"+File.separator+fileName;
        String downloadUrl = appUrl+"?t="+System.currentTimeMillis();
        FileDownloader.getImpl().create(downloadUrl)
                .setPath(path)
                .setMinIntervalUpdateSpeed(100)
                .setListener(new FileDownloadListener() {
                    @Override
                    protected void pending(BaseDownloadTask task, int soFarBytes, int totalBytes) {
                    }

                    @Override
                    protected void progress(BaseDownloadTask task, int soFarBytes, int totalBytes) {
                        if (totalBytes > 0) {
                            int percentage = soFarBytes * 100 / totalBytes;
                            handleUpdate(UPDATE_STATUS_UPDATING, "updating", percentage);
                        }
                    }

                    @Override
                    protected void completed(BaseDownloadTask task) {
                        System.out.println(task.getPath());
                        installApk(AppActivity.this,task.getPath());
                    }

                    @Override
                    protected void paused(BaseDownloadTask task, int soFarBytes, int totalBytes) {
                    }

                    @Override
                    protected void error(BaseDownloadTask task, Throwable e) {
                        downloadByWeb(AppActivity.this,apkUrl);
                        System.out.println(e.getMessage());
                    }

                    @Override
                    protected void warn(BaseDownloadTask task) {
                    }
                }).start();
    }

    //使用系统自动下载工具
    private void downloadApk(final String apkUrl){
        if (TextUtils.isEmpty(apkUrl)) {
            return;
        }
        try {
            String url = apkUrl+"?t="+System.currentTimeMillis();
            Uri uri = Uri.parse(url);
            if (downloadManager == null) {
                downloadManager = (DownloadManager) this.getSystemService(Context.DOWNLOAD_SERVICE);
            }
            DownloadManager.Request request = new DownloadManager.Request(uri);
            //在通知栏中显示
            request.setVisibleInDownloadsUi(true);
            request.setTitle("应用更新");
            request.setDescription("新版本更流畅");
            //MIME_MapTable是所有文件的后缀名所对应的MIME类型的一个String数组  {".apk",    "application/vnd.android.package-archive"},
            request.setMimeType("application/vnd.android.package-archive");
            // 在通知栏通知下载中和下载完成
            // 下载完成后该Notification才会被显示
            if (Build.VERSION.SDK_INT > Build.VERSION_CODES.HONEYCOMB) {
                // Android 3.0版本 以后才有该方法
                //在下载过程中通知栏会一直显示该下载的Notification，在下载完成后该Notification会继续显示，直到用户点击该Notification或者消除该Notification
                request.setNotificationVisibility(DownloadManager.Request.VISIBILITY_VISIBLE_NOTIFY_COMPLETED);
            }
            String fileName = "v"+appVer+"_" + System.currentTimeMillis() + ".apk";
            request.setDestinationInExternalFilesDir(this, Environment.DIRECTORY_DOWNLOADS,fileName);
            //下载管理Id
            downloadId = downloadManager.enqueue(request);
            //注册下载完成广播
            this.registerReceiver(mDownloaderReceiver, new IntentFilter(DownloadManager.ACTION_DOWNLOAD_COMPLETE));
            startDownloadTimer();
        } catch (Exception e) {
            e.printStackTrace();
            //注意:如果文件下载失败则 使用浏览器下载
             downloadByWeb(this, apkUrl);
        }
    }

    private void startDownloadTimer(){
        stopDownloadTimer();
        if (scheduledExecutorService == null){
            scheduledExecutorService = Executors.newScheduledThreadPool(1);
        }
        future = scheduledExecutorService.scheduleAtFixedRate(new Runnable() {
            @Override
            public void run() {
                Message msg = mHandler.obtainMessage();
                msg.what = DOWNLOAD_QUERY;
                mHandler.sendMessage(msg);
            }
        },0,50, TimeUnit.MILLISECONDS);
    }

    private void stopDownloadTimer(){
        if (future != null && !future.isCancelled()) {
            future.cancel(true);
        }
        if (scheduledExecutorService != null && !scheduledExecutorService.isShutdown()) {
            scheduledExecutorService.shutdown();
        }
    }

    //通过浏览器方式下载并安装
    private void downloadByWeb(Context context, String apkPath) {
        Uri uri = Uri.parse(apkPath);
        //String android.intent.action.VIEW 比较通用，会根据用户的数据类型打开相应的Activity。如:浏览器,电话,播放器,地图
        Intent intent = new Intent(Intent.ACTION_VIEW, uri);
        intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
        context.startActivity(intent);
    }

    private void installApk(Context context,String apkPath){
        File file=new File(Uri.parse(apkPath).getPath());
        String filePath = file.getAbsolutePath();
        //会根据用户的数据类型打开android系统相应的Activity。
        Intent intent = new Intent(Intent.ACTION_VIEW);
        //为这个新apk开启一个新的activity栈
        intent.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
        if(Build.VERSION.SDK_INT>=24) { //Android 7.0及以上
            // 参数2 清单文件中provider节点里面的authorities ; 参数3  共享的文件,即apk包的file类
            Uri apkUri = FileProvider.getUriForFile(this, "com.happy.winner.fileprovider", new File(filePath));
            //对目标应用临时授权该Uri所代表的文件
            intent.addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION);
            intent.setDataAndType(apkUri, "application/vnd.android.package-archive");
        }else {
            intent.setDataAndType(Uri.fromFile(file), "application/vnd.android.package-archive");
        }
        //开始安装
        handleUpdate(UPDATE_STATUS_FINISHED,"install",100);
        context.startActivity(intent);
    }

    private void handleUpdate(final int status, final String msg,final int percent){
        if (updateHandler == 0){
            return;
        }
        this.runOnGLThread(new Runnable() {
            @Override
            public void run() {
                String resultString = status+","+msg+","+percent;
                Cocos2dxLuaJavaBridge.callLuaFunctionWithString(updateHandler,resultString);
                if (status==UPDATE_STATUS_ERROR|| status == UPDATE_STATUS_FINISHED) {
                    Cocos2dxLuaJavaBridge.releaseLuaFunction(updateHandler);
                    updateHandler = 0;
                }
            }
        });
    }

    @Override
    public void onLocationChanged(AMapLocation amapLocation) {
        if (amapLocation != null) {
            if (amapLocation.getErrorCode() == 0) {
                handleLocation(true,amapLocation.getLatitude(),amapLocation.getLongitude());
            } else {
                handleLocation(false,0,0);
            }
        }
    }

    @Override
    protected void onNewIntent(Intent intent) {
        super.onNewIntent(intent);
    }

    @Override
    protected void onStart() {
        super.onStart();
    }

    @Override
    protected void onPause() {
        super.onPause();
        isPasue = true;
//        unregisterReceiver(mDownloaderReceiver);
    }

    @Override
    protected void onResume() {
        super.onResume();
        isPasue = false;
        /** 注册下载完成接收广播 **/
//        registerReceiver(mDownloaderReceiver,new IntentFilter(DownloadManager.ACTION_DOWNLOAD_COMPLETE));
        //延迟1秒执行
        new Thread(){
            public void run(){
                try {
                    Thread.sleep(1000);
                    if (needHandleWechatLogin){
                        HandleWechatLoginResp(wechatLoginCode);
                        needHandleWechatLogin = false;
                    }
                    if (neededHandleLocation){
                        handleLocation(locationSuccess,locationLatitude,locationLongitude);
                        neededHandleLocation = false;
                    }
                    if (neededHandleSaveImage){
                        handleSaveImage(saveImageSuccess);
                        neededHandleSaveImage = false;
                    }
                    if (neededHandleGetImage){
                        handleGetImage(getImageSuccess);
                        neededHandleGetImage = false;
                    }
                } catch (InterruptedException e) { }
            }
        }.start();
    }

    @Override
    protected void onDestroy() {
        super.onDestroy();
        stopDownloadTimer();
    }

    @Override
    protected void onSaveInstanceState(Bundle outState) {
        super.onSaveInstanceState(outState);
    }

    @Override
    protected void onActivityResult(int requestCode, int resultCode, Intent data) {
        super.onActivityResult(requestCode, resultCode, data);
    }

    @Override
    public void takeSuccess(TResult result) {
        super.takeSuccess(result);
        if (result.getImages().size() <= 0 ){
            handleGetImage(false);
            return;
        }
        try {
            String path = result.getImages().get(0).getCompressPath();
            if (path == null || path.equals("")){
                path = result.getImages().get(0).getOriginalPath();
            }
            File file = new File(path);
            Uri uri = Uri.fromFile(file);
            Bitmap bitmap = BitmapFactory.decodeStream(getContentResolver().openInputStream(uri));
            SaveBitmap(bitmap,tempImagePath);
            handleGetImage(true);
        } catch (Exception e) {
            handleGetImage(false);
            e.printStackTrace();
        }
    }
    @Override
    public void takeFail(TResult result,String msg) {
        super.takeFail(result,msg);
        handleGetImage(false);
    }
    @Override
    public void takeCancel() {
        super.takeCancel();
        handleGetImage(false);
    }

    public static AppActivity getInstance()
    {
        return instance;
    }

    final ServiceConnection serviceConnection = new ServiceConnection()
    {
        @Override
        public void onServiceConnected(ComponentName name, IBinder service) {
            IEmulatorCheck IEmulatorCheck = org.cocos2dx.lua.IEmulatorCheck.Stub.asInterface(service);
            if (IEmulatorCheck != null) {
                try {

                    boolean b= IEmulatorCheck.isEmulator();

                    AppActivity.n_bIsVm = b;
                    //TextView textView = (TextView) findViewById(R.id.btn_moni);
                    //textView.setText(" 是否模拟器 " + );
                    unbindService(this);
                } catch (RemoteException e) {
                    //Toast.makeText(MainActivity.this,"获取进程崩溃",Toast.LENGTH_SHORT).show();
                    AppActivity.n_bIsVm = false;
                }
            }
        }

        @Override
        public void onServiceDisconnected(ComponentName name) {
        }
    };

    public static boolean isEmulator()
    {
        return n_bIsVm;
    }

    public void OpenUrl(String url)
    {
        Intent intent = new Intent(Intent.ACTION_VIEW, Uri.parse(url));
        //intent.setClassName("com.android.browser", "com.android.browser.BrowserActivity");
        this.startActivity(intent);
    }

    public void SetCopy(String str)
    {
        try
        {
            // 创建普通字符型ClipData
            ClipData mClipData = ClipData.newPlainText("text", str);
            // 将ClipData内容放到系统剪贴板里。
            if (cm != null)
                cm.setPrimaryClip(mClipData);
        }
        catch (Exception e)
        {
            Log.e("cocos",e.getMessage());
        }
    }

    public String GetCopy()
    {
        if(cm != null && cm.getPrimaryClip() != null && cm.getPrimaryClip().getItemAt(0) != null && cm.getPrimaryClip().getItemAt(0).getText() !=null){
            return cm.getPrimaryClip().getItemAt(0).getText().toString();
        }else {
            return "";
        }
    }

    public boolean isTabletDevice()
    {
        // 判断android设备是手机还是平板
        TelephonyManager telManager = (TelephonyManager) getSystemService(Context.TELEPHONY_SERVICE);
        if(telManager == null) return false;
        int type = telManager.getPhoneType();
        if (type == TelephonyManager.PHONE_TYPE_NONE)
        {// 平板
            Log.d("cocos", "is Tablet!");
            return true;
        }
        else
        {// 手机
            Log.d("cocos", "is phone!");
            return false;
        }
    }

    @SuppressLint("HardwareIds")
    public String GetUuid()
    {
        String IMSINumber = "0";
        if (isTabletDevice()) {
            IMSINumber = Settings.Secure.getString(getContentResolver(),
                    Settings.Secure.ANDROID_ID);
            Log.e("cocos", "返回用户识别码（Pad）的设备"+IMSINumber);
        }
        else {
            int absent = TelephonyManager.SIM_STATE_ABSENT;
            if (1 == absent) {
                Log.e("cocos", "请确认sim卡是否插入或者sim卡暂时不可用！");
                IMSINumber = Settings.Secure.getString(getContentResolver(),
                        Settings.Secure.ANDROID_ID);
                Log.e("cocos", "未找到sim卡,返回用户识别码（Pad）的设备" + IMSINumber);

            }
            else {
                TelephonyManager telManager = (TelephonyManager) getSystemService(Context.TELEPHONY_SERVICE);
                try {
                    IMSINumber = telManager.getSubscriberId();
                }catch (SecurityException e){
                    e.printStackTrace();
                }

                Log.e("cocos", "返回用户识别码（IMSI）的设备" + IMSINumber);
            }
        }
        return IMSINumber;
    }

    public boolean isInstallWechat()
    {
        final PackageManager packageManager = instance.getPackageManager();// 获取packagemanager
        List<PackageInfo> pinfo = packageManager.getInstalledPackages(0);// 获取所有已安装程序的包信息
        if (pinfo != null) {
            for (int i = 0; i < pinfo.size(); i++) {
                String pn = pinfo.get(i).packageName;
                if (pn.equalsIgnoreCase("com.tencent.mm"))
                {
                    return true;
                }
            }
        }
        return false;
    }

    public String GetAndroidDeviceType()
    {
        String deviceType = "phone";
        if (isTabletDevice()) {
            deviceType = "pad";
        }
        return deviceType;
    }

    public int GetCurrentConnectType()
    {
        int currconnect= 0;
        if(CheckConnect.isWifi(this))
        {
            currconnect = 1;
        };
        if(CheckConnect.is3G(this))
        {
            currconnect = 2;
        };
        return currconnect;
    }

    public boolean IsNetworkAvailable()
    {
        if(CheckConnect.isNetworkAvailable(this))
        {
            return true;
        }
        return false;
    }

    public void OpenApp(String packname,String classname)
    {
        Log.e(packname, classname);
        try{
            Intent intent = new Intent();
            ComponentName cmp = new ComponentName(packname,classname);
            //ComponentName cmp = new ComponentName("com.tencent.mobileqq","com.tencent.mobileqq.activity.HomeActivity");
            intent.setAction(Intent.ACTION_MAIN);
            intent.addCategory(Intent.CATEGORY_LAUNCHER);
            intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
            intent.setComponent(cmp);
            startActivityForResult(intent, 0);
            //startActivity(new Intent(Intent.ACTION_VIEW, Uri.parse("alipays:")));
        }catch (Exception e)
        {
            e.printStackTrace();
            Toast.makeText(this, "请安装此应用后再使用该功能", Toast.LENGTH_LONG).show();
            Log.e("请安装此应用后再使用该功能","Open APP");
        }

        Log.e("Open APP End","Open APP");
    }

    protected Intent GetBatteryReceiver()
    {
        return getContext().registerReceiver(null, batteryfilter);
    }

    public int GetBatteryStatus()
    {
        int status = GetBatteryReceiver().getIntExtra(BatteryManager.EXTRA_STATUS, 0);
        return status;
    }

    public int GetBatteryLevel()
    {
        int level = GetBatteryReceiver().getIntExtra(BatteryManager.EXTRA_LEVEL, 0);
        return level;
    }

    public String GetPromotionId()
    {
        return WalleChannelReader.getChannel(this.getApplicationContext());
    }
	
	//生成二维码
	private static final int BLACK = 0xff000000;
	private static final int WHITE = 0xffffffff;
	public boolean CreateQRCode(String str, int widthAndHeight, String filePath) throws WriterException {//Bitmap String str,int widthAndHeight
		Hashtable<EncodeHintType, String> hints = new Hashtable<EncodeHintType, String>();
		hints.put(EncodeHintType.CHARACTER_SET, "utf-8");
		BitMatrix matrix = new MultiFormatWriter().encode(str, BarcodeFormat.QR_CODE, widthAndHeight, widthAndHeight);
		matrix = DeleteWhite(matrix);//删除白边
		int width = matrix.getWidth();
		int height = matrix.getHeight();
		int[] pixels = new int[width * height];

		for (int y = 0; y < height; y++) {
			for (int x = 0; x < width; x++) {
				if (matrix.get(x, y)) {
					pixels[y * width + x] = BLACK;
				}else{
					pixels[y * width + x] = WHITE;
				}
			}
		}
		Bitmap bitmap = Bitmap.createBitmap(width, height,
				Bitmap.Config.ARGB_8888);
		bitmap.setPixels(pixels, 0, width, 0, 0, width, height);
		SaveBitmap(bitmap, filePath);
		return true;
	}
	//保存图片
	private void SaveBitmap(Bitmap bitmap, String filePath){
		File file = new File(filePath);
		if (file.exists()) {
			file.delete();
		}
		try {
			FileOutputStream out = new FileOutputStream(file);
			bitmap.compress(Bitmap.CompressFormat.PNG, 100, out);
			out.flush();
			out.close();
		} catch (FileNotFoundException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		} catch (IOException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
	}
	private BitMatrix DeleteWhite(BitMatrix matrix) {
		int[] rec = matrix.getEnclosingRectangle();
		int resWidth = rec[2] + 1;
		int resHeight = rec[3] + 1;

		BitMatrix resMatrix = new BitMatrix(resWidth, resHeight);
		resMatrix.clear();
		for (int i = 0; i < resWidth; i++) {
			for (int j = 0; j < resHeight; j++) {
				if (matrix.get(i + rec[0], j + rec[1]))
					resMatrix.set(i, j);
			}
		}
		return resMatrix;
	}
	//生成二维码

    //注册OpenUrl handler
    public void RegisterOpenUrlHandler(int handler){
        if (openUrlHandler != 0){
            Cocos2dxLuaJavaBridge.releaseLuaFunction(openUrlHandler);
        }
        openUrlHandler = handler;
        Cocos2dxLuaJavaBridge.retainLuaFunction(openUrlHandler);
    }

    //处理openUrl
    public void HandleOpenUrl(Intent intent){
	    System.out.println("----------------------------------------------");
	    System.out.println("---------------------f;alksjf;laskdjfl;a");
        System.out.println("----------------------------------------------");
        if (openUrlHandler == 0){
            return;
        }
        if (intent == null){
            return;
        }
        Uri uri = intent.getData();
        if (uri == null){
            return;
        }
        if (uri.getScheme().equals("jyjh") == false){
            return;
        }
        String uriString = uri.toString();
        System.out.println("======================uriString:"+uriString);
        Cocos2dxLuaJavaBridge.callLuaFunctionWithString(openUrlHandler,uriString);
    }

    //注册微信APPID
    public void RegisterWechatAppId(String appId){
        if (appId == null || appId.equals("")){
            return;
        }
	    wechatAppId = appId;
        // 通过WXAPIFactory工厂，获取IWXAPI的实例
        wxapi = WXAPIFactory.createWXAPI(this, wechatAppId, false);
        // 将应用的appId注册到微信
        wxapi.registerApp(wechatAppId);
        //微信登录
        WXEntryActivity.registerWXAPI(wxapi);
    }

    //发送微信登录请求
    public void SendWechatLoginReq(int handler){
        if (wxapi == null){
            return;
        }
        if (wechatLoginHandler != 0){
            Cocos2dxLuaJavaBridge.releaseLuaFunction(wechatLoginHandler);
        }
        wechatLoginHandler = handler;
        Cocos2dxLuaJavaBridge.retainLuaFunction(wechatLoginHandler);
	    this.runOnUiThread(new Runnable() {
            @Override
            public void run() {
                final SendAuth.Req req = new SendAuth.Req();
                req.scope = "snsapi_userinfo";
                req.state = "wechat_login";
                wxapi.sendReq(req);
            }
        });

    }

    //微信登录返回
    public void HandleWechatLoginResp(final String code){
	    if (isPasue){
	        needHandleWechatLogin = true;
	        wechatLoginCode = code;
	        return;
        }
	    if (wechatLoginHandler == 0){
	        return;
        }
        this.runOnGLThread(new Runnable() {
            @Override
            public void run() {
                Cocos2dxLuaJavaBridge.callLuaFunctionWithString(wechatLoginHandler,code);
                Cocos2dxLuaJavaBridge.releaseLuaFunction(wechatLoginHandler);
                wechatLoginHandler = 0;
            }
        });
    }

    //微信分享
    public void ShareToWechat(final String jsonString){
        if (wxapi == null){
            return;
        }
        this.runOnUiThread(new Runnable() {
            @Override
            public void run() {
                try {
                    JSONObject jsonObject = new JSONObject(jsonString);
                    System.out.println(jsonObject.toString());
                    int scene = jsonObject.getInt("scene");
                    if (scene < SendMessageToWX.Req.WXSceneSession || scene > SendMessageToWX.Req.WXSceneSpecifiedContact){
                        return;
                    }
                    int type = jsonObject.getInt("type");
                    if (type==1){
                        ShareTextToWechat(jsonObject,scene);
                    }else if(type==2){
                        ShareImageToWechat(jsonObject,scene);
                    }else if(type==3){
                        ShareMusicToWechat(jsonObject,scene);
                    }else if(type==4){
                        ShareVideoToWechat(jsonObject,scene);
                    }else if(type==5){
                        ShareWebpageToWechat(jsonObject,scene);
                    }else if(type==6){
                        ShareMiniProgramToWechat(jsonObject,scene);
                    }
                }catch (Exception e){
                    e.printStackTrace();
                }
            }
        });
    }

    //微信分享文字1
    private void ShareTextToWechat(JSONObject jsonObject, int scene){
	    try {
            //初始化一个 WXTextObject 对象，填写分享的文本内容
            WXTextObject textObj = new WXTextObject();
            textObj.text = jsonObject.getString("text");

            //用 WXTextObject 对象初始化一个 WXMediaMessage 对象
            WXMediaMessage msg = new WXMediaMessage(textObj);
            msg.description = jsonObject.getString("text");

            SendMessageToWX.Req req = new SendMessageToWX.Req();
            req.message = msg;
            req.scene = scene;
            //调用api接口，发送数据到微信
            wxapi.sendReq(req);
        }catch (Exception e) {
            e.printStackTrace();
        }
    }

    //微信分享图片2
    private void ShareImageToWechat(JSONObject jsonObject, int scene){
        try {
            String path = jsonObject.getString("imagePath");
            File file = new File(path);
            if (!file.exists()) {
                return;
            }
            Bitmap bmp = BitmapFactory.decodeFile(path);
            WXImageObject imgObj = new WXImageObject(bmp);
            bmp.recycle();
            WXMediaMessage msg = new WXMediaMessage();
            msg.mediaObject = imgObj;
            msg.title = jsonObject.getString("title");
            msg.description = jsonObject.getString("description");

            SendMessageToWX.Req req = new SendMessageToWX.Req();
            req.message = msg;
            req.scene = scene;
            wxapi.sendReq(req);

        }catch (Exception e) {
            e.printStackTrace();
        }
    }

    //微信分享音乐3
    private void ShareMusicToWechat(JSONObject jsonObject, int scene){
        try {
            WXMusicObject music = new WXMusicObject();
            music.musicUrl=jsonObject.getString("musicUrl");
            music.musicDataUrl=jsonObject.getString("musicDataUrl");

            WXMediaMessage msg = new WXMediaMessage();
            msg.mediaObject = music;
            msg.title = jsonObject.getString("title");
            msg.description = jsonObject.getString("description");

            String path = jsonObject.getString("imagePath");
            File file = new File(path);
            if (file.exists()) {
                Bitmap bmp = BitmapFactory.decodeFile(path);
                Bitmap thumbBmp = Bitmap.createScaledBitmap(bmp, THUMB_SIZE, THUMB_SIZE, true);
                bmp.recycle();
                msg.thumbData = Util.bmpToByteArray(thumbBmp, true);
            }

            SendMessageToWX.Req req = new SendMessageToWX.Req();
            req.message = msg;
            req.scene = scene;
            wxapi.sendReq(req);

        }catch (Exception e) {
            e.printStackTrace();
        }
    }

    //微信分享视频4
    private void ShareVideoToWechat(JSONObject jsonObject, int scene){
        try {
            WXVideoObject video = new WXVideoObject();
            video.videoUrl = jsonObject.getString("videoUrl");

            WXMediaMessage msg = new WXMediaMessage(video);
            msg.title = jsonObject.getString("title");
            msg.description = jsonObject.getString("description");

            String path = jsonObject.getString("imagePath");
            File file = new File(path);
            if (file.exists()) {
                Bitmap bmp = BitmapFactory.decodeFile(path);
                Bitmap thumbBmp = Bitmap.createScaledBitmap(bmp, THUMB_SIZE, THUMB_SIZE, true);
                bmp.recycle();
                msg.thumbData = Util.bmpToByteArray(thumbBmp, true);
            }

            SendMessageToWX.Req req = new SendMessageToWX.Req();
            req.message = msg;
            req.scene = scene;
            wxapi.sendReq(req);
        }catch (Exception e) {
            e.printStackTrace();
        }
    }

    //微信分享网页5
    private void ShareWebpageToWechat(JSONObject jsonObject, int scene){
        try {
            WXWebpageObject webpage = new WXWebpageObject();
            webpage.webpageUrl = jsonObject.getString("webpageUrl");

            WXMediaMessage msg = new WXMediaMessage(webpage);
            msg.title = jsonObject.getString("title");
            msg.description = jsonObject.getString("description");

            String path = jsonObject.getString("imagePath");
            File file = new File(path);
            if (file.exists()) {
                Bitmap bmp = BitmapFactory.decodeFile(path);
                Bitmap thumbBmp = Bitmap.createScaledBitmap(bmp, THUMB_SIZE, THUMB_SIZE, true);
                bmp.recycle();
                msg.thumbData = Util.bmpToByteArray(thumbBmp, true);
            }

            SendMessageToWX.Req req = new SendMessageToWX.Req();
            req.message = msg;
            req.scene = scene;
            wxapi.sendReq(req);
        }catch (Exception e) {
            e.printStackTrace();
        }
    }

    //微信分享小程序6
    private void ShareMiniProgramToWechat(JSONObject jsonObject, int scene){
        try {
            WXMiniProgramObject miniProgram = new WXMiniProgramObject();
            miniProgram.webpageUrl = jsonObject.getString("webpageUrl");
            miniProgram.userName = jsonObject.getString("userName");
            miniProgram.path = jsonObject.getString("path");
            miniProgram.withShareTicket = jsonObject.getBoolean("withShareTicket");
            miniProgram.miniprogramType = jsonObject.getInt("miniprogramType");

            WXMediaMessage msg = new WXMediaMessage(miniProgram);
            msg.title = jsonObject.getString("title");
            msg.description = jsonObject.getString("description");

            String path = jsonObject.getString("imagePath");
            File file = new File(path);
            if (file.exists()) {
                Bitmap bmp = BitmapFactory.decodeFile(path);
                Bitmap thumbBmp = Bitmap.createScaledBitmap(bmp, THUMB_SIZE, THUMB_SIZE, true);
                bmp.recycle();
                msg.thumbData = Util.bmpToByteArray(thumbBmp, true);
            }

            SendMessageToWX.Req req = new SendMessageToWX.Req();
            req.message = msg;
            req.scene = scene;
            wxapi.sendReq(req);
        }catch (Exception e) {
            e.printStackTrace();
        }
    }

    //定位
    public void StartLocation(int handler){
        if (locationHandler != 0){
            Cocos2dxLuaJavaBridge.releaseLuaFunction(locationHandler);
        }
        locationHandler = handler;
        Cocos2dxLuaJavaBridge.retainLuaFunction(locationHandler);
        this.runOnUiThread(new Runnable() {
            @Override
            public void run() {
                XXPermissions.with(AppActivity.this)
                        //.constantRequest() //可设置被拒绝后继续申请，直到用户授权或者永久拒绝
                        //.permission(Permission.SYSTEM_ALERT_WINDOW, Permission.REQUEST_INSTALL_PACKAGES) //支持请求6.0悬浮窗权限8.0请求安装权限
                        .permission(Permission.ACCESS_FINE_LOCATION, Permission.ACCESS_COARSE_LOCATION) //不指定权限则自动获取清单中的危险权限
                        .request(new OnPermission() {
                            @Override
                            public void hasPermission(List<String> granted, boolean isAll) {
                                mlocationClient.startLocation();
                            }

                            @Override
                            public void noPermission(List<String> denied, boolean quick) {
                                handleLocation(false, 0, 0);
                            }
                        });
            }
        });
    }

    private void handleLocation(final boolean success, final double latitude, final double longitude){
	    if (isPasue){
	        neededHandleLocation = true;
	        locationSuccess = success;
	        locationLatitude = latitude;
	        locationLongitude = longitude;
	        return;
        }
        if (locationHandler == 0){
            return;
        }
        this.runOnGLThread(new Runnable() {
            @Override
            public void run() {
                String resultString = "";
                if (success){
                    resultString = 1+","+latitude+","+longitude;
                }else {
                    resultString = 0+","+latitude+","+longitude;
                }
                Cocos2dxLuaJavaBridge.callLuaFunctionWithString(locationHandler,resultString);
                Cocos2dxLuaJavaBridge.releaseLuaFunction(locationHandler);
                locationHandler = 0;
            }
        });
    }

    //保存图片到相册
    public void SaveImage(int handler,final String filePath){
        if (saveImageHandler != 0){
            Cocos2dxLuaJavaBridge.releaseLuaFunction(saveImageHandler);
        }
        saveImageHandler = handler;
        Cocos2dxLuaJavaBridge.retainLuaFunction(saveImageHandler);
        this.runOnUiThread(new Runnable() {
            @Override
            public void run() {
                XXPermissions.with(AppActivity.this)
                        .permission(Permission.WRITE_EXTERNAL_STORAGE,Permission.READ_EXTERNAL_STORAGE)
                        .request(new OnPermission() {
                            @Override
                            public void hasPermission(List<String> granted, boolean isAll) {
                                doSaveImage(filePath);
                            }

                            @Override
                            public void noPermission(List<String> denied, boolean quick) {
                                handleSaveImage(false);
                            }
                        });
            }
        });
    }

    private void doSaveImage(String filePath){
        //获取图片
        File inFile = new File(filePath);
        if (inFile.exists()) {
            Bitmap bmp = BitmapFactory.decodeFile(filePath);
            // 首先保存图片
            File appDir = new File(Environment.getExternalStorageDirectory(), "QQ娱乐");
            if (!appDir.exists()) {
                appDir.mkdir();
            }
            String fileName = "jh_"+System.currentTimeMillis() + ".png";
            File file = new File(appDir, fileName);
            try {
                FileOutputStream fos = new FileOutputStream(file);
                bmp.compress(Bitmap.CompressFormat.PNG, 100, fos);
                fos.flush();
                fos.close();
            } catch (FileNotFoundException e) {
                handleSaveImage(false);
                e.printStackTrace();
            } catch (IOException e) {
                handleSaveImage(false);
                e.printStackTrace();
            }

            // 其次把文件插入到系统图库
            String path = file.getAbsolutePath();
            try {
                MediaStore.Images.Media.insertImage(AppActivity.this.getContentResolver(), path, fileName, null);
            } catch (FileNotFoundException e) {
                handleSaveImage(false);
                e.printStackTrace();
            }
            // 最后通知图库更新
            Intent intent = new Intent(Intent.ACTION_MEDIA_SCANNER_SCAN_FILE);
            Uri uri = Uri.fromFile(file);
            intent.setData(uri);
            AppActivity.this.sendBroadcast(intent);
            handleSaveImage(true);
            bmp.recycle();
        }else {
            handleSaveImage(false);
        }
    }

    private void handleSaveImage(final boolean success){
	    if (isPasue){
	        neededHandleSaveImage = true;
	        saveImageSuccess = success;
	        return;
        }
	    if (saveImageHandler == 0){
	        return;
        }
        this.runOnGLThread(new Runnable() {
            @Override
            public void run() {
                String ret = "0";
                if (success){
                    ret = "1";
                }
                Cocos2dxLuaJavaBridge.callLuaFunctionWithString(saveImageHandler,ret);
                Cocos2dxLuaJavaBridge.releaseLuaFunction(saveImageHandler);
                saveImageHandler = 0;
            }
        });
    }

    //从相册或者相机获取图片
    public void GetImage(int handler,int type,String filePath,int size){
        if (getImageHandler != 0){
            Cocos2dxLuaJavaBridge.releaseLuaFunction(getImageHandler);
        }
        getImageHandler = handler;
        tempImageSize = size;
        tempImagePath = filePath;
        Cocos2dxLuaJavaBridge.retainLuaFunction(getImageHandler);
        //设置样式
        TakePhotoOptions.Builder builder = new TakePhotoOptions.Builder();
        builder.setWithOwnGallery(true);
        builder.setCorrectImage(true);
        getTakePhoto().setTakePhotoOptions(builder.create());
        //压缩
        int maxSize = 1024*1024;
        int maxPixel = tempImageSize >= 1024 ? tempImageSize : 1024;
        CompressConfig config = new CompressConfig.Builder().setMaxSize(maxSize).setMaxPixel(maxPixel).create();
        getTakePhoto().onEnableCompress(config,true);
        //设置临时路径
        File file = new File(Environment.getExternalStorageDirectory(), "/temp/" + System.currentTimeMillis() + ".png");
        if (!file.getParentFile().exists()) {
            file.getParentFile().mkdirs();
        }
        Uri imageUri = Uri.fromFile(file);
        CropOptions op = new CropOptions.Builder().setAspectX(1).setAspectY(1).setOutputX(tempImageSize).setOutputY(tempImageSize).setWithOwnCrop(true).create();
        if (type == 2){
            getTakePhoto().onPickFromCaptureWithCrop(imageUri,op);
        }else {
            getTakePhoto().onPickFromGalleryWithCrop(imageUri,op);
        }
    }

    private void handleGetImage(final boolean success){
        if (isPasue){
            neededHandleGetImage = true;
            getImageSuccess = success;
            return;
        }
        if (getImageHandler == 0){
            return;
        }
        this.runOnGLThread(new Runnable() {
            @Override
            public void run() {
                String ret = "0";
                if (success){
                    ret = "1";
                }
                Cocos2dxLuaJavaBridge.callLuaFunctionWithString(getImageHandler,ret);
                Cocos2dxLuaJavaBridge.releaseLuaFunction(getImageHandler);
                getImageHandler = 0;
            }
        });
    }
}
