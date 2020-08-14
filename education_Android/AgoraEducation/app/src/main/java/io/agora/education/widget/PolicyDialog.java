package io.agora.education.widget;

import android.os.Bundle;
import android.text.SpannableString;
import android.text.Spanned;
import android.text.method.LinkMovementMethod;
import android.text.style.URLSpan;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.fragment.app.FragmentManager;

import io.agora.base.PreferenceManager;
import io.agora.education.BuildConfig;
import io.agora.education.R;

public class PolicyDialog extends ConfirmDialog implements ConfirmDialog.DialogClickListener {

    private final String KEY_SP = EyeProtection.class.getSimpleName();

    @Nullable
    @Override
    public View onCreateView(@NonNull LayoutInflater inflater, @Nullable ViewGroup container, @Nullable Bundle savedInstanceState) {
        View view = super.onCreateView(inflater, container, savedInstanceState);
        String tips = getString(R.string.policy_tips);
        String policy = getString(R.string.policy);
        SpannableString spannableString = new SpannableString(tips);
        int index = tips.toLowerCase().indexOf(policy.toLowerCase());
        spannableString.setSpan(new URLSpan(BuildConfig.POLICY_URL), index, index + policy.length(), Spanned.SPAN_EXCLUSIVE_EXCLUSIVE);
        tv_content.setMovementMethod(LinkMovementMethod.getInstance());
        tv_content.setText(spannableString);
        tv_dialog_cancel.setText(R.string.policy_refuse);
        tv_dialog_confirm.setText(R.string.policy_agree);
        listener = this;
        setCancelable(false);
        return view;
    }

    @Override
    public void show(@NonNull FragmentManager manager, @Nullable String tag) {
        if (isNeedShow()) {
            super.show(manager, tag);
        }
    }

    private boolean isNeedShow() {
        return PreferenceManager.get(KEY_SP, true);
    }

    private void setNeedShow(boolean isNeed) {
        PreferenceManager.put(KEY_SP, isNeed);
    }

    @Override
    public void onClick(boolean confirm) {
        if (confirm) {
            setNeedShow(false);
            dismiss();
        } else {
            System.exit(0);
        }
    }

}
