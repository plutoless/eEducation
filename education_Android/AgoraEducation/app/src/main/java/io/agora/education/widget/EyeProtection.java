package io.agora.education.widget;

import android.content.Context;
import android.util.AttributeSet;
import android.view.View;

import androidx.annotation.Nullable;

import io.agora.base.PreferenceManager;
import io.agora.education.R;
import io.agora.education.util.StatusBarUtil;

public class EyeProtection {

    private static final String KEY_SP = EyeProtection.class.getSimpleName();

    public static class EyeProtectionView extends View {
        public EyeProtectionView(Context context) {
            this(context, null);
        }

        public EyeProtectionView(Context context, @Nullable AttributeSet attrs) {
            this(context, attrs, 0);
        }

        public EyeProtectionView(Context context, @Nullable AttributeSet attrs, int defStyleAttr) {
            super(context, attrs, defStyleAttr);
            setBackgroundColor(getResources().getColor(R.color.eye_care_color));
        }

        @Override
        public void setVisibility(int visibility) {
            super.setVisibility(visibility);
            if (visibility == VISIBLE) {
                StatusBarUtil.setStatusBarColor(getContext(), R.color.eye_care_color);
            } else if (visibility == GONE) {
                StatusBarUtil.setStatusBarColor(getContext(), R.color.colorPrimaryDark);
            }
        }
    }

    public static boolean isNeedShow() {
        return PreferenceManager.get(KEY_SP, false);
    }

    public static void setNeedShow(boolean isNeed) {
        PreferenceManager.put(KEY_SP, isNeed);
    }

}
