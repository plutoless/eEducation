package io.agora.sdk.manager;

import android.content.Context;

import java.util.Map;

/**
 * Agora SDK manager template
 */
public abstract class SdkManager<Sdk> {

    public static final String TOKEN = "token";
    public static final String CHANNEL_ID = "channelId";
    public static final String USER_ID = "userId";
    public static final String USER_EXTRA = "userExtra";

    protected Sdk sdk;

    public final void init(Context context, String appId) {
        try {
            if (sdk != null) release();
            sdk = creakSdk(context, appId);
        } catch (Exception e) {
            throw new RuntimeException(e.getMessage());
        }
        configSdk();
    }

    protected abstract Sdk creakSdk(Context context, String appId) throws Exception;

    protected abstract void configSdk();

    public abstract void joinChannel(Map<String, String> data);

    public abstract void leaveChannel();

    protected abstract void destroySdk();

    public final void release() {
        leaveChannel();
        destroySdk();
        sdk = null;
    }

}
