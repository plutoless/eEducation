package io.agora.sdk.annotation;

import androidx.annotation.IntDef;

import java.lang.annotation.Retention;
import java.lang.annotation.RetentionPolicy;

import io.agora.rtm.RtmStatusCode;

@IntDef({
        RtmStatusCode.ConnectionState.CONNECTION_STATE_DISCONNECTED,
        RtmStatusCode.ConnectionState.CONNECTION_STATE_CONNECTING,
        RtmStatusCode.ConnectionState.CONNECTION_STATE_CONNECTED,
        RtmStatusCode.ConnectionState.CONNECTION_STATE_RECONNECTING,
        RtmStatusCode.ConnectionState.CONNECTION_STATE_ABORTED
})
@Retention(RetentionPolicy.SOURCE)
public @interface ConnectionState {

}
