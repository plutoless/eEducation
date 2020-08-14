package io.agora.education.classroom.widget;

import android.content.Context;
import android.content.res.Configuration;
import android.util.AttributeSet;
import android.view.LayoutInflater;
import android.view.View;
import android.widget.ImageView;
import android.widget.TextView;

import androidx.annotation.Nullable;
import androidx.constraintlayout.widget.ConstraintLayout;

import butterknife.BindView;
import butterknife.ButterKnife;
import butterknife.OnClick;
import io.agora.education.R;
import io.agora.education.classroom.BaseClassActivity;
import io.agora.rtc.Constants;
import io.agora.sdk.annotation.NetworkQuality;

public class TitleView extends ConstraintLayout {

    @Nullable
    @BindView(R.id.iv_quality)
    protected ImageView iv_quality;
    @BindView(R.id.tv_room_name)
    protected TextView tv_room_name;
    @Nullable
    @BindView(R.id.time_view)
    protected TimeView time_view;

    public TitleView(Context context) {
        this(context, null);
    }

    public TitleView(Context context, AttributeSet attrs) {
        this(context, attrs, 0);
    }

    public TitleView(Context context, AttributeSet attrs, int defStyleAttr) {
        super(context, attrs, defStyleAttr);
        init();
        ButterKnife.bind(this);
    }

    private void init() {
        int layoutResId;
        Configuration configuration = getResources().getConfiguration();
        if (configuration.orientation == Configuration.ORIENTATION_PORTRAIT) {
            layoutResId = R.layout.layout_title_portrait;
        } else {
            layoutResId = R.layout.layout_title_landscape;
        }
        LayoutInflater.from(getContext()).inflate(layoutResId, this, true);
    }

    public void setTitle(String title) {
        tv_room_name.setText(title);
    }

    public void setNetworkQuality(@NetworkQuality int quality) {
        if (iv_quality != null) {
            switch (quality) {
                case Constants.QUALITY_EXCELLENT:
                case Constants.QUALITY_GOOD:
                    iv_quality.setImageResource(R.drawable.ic_signal_good);
                    break;
                case Constants.QUALITY_VBAD:
                case Constants.QUALITY_DOWN:
                    iv_quality.setImageResource(R.drawable.ic_signal_bad);
                    break;
                default:
                    iv_quality.setImageResource(R.drawable.ic_signal_normal);
                    break;
            }
        }
    }

    public void setTimeState(boolean start, long time) {
        if (time_view != null) {
            if (start) {
                if (!time_view.isStarted()) {
                    time_view.start();
                }
                time_view.setTime(time);
            } else {
                time_view.stop();
            }
        }
    }

    @OnClick(R.id.iv_close)
    public void onClock(View view) {
        Context context = getContext();
        if (context instanceof BaseClassActivity) {
            ((BaseClassActivity) context).showLeaveDialog();
        }
    }

}
