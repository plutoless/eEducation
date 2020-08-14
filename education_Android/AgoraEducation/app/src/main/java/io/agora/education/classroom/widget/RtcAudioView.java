package io.agora.education.classroom.widget;

import android.content.Context;
import android.util.AttributeSet;

import androidx.annotation.IntDef;
import androidx.annotation.Nullable;
import androidx.appcompat.widget.AppCompatImageView;

import java.lang.annotation.Retention;
import java.lang.annotation.RetentionPolicy;

import io.agora.education.R;

public class RtcAudioView extends AppCompatImageView {

    @IntDef({State.CLOSED, State.OPENED, State.SPEAKING})
    @Retention(RetentionPolicy.SOURCE)
    public @interface State {
        int CLOSED = 0; // closed
        int OPENED = 1; // opened
        int SPEAKING = 2; // speaking
    }

    private int[] imgResArray = {
            R.drawable.ic_speaker_off,
            R.drawable.ic_speaker1,
            R.drawable.ic_speaker2,
            R.drawable.ic_speaker3
    };
    private int showIndex = 0;
    private int state = State.CLOSED;

    private Runnable runnable = () -> {
        setImageResource(this.imgResArray[this.showIndex]);
        if (this.state == 2) {
            this.showIndex++;
            postDelayed(this.runnable, 500);
        }
    };

    public RtcAudioView(Context context) {
        this(context, null);
    }

    public RtcAudioView(Context context, @Nullable AttributeSet attrs) {
        this(context, attrs, 0);
    }

    public RtcAudioView(Context context, @Nullable AttributeSet attrs, int defStyleAttr) {
        super(context, attrs, defStyleAttr);
        runnable.run();
    }

    public void setState(@State int state) {
        if (this.state != state) {
            this.state = state;
            if (state == State.OPENED) {
                showIndex = 3;
            } else if (state == State.CLOSED) {
                showIndex = 0;
            } else if (state == State.SPEAKING) {
                showIndex = 0;
            }
            runnable.run();
        }
    }

    public int getState() {
        return state;
    }

}
