package io.agora.education.base;

import android.os.Bundle;
import android.view.View;
import android.view.ViewGroup;

import androidx.annotation.LayoutRes;
import androidx.annotation.Nullable;
import androidx.appcompat.app.AppCompatActivity;

import butterknife.ButterKnife;
import io.agora.education.widget.EyeProtection;

public abstract class BaseActivity extends AppCompatActivity {

    private EyeProtection.EyeProtectionView eyeProtectionView;

    @Override
    protected void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(getLayoutResId());
        ButterKnife.bind(this);
        initData();
        initView();
    }

    @LayoutRes
    protected abstract int getLayoutResId();

    protected abstract void initData();

    protected abstract void initView();

    @Override
    protected void onStart() {
        super.onStart();
        if (EyeProtection.isNeedShow()) {
            showEyeProtection();
        } else {
            dismissEyeProtection();
        }
    }

    protected void showEyeProtection() {
        if (eyeProtectionView == null) {
            eyeProtectionView = new EyeProtection.EyeProtectionView(this);
        }
        if (eyeProtectionView.getParent() == null) {
            addContentView(eyeProtectionView, new ViewGroup.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.MATCH_PARENT));
        }
        eyeProtectionView.setVisibility(View.VISIBLE);
    }

    protected void dismissEyeProtection() {
        if (eyeProtectionView != null) {
            eyeProtectionView.setVisibility(View.GONE);
        }
    }

    protected void removeFromParent(View view) {
        ViewGroup viewGroup = (ViewGroup) view.getParent();
        if (viewGroup != null) {
            viewGroup.removeView(view);
        }
    }

}
