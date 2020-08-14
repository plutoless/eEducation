package io.agora.sdk.annotation;

import androidx.annotation.IntDef;

import java.lang.annotation.Retention;
import java.lang.annotation.RetentionPolicy;

import io.agora.rtc.Constants;

@IntDef({
        Constants.CHANNEL_PROFILE_COMMUNICATION,
        Constants.CHANNEL_PROFILE_LIVE_BROADCASTING,
        Constants.CHANNEL_PROFILE_GAME
})
@Retention(RetentionPolicy.SOURCE)
public @interface ChannelProfile {

}
