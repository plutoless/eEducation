package io.agora.sdk.annotation;

import androidx.annotation.IntDef;

import java.lang.annotation.Retention;
import java.lang.annotation.RetentionPolicy;

import io.agora.rtc.video.VideoCanvas;

@IntDef({VideoCanvas.RENDER_MODE_HIDDEN, VideoCanvas.RENDER_MODE_FIT})
@Retention(RetentionPolicy.SOURCE)
public @interface RenderMode {

}
