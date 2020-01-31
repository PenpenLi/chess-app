package com.happy.winner.wxapi;

import android.app.Activity;
import android.content.Intent;
import android.os.Bundle;
import android.support.annotation.Nullable;
import android.widget.Toast;

import com.tencent.mm.opensdk.constants.ConstantsAPI;
import com.tencent.mm.opensdk.modelbase.BaseReq;
import com.tencent.mm.opensdk.modelbase.BaseResp;
import com.tencent.mm.opensdk.modelmsg.SendAuth;
import com.tencent.mm.opensdk.openapi.IWXAPI;
import com.tencent.mm.opensdk.openapi.IWXAPIEventHandler;
import com.tencent.mm.opensdk.openapi.WXAPIFactory;

import org.cocos2dx.lua.AppActivity;

public class WXEntryActivity extends Activity implements IWXAPIEventHandler {
//    private static String wechatAppId;
    private static IWXAPI wxapi;
//    private static AppActivity appActivity;
    @Override
    protected void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        if (wxapi != null){
            try {
                wxapi.handleIntent(getIntent(), this);
            } catch (Exception e) {
                e.printStackTrace();
            }
        }
    }

    public static void registerWXAPI(IWXAPI thewxapi){
        if (thewxapi != null){
            wxapi = thewxapi;
        }
    }

    @Override
    protected void onNewIntent(Intent intent) {
        super.onNewIntent(intent);
        setIntent(intent);
        if (wxapi != null){
            wxapi.handleIntent(intent, this);
        }
    }

    @Override
    public void onReq(BaseReq baseReq) {

    }

    @Override
    public void onResp(BaseResp baseResp) {
        if (baseResp.getType() == ConstantsAPI.COMMAND_SENDAUTH){
            String code = "";
            if (baseResp.errCode == BaseResp.ErrCode.ERR_OK) {
                code = ((SendAuth.Resp) baseResp).code;
            }
            AppActivity.getInstance().HandleWechatLoginResp(code);
        }
        else {
//            Toast.makeText(this, "launch result = " + baseResp.errStr, Toast.LENGTH_LONG).show();
        }
        finish();
    }
}
