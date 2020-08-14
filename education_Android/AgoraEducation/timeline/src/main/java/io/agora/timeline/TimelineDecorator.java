package io.agora.timeline;

public abstract class TimelineDecorator implements Timeline {
    private Timeline timeline;

    public TimelineDecorator(Timeline timeline) {
        this.timeline = timeline;
    }

    @Override
    public void start() {
        if (getState() == TimelineState.STATE_BUFFERING) {
            return;
        }
        timeline.start();
    }

    @Override
    public void seekTo(long positionMs) {
        if (getState() == TimelineState.STATE_BUFFERING) {
            return;
        }
        timeline.seekTo(positionMs);
    }

    @Override
    public void pause() {
        if (getState() != TimelineState.STATE_START) {
            return;
        }
        timeline.pause();
    }

    @Override
    public void stop() {
        if (getState() != TimelineState.STATE_START
                && getState() != TimelineState.STATE_PAUSE) {
            return;
        }
        timeline.stop();
    }

    @TimelineState
    @Override
    public int getState() {
        return timeline.getState();
    }
}
