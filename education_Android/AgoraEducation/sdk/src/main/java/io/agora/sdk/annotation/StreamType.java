package io.agora.sdk.annotation;

import androidx.annotation.IntDef;

import java.lang.annotation.Retention;
import java.lang.annotation.RetentionPolicy;

import io.agora.rtc.Constants;

@IntDef({Constants.VIDEO_STREAM_HIGH, Constants.VIDEO_STREAM_LOW})
@Retention(RetentionPolicy.SOURCE)
public @interface StreamType {

}
