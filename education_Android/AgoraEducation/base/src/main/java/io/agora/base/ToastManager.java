package io.agora.base;

import android.app.Application;
import android.os.Handler;
import android.widget.Toast;

import androidx.annotation.StringRes;

public class ToastManager {

    private static Application context;
    private static Handler handler;

    public static void init(Application application) {
        ToastManager.context = application;
        handler = new Handler();
    }

    public static void showShort(@StringRes int stringResId) {
        showShort(context.getString(stringResId));
    }

    public static void showShort(String text) {
        handler.post(() -> Toast.makeText(context, text, Toast.LENGTH_SHORT).show());
    }

}
