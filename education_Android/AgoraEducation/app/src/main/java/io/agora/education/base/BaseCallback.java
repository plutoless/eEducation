package io.agora.education.base;

import android.text.TextUtils;

import androidx.annotation.Nullable;

import java.util.Locale;
import java.util.Map;

import io.agora.base.Callback;
import io.agora.base.ToastManager;
import io.agora.base.network.BusinessException;
import io.agora.base.network.RetrofitManager;
import io.agora.education.EduApplication;
import io.agora.education.R;
import io.agora.education.service.bean.ResponseBody;

public class BaseCallback<T> extends RetrofitManager.Callback<ResponseBody<T>> {

    public BaseCallback(@Nullable SuccessCallback<T> callback) {
        super(0, new Callback<ResponseBody<T>>() {
            @Override
            public void onSuccess(ResponseBody<T> res) {
                if (callback != null) {
                    callback.onSuccess(res.data);
                }
            }

            @Override
            public void onFailure(Throwable throwable) {
                checkError(throwable);
            }
        });
    }

    public BaseCallback(@Nullable SuccessCallback<T> success, @Nullable FailureCallback failure) {
        super(0, new Callback<ResponseBody<T>>() {
            @Override
            public void onSuccess(ResponseBody<T> res) {
                if (success != null) {
                    success.onSuccess(res.data);
                }
            }

            @Override
            public void onFailure(Throwable throwable) {
                checkError(throwable);
                if (failure != null) {
                    failure.onFailure(throwable);
                }
            }
        });
    }

    private static void checkError(Throwable throwable) {
        String message = throwable.getMessage();
        if (throwable instanceof BusinessException) {
            int code = ((BusinessException) throwable).getCode();
            Map<String, Map<Integer, String>> languages = EduApplication.getMultiLanguage();
            if (languages != null) {
                Locale locale = Locale.getDefault();
                if (!Locale.SIMPLIFIED_CHINESE.toString().equals(locale.toString())) {
                    locale = Locale.US;
                }
                String key = String.format("%s-%s", locale.getLanguage(), locale.getCountry()).toLowerCase();
                Map<Integer, String> stringMap = languages.get(key);
                if (stringMap != null) {
                    String string = stringMap.get(code);
                    if (!TextUtils.isEmpty(string)) {
                        message = string;
                    }
                }
            }
            if (TextUtils.isEmpty(message)) {
                message = EduApplication.instance.getString(R.string.request_error, code);
            }
        }
        if (!TextUtils.isEmpty(message)) {
            ToastManager.showShort(message);
        }
    }

    public interface SuccessCallback<T> {
        void onSuccess(T data);
    }

    public interface FailureCallback {
        void onFailure(Throwable throwable);
    }

}
