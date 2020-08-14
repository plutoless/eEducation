package io.agora.education.classroom.widget;

import android.content.Context;
import android.content.res.Resources;
import android.os.Handler;
import android.util.AttributeSet;
import android.util.TypedValue;
import android.view.Gravity;

import androidx.appcompat.widget.AppCompatTextView;

import io.agora.education.R;
import io.agora.education.util.TimeUtil;

public class TimeView extends AppCompatTextView {

    private Handler handler;
    private long time = -1;
    private Runnable updateTimeRunnable = () -> {
        if (time >= 0) {
            setText(TimeUtil.stringForTimeHMS(time, "%02d:%02d:%02d"));
            time++;
            handler.postDelayed(this.updateTimeRunnable, 1000);
        } else {
            setText(R.string.time_default);
        }
    };

    public TimeView(Context context) {
        this(context, null);
    }

    public TimeView(Context context, AttributeSet attrs) {
        this(context, attrs, 0);
    }

    public TimeView(Context context, AttributeSet attrs, int defStyleAttr) {
        super(context, attrs, defStyleAttr);
        handler = new Handler();
        setGravity(Gravity.CENTER);
        setText(R.string.time_default);
        Resources resources = getResources();
        setTextSize(TypedValue.COMPLEX_UNIT_PX, resources.getDimension(R.dimen.sp_12));
        setTextColor(resources.getColor(R.color.gray_333333));
        setCompoundDrawablesRelativeWithIntrinsicBounds(resources.getDrawable(R.drawable.ic_time), null, null, null);
    }

    public long getTime() {
        return time;
    }

    public void setTime(long time) {
        this.time = time / 1000;
    }

    public boolean isStarted() {
        return time >= 0;
    }

    public void start() {
        if (time < 0) {
            time = 0;
        }
        handler.removeCallbacks(updateTimeRunnable);
        updateTimeRunnable.run();
    }

    public void stop() {
        time = -1;
        handler.removeCallbacks(updateTimeRunnable);
        updateTimeRunnable.run();
    }

}
