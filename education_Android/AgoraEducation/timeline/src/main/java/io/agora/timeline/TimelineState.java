package io.agora.timeline;

import androidx.annotation.IntDef;

import java.lang.annotation.Retention;
import java.lang.annotation.RetentionPolicy;

@IntDef({
        TimelineState.STATE_IDLE,
        TimelineState.STATE_BUFFERING,
        TimelineState.STATE_START,
        TimelineState.STATE_PAUSE,
        TimelineState.STATE_STOP
})
@Retention(RetentionPolicy.SOURCE)
public @interface TimelineState {
    int STATE_IDLE = 0;
    int STATE_BUFFERING = 1;
    int STATE_START = 2;
    int STATE_PAUSE = 3;
    int STATE_STOP = 4;
}
