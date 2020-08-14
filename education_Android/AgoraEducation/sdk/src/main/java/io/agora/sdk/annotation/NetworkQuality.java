package io.agora.sdk.annotation;

import androidx.annotation.IntDef;

import java.lang.annotation.Retention;
import java.lang.annotation.RetentionPolicy;

import io.agora.rtc.Constants;

@IntDef({
        Constants.QUALITY_UNKNOWN,
        Constants.QUALITY_EXCELLENT,
        Constants.QUALITY_GOOD,
        Constants.QUALITY_POOR,
        Constants.QUALITY_BAD,
        Constants.QUALITY_VBAD,
        Constants.QUALITY_DOWN,
        Constants.QUALITY_UNSUPPORTED,
        Constants.QUALITY_DETECTING
})
@Retention(RetentionPolicy.SOURCE)
public @interface NetworkQuality {

}
