package io.agora.education.util;

import java.util.Formatter;
import java.util.Locale;

public class TimeUtil {

    public static String stringForTimeHMS(long timeS, String formatStrHMS) {
        long seconds = timeS % 60;
        long minutes = timeS / 60 % 60;
        long hours = timeS / 3600;
        return new Formatter(new StringBuffer(), Locale.getDefault())
                .format(formatStrHMS, hours, minutes, seconds).toString();
    }

}
