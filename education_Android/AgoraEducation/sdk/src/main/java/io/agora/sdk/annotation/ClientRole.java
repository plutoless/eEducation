package io.agora.sdk.annotation;

import androidx.annotation.IntDef;

import java.lang.annotation.Retention;
import java.lang.annotation.RetentionPolicy;

import io.agora.rtc.Constants;

@IntDef({Constants.CLIENT_ROLE_BROADCASTER, Constants.CLIENT_ROLE_AUDIENCE})
@Retention(RetentionPolicy.SOURCE)
public @interface ClientRole {

}
