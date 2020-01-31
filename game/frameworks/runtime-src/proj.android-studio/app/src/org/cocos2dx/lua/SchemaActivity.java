package org.cocos2dx.lua;

import android.app.Activity;
import android.content.Intent;
import android.os.Bundle;
import android.support.annotation.Nullable;

public class SchemaActivity extends Activity {
    @Override
    protected void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        //处理openUrl
        try {
            HandleOpenUrl(getIntent());
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    @Override
    protected void onNewIntent(Intent intent) {
        super.onNewIntent(intent);
        setIntent(intent);
        HandleOpenUrl(intent);
    }

    private void HandleOpenUrl(Intent intent){
        AppActivity.getInstance().HandleOpenUrl(intent);
    }
}
