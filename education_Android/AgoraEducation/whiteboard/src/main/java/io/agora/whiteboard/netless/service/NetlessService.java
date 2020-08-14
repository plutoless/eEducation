package io.agora.whiteboard.netless.service;

import io.agora.whiteboard.netless.service.bean.ResponseBody;
import retrofit2.Call;
import retrofit2.http.Field;
import retrofit2.http.FormUrlEncoded;
import retrofit2.http.POST;

public interface NetlessService {

    @FormUrlEncoded
    @POST("/room/join")
    Call<ResponseBody> roomJoin(
            @Field("uuid") String uuid,
            @Field("token") String token
    );

}
