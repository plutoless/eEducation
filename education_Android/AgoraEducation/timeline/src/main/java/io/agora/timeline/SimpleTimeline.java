package io.agora.timeline;

import java.util.Date;
import java.util.Timer;
import java.util.TimerTask;
import java.util.concurrent.atomic.AtomicLong;

public class SimpleTimeline implements Timeline {
    public static final int PERIOD = 1000 / 15;

    @TimelineState
    private int state = TimelineState.STATE_IDLE;

    private long startTime, endTime;
    private AtomicLong playedTime = new AtomicLong();
    private long previewTime;

    private Timer timer;
    private TimelineListener listener;

    public SimpleTimeline(long startTime, long endTime) {
        this.startTime = startTime;
        this.endTime = endTime;
    }

    public long getDuration() {
        return endTime - startTime;
    }

    @Override
    public void start() {
        previewTime = new Date().getTime();

        timer = new Timer();
        timer.schedule(task(), PERIOD, PERIOD);

        state = TimelineState.STATE_START;
        if (listener != null) {
            listener.onStart();
        }
    }

    @Override
    public void seekTo(long positionMs) {
        playedTime.set(positionMs);
    }

    @Override
    public void pause() {
        timer.cancel();
        timer = null;

        state = TimelineState.STATE_PAUSE;
        if (listener != null) {
            listener.onPause();
        }
    }

    @Override
    public void stop() {
        timer.cancel();
        timer = null;

        state = TimelineState.STATE_STOP;
        if (listener != null) {
            listener.onStop();
        }
    }

    @Override
    public int getState() {
        return state;
    }

    private TimerTask task() {
        return new TimerTask() {
            @Override
            public void run() {
                long nowTime = new Date().getTime();
                playedTime.set(playedTime.get() + (nowTime - previewTime));
                if (startTime + playedTime.get() > endTime) {
                    stop();
                    return;
                }
                if (listener != null) {
                    listener.onTimelineChanged(playedTime.get(), endTime - startTime);
                }
                previewTime = nowTime;
            }
        };
    }

    public void setTimelineListener(TimelineListener listener) {
        this.listener = listener;
    }
}
