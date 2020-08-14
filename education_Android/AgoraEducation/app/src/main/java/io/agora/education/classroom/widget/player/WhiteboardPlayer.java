package io.agora.education.classroom.widget.player;

import io.agora.timeline.Timeline;
import io.agora.timeline.TimelineState;
import io.agora.whiteboard.netless.manager.ReplayManager;

public class WhiteboardPlayer implements Timeline {
    private ReplayManager mPlayer;

    WhiteboardPlayer(ReplayManager player) {
        mPlayer = player;
    }

    @Override
    public void start() {
        mPlayer.play();
    }

    @Override
    public void pause() {
        mPlayer.pause();
    }

    @Override
    public void seekTo(long positionMs) {
        mPlayer.seekToScheduleTime(positionMs);
    }

    @Override
    public void stop() {
        mPlayer.stop();
    }

    @TimelineState
    @Override
    public int getState() {
        switch (mPlayer.getPlayerPhase()) {
            case waitingFirstFrame:
            case buffering:
                return TimelineState.STATE_BUFFERING;
            case playing:
                return TimelineState.STATE_START;
            case pause:
                return TimelineState.STATE_PAUSE;
            case stopped:
            case ended:
                return TimelineState.STATE_STOP;
        }
        return TimelineState.STATE_IDLE;
    }
}
