package org.cocos2dx.lua;
  
import java.util.List;  
  
import android.content.Context;
import android.content.Intent;
import android.location.LocationManager;  
import android.net.ConnectivityManager;  
import android.net.NetworkInfo;  
import android.telephony.TelephonyManager;
import android.util.Log;
import android.os.BatteryManager;

import android.content.BroadcastReceiver;  
import android.os.Bundle;  
import android.widget.Toast;

import org.cocos2dx.lib.Cocos2dxLuaJavaBridge;

public class CheckConnect extends BroadcastReceiver
{
    private static boolean _isNetworkAvailable = false;
    private static int _networkType = 0;

    public CheckConnect()
    {
    }

    public static void Init(Context context)
    {
        _isNetworkAvailable = isNetworkAvailable(context);
        _networkType = getNetworkType(context);
    }

    public static boolean isNetworkAvailable(Context context)
    {
        ConnectivityManager connectivity = (ConnectivityManager) context  
                .getSystemService(Context.CONNECTIVITY_SERVICE);  
        if (connectivity == null) {  
        } else {  
            NetworkInfo[] info = connectivity.getAllNetworkInfo();  
            if (info != null) {  
                for (int i = 0; i < info.length; i++)
                {
                    if (info[i].getState() == NetworkInfo.State.CONNECTED)
                    {
                        return true;  
                    }  
                }  
            }  
        }
        return false;  
    }  

    public static boolean isGpsEnabled(Context context)
    {
        LocationManager locationManager = ((LocationManager) context  
                .getSystemService(Context.LOCATION_SERVICE));  
        List<String> accessibleProviders = locationManager.getProviders(true);  
        return accessibleProviders != null && accessibleProviders.size() > 0;  
    }  

    public static boolean isWifiEnabled(Context context)
    {
        ConnectivityManager mgrConn = (ConnectivityManager) context  
                .getSystemService(Context.CONNECTIVITY_SERVICE);  
        TelephonyManager mgrTel = (TelephonyManager) context  
                .getSystemService(Context.TELEPHONY_SERVICE);  
        return ((mgrConn.getActiveNetworkInfo() != null && mgrConn  
                .getActiveNetworkInfo().getState() == NetworkInfo.State.CONNECTED) || mgrTel  
                .getNetworkType() == TelephonyManager.NETWORK_TYPE_UMTS);  
    }  

    public static boolean isWifi(Context context)
    {
        ConnectivityManager connectivityManager = (ConnectivityManager) context  
                .getSystemService(Context.CONNECTIVITY_SERVICE);  
        NetworkInfo activeNetInfo = connectivityManager.getActiveNetworkInfo();  
        if (activeNetInfo != null  
                && activeNetInfo.getType() == ConnectivityManager.TYPE_WIFI) {  
            return true;  
        }  
        return false;  
    }  

    public static boolean is3G(Context context)
    {
        ConnectivityManager connectivityManager = (ConnectivityManager) context  
                .getSystemService(Context.CONNECTIVITY_SERVICE);  
        NetworkInfo activeNetInfo = connectivityManager.getActiveNetworkInfo();  
        if (activeNetInfo != null  
                && activeNetInfo.getType() == ConnectivityManager.TYPE_MOBILE) {  
            return true;  
        }  
        return false;  
    }

    public static int getNetworkType(Context context)
    {
        ConnectivityManager connectivityManager = (ConnectivityManager) context
                .getSystemService(Context.CONNECTIVITY_SERVICE);
        NetworkInfo activeNetInfo = connectivityManager.getActiveNetworkInfo();
        if (activeNetInfo != null)
        {
            return activeNetInfo.getType();
        }
        return 0;
    }

    @Override
    public void onReceive(Context context, Intent intent)
    {
        boolean isAvailable = isNetworkAvailable(context);
        if(isAvailable && !_isNetworkAvailable)
        {
            Cocos2dxLuaJavaBridge.callLuaGlobalFunctionWithString("OnNetworkAvailable","");
        }
        else if(!isAvailable && _isNetworkAvailable)
        {
            Cocos2dxLuaJavaBridge.callLuaGlobalFunctionWithString("OnNetworkUnavailable","");
        }
        _isNetworkAvailable = isAvailable;
    }
}



 











