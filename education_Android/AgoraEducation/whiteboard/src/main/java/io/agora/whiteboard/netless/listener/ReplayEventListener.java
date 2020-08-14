package io.agora.whiteboard.netless.listener;

import com.herewhite.sdk.domain.PlayerPhase;

import io.agora.whiteboard.netless.manager.ReplayManager;

public interface ReplayEventListener {

    void onPlayerPrepared(ReplayManager replayBoard);

    void onPhaseChanged(PlayerPhase playerPhase);

    void onLoadFirstFrame();

    void onScheduleTimeChanged(long l);

}
