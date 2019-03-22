package com.example.fancylib;

import android.app.Activity;

import com.facebook.react.ReactInstanceManager;
import com.facebook.react.bridge.CatalystInstance;
import com.facebook.react.bridge.ReactContext;
import com.facebook.react.bridge.WritableNativeArray;
import com.facebook.react.common.LifecycleState;
import com.facebook.react.shell.MainReactPackage;

public class UnifiedSDK {
    private static ReactInstanceManager manager;

    public static void init(Activity activity) {
        if (manager == null) {
            manager = ReactInstanceManager.builder()
                    .setApplication(activity.getApplication())
                    .setCurrentActivity(activity)
                    .setBundleAssetName("unifiedsdk.bundle")
                    .setJSMainModulePath("index")
                    .addPackage(new MainReactPackage())
                    .setUseDeveloperSupport(BuildConfig.DEBUG)
                    .setInitialLifecycleState(LifecycleState.RESUMED)
                    .build();
            manager.createReactContextInBackground();
        }
    }

    public static void helloWorld() {
        if (manager != null) {
            ReactContext reactContext = manager.getCurrentReactContext();
            if (reactContext != null) {
                CatalystInstance catalystInstance = reactContext.getCatalystInstance();
                WritableNativeArray params = new WritableNativeArray();
                params.pushString("UnifiedSDK");
                catalystInstance.callFunction("CommonInterface", "helloworld", params);
            }
        }
    }
}