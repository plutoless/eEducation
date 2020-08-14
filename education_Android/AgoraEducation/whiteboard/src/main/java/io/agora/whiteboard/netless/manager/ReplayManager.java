package io.agora.whiteboard.netless.manager;

import android.os.Handler;
import android.os.Looper;

import com.herewhite.sdk.Player;
import com.herewhite.sdk.PlayerEventListener;
import com.herewhite.sdk.WhiteSdk;
import com.herewhite.sdk.combinePlayer.NativePlayer;
import com.herewhite.sdk.combinePlayer.PlayerSyncManager;
import com.herewhite.sdk.domain.PlayerConfiguration;
import com.herewhite.sdk.domain.PlayerPhase;
import com.herewhite.sdk.domain.PlayerState;
import com.herewhite.sdk.domain.PlayerTimeInfo;
import com.herewhite.sdk.domain.SDKError;

import io.agora.base.ToastManager;
import io.agora.whiteboard.netless.listener.ReplayEventListener;

public class ReplayManager extends NetlessManager<Player> implements PlayerEventListener {

    private Handler handler = new Handler(Looper.getMainLooper());
    private ReplayEventListener listener;

    public void setListener(ReplayEventListener listener) {
        this.listener = listener;
    }

    public void init(WhiteSdk sdk, PlayerConfiguration configuration) {
        sdk.createPlayer(configuration, this, promise);
    }

    public PlayerSyncManager getSyncManager(NativePlayer nativePlayer, PlayerSyncManager.Callbacks callbacks) {
        return new PlayerSyncManager(t, nativePlayer, callbacks);
    }

    public void play() {
        if (t != null)
            t.play();
    }

    public void pause() {
        if (t != null)
            t.pause();
    }

    public void stop() {
        if (t != null)
            t.stop();
    }

    public void seekToScheduleTime(long time) {
        if (t != null)
            t.seekToScheduleTime(time);
    }

    public PlayerPhase getPlayerPhase() {
        if (t != null)
            return t.getPlayerPhase();
        return null;
    }

    public PlayerTimeInfo getPlayerTimeInfo() {
        if (t != null)
            return t.getPlayerTimeInfo();
        return null;
    }

    @Override
    public void onPhaseChanged(PlayerPhase phase) {
        if (listener != null) {
            handler.post(() -> listener.onPhaseChanged(phase));
        }
    }

    @Override
    public void onLoadFirstFrame() {
        if (listener != null) {
            handler.post(() -> listener.onLoadFirstFrame());
        }
    }

    @Override
    public void onSliceChanged(String slice) {

    }

    @Override
    public void onPlayerStateChanged(PlayerState modifyState) {

    }

    @Override
    public void onStoppedWithError(SDKError error) {

    }

    @Override
    public void onScheduleTimeChanged(long time) {
        if (listener != null) {
            handler.post(() -> listener.onScheduleTimeChanged(time));
        }
    }

    @Override
    public void onCatchErrorWhenAppendFrame(SDKError error) {

    }

    @Override
    public void onCatchErrorWhenRender(SDKError error) {

    }

    @Override
    void onSuccess(Player player) {
        if (listener != null) {
            handler.post(() -> listener.onPlayerPrepared(this));
        }
    }

    @Override
    void onFail(SDKError error) {
        ToastManager.showShort(error.toString());
    }

}
