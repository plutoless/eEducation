package io.agora.education;

import android.app.Application;

import androidx.annotation.Nullable;

import java.util.Map;

import io.agora.base.PreferenceManager;
import io.agora.base.ToastManager;
import io.agora.education.service.bean.response.AppConfigRes;
import io.agora.log.LogManager;

public class EduApplication extends Application {

    public static EduApplication instance;

    private AppConfigRes config;

    @Override
    public void onCreate() {
        super.onCreate();
        instance = this;

        LogManager.init(this, BuildConfig.EXTRA);
        PreferenceManager.init(this);
        ToastManager.init(this);
    }

    @Nullable
    public static String getAppId() {
        if (instance.config == null) return null;
        return instance.config.appId;
    }

    public static void setAppId(String appId) {
        if (instance.config == null) {
            instance.config = new AppConfigRes();
        }
        instance.config.appId = appId;
    }

    @Nullable
    public static Map<String, Map<Integer, String>> getMultiLanguage() {
        if (instance.config == null) return null;
        return instance.config.multiLanguage;
    }

    public static void setMultiLanguage(Map<String, Map<Integer, String>> multiLanguage) {
        if (instance.config == null) {
            instance.config = new AppConfigRes();
        }
        instance.config.multiLanguage = multiLanguage;
    }

}
