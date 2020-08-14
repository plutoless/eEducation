package io.agora.log;

import android.content.Context;

import com.elvishew.xlog.LogConfiguration;
import com.elvishew.xlog.LogLevel;
import com.elvishew.xlog.Logger;
import com.elvishew.xlog.XLog;
import com.elvishew.xlog.printer.AndroidPrinter;
import com.elvishew.xlog.printer.file.FilePrinter;
import com.elvishew.xlog.printer.file.naming.ChangelessFileNameGenerator;

import java.io.File;

public class LogManager {

    public static File path;
    private static String tag;
    private Logger logger;

    public static void init(Context context, String tag) {
        path = new File(context.getExternalCacheDir(), "logs");
        LogManager.tag = tag;
        XLog.init(new LogConfiguration.Builder()
                        .logLevel(LogLevel.ALL)
                        .tag(tag).build(),
                new AndroidPrinter(),
                new FilePrinter.Builder(path.getPath())
                        .fileNameGenerator(new ChangelessFileNameGenerator(tag + ".log"))
                        .build());
    }

    public LogManager(String tag) {
        logger = XLog.tag(LogManager.tag + " " + tag).build();
    }

    public void d(String msg, Object... args) {
        logger.d(msg, args);
    }

    public void i(String msg, Object... args) {
        logger.i(msg, args);
    }

    public void w(String msg, Object... args) {
        logger.w(msg, args);
    }

    public void e(String msg, Object... args) {
        logger.e(msg, args);
    }

}
