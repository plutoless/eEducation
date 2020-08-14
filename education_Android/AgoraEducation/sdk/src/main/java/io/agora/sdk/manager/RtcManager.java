package io.agora.sdk.manager;

import android.content.Context;
import android.view.SurfaceView;

import androidx.annotation.NonNull;

import java.io.File;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;

import io.agora.log.LogManager;
import io.agora.rtc.Constants;
import io.agora.rtc.IRtcEngineEventHandler;
import io.agora.rtc.RtcEngine;
import io.agora.rtc.video.VideoCanvas;
import io.agora.rtc.video.VideoEncoderConfiguration;
import io.agora.sdk.BuildConfig;
import io.agora.sdk.annotation.ChannelProfile;
import io.agora.sdk.annotation.ClientRole;
import io.agora.sdk.annotation.RenderMode;
import io.agora.sdk.annotation.StreamType;
import io.agora.sdk.listener.RtcEventListener;

public final class RtcManager extends SdkManager<RtcEngine> {

    private final LogManager log = new LogManager(this.getClass().getSimpleName());

    private List<RtcEventListener> listeners;

    private static RtcManager instance;

    private RtcManager() {
        listeners = new ArrayList<>();
    }

    public static RtcManager instance() {
        if (instance == null) {
            synchronized (RtcManager.class) {
                if (instance == null)
                    instance = new RtcManager();
            }
        }
        return instance;
    }

    @Override
    protected RtcEngine creakSdk(Context context, String appId) throws Exception {
        return RtcEngine.create(context, appId, eventHandler);
    }

    @Override
    protected void configSdk() {
        sdk.setLogFile(new File(LogManager.path, "agorasdk.log").getAbsolutePath());
        if (BuildConfig.DEBUG) {
            sdk.setParameters("{\"rtc.log_filter\": 65535}");
        }
        sdk.enableAudio();
        sdk.enableVideo();
        sdk.enableWebSdkInteroperability(true);
        VideoEncoderConfiguration config = new VideoEncoderConfiguration(
                VideoEncoderConfiguration.VD_360x360,
                VideoEncoderConfiguration.FRAME_RATE.FRAME_RATE_FPS_15,
                VideoEncoderConfiguration.STANDARD_BITRATE,
                VideoEncoderConfiguration.ORIENTATION_MODE.ORIENTATION_MODE_FIXED_LANDSCAPE
        );
        sdk.setVideoEncoderConfiguration(config);
    }

    @Override
    public void joinChannel(@NonNull Map<String, String> data) {
        sdk.joinChannel(data.get(TOKEN), data.get(CHANNEL_ID), data.get(USER_EXTRA), Integer.parseInt(data.get(USER_ID)));
    }

    @Override
    public void leaveChannel() {
        sdk.leaveChannel();
    }

    @Override
    protected void destroySdk() {
        RtcEngine.destroy();
    }

    public void registerListener(RtcEventListener listener) {
        listeners.add(listener);
    }

    public void unregisterListener(RtcEventListener listener) {
        listeners.remove(listener);
    }

    public void setChannelProfile(@ChannelProfile int profile) {
        sdk.setChannelProfile(profile);
    }

    public void setClientRole(@ClientRole int role) {
        sdk.setClientRole(role);
    }

    public void muteLocalAudioStream(boolean isMute) {
        sdk.muteLocalAudioStream(isMute);
    }

    public void muteLocalVideoStream(boolean isMute) {
        sdk.muteLocalVideoStream(isMute);
    }

    public void enableDualStreamMode(boolean enable) {
        sdk.setParameters(String.format("{\"che.audio.live_for_comm\":%b}", enable));
        sdk.enableDualStreamMode(enable);
        sdk.setRemoteDefaultVideoStreamType(enable ? Constants.VIDEO_STREAM_LOW : Constants.VIDEO_STREAM_HIGH);
    }

    public void setRemoteVideoStreamType(int uid, @StreamType int streamType) {
        sdk.setRemoteVideoStreamType(uid, streamType);
    }

    public void setRemoteDefaultVideoStreamType(@StreamType int streamType) {
        sdk.setRemoteDefaultVideoStreamType(streamType);
    }

    public SurfaceView createRendererView(Context context) {
        return RtcEngine.CreateRendererView(context);
    }

    public void setupLocalVideo(SurfaceView view, @RenderMode int renderMode) {
        log.d("setupLocalVideo %b", view != null);
        VideoCanvas canvas = new VideoCanvas(view, renderMode, 0);
        sdk.setupLocalVideo(canvas);
    }

    public void startPreview() {
        sdk.startPreview();
    }

    public void setupRemoteVideo(SurfaceView view, @RenderMode int renderMode, int uid) {
        log.d("setupRemoteVideo %b %d", view != null, uid);
        VideoCanvas canvas = new VideoCanvas(view, renderMode, uid);
        sdk.setupRemoteVideo(canvas);
    }

    private IRtcEngineEventHandler eventHandler = new IRtcEngineEventHandler() {
        @Override
        public void onJoinChannelSuccess(String channel, int uid, int elapsed) {
            log.i("onJoinChannelSuccess %s %d", channel, uid);
            for (RtcEventListener listener : listeners) {
                listener.onJoinChannelSuccess(channel, uid, elapsed);
            }
        }

        @Override
        public void onRtcStats(RtcStats stats) {
            for (RtcEventListener listener : listeners) {
                listener.onRtcStats(stats);
            }
        }

        @Override
        public void onUserJoined(int uid, int elapsed) {
            log.i("onUserJoined %d", uid);
            for (RtcEventListener listener : listeners) {
                listener.onUserJoined(uid, elapsed);
            }
        }

        @Override
        public void onUserOffline(int uid, int reason) {
            log.i("onUserOffline %d", uid);
            for (RtcEventListener listener : listeners) {
                listener.onUserOffline(uid, reason);
            }
        }

        @Override
        public void onUserMuteAudio(int uid, boolean muted) {
            super.onUserMuteAudio(uid, muted);
        }

        @Override
        public void onRemoteAudioStats(RemoteAudioStats stats) {
            super.onRemoteAudioStats(stats);
        }

        @Override
        public void onRemoteAudioStateChanged(int uid, int state, int reason, int elapsed) {
            super.onRemoteAudioStateChanged(uid, state, reason, elapsed);
        }
    };

}
