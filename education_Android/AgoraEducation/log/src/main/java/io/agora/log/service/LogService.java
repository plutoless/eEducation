package io.agora.log.service;

import io.agora.log.service.bean.ResponseBody;
import io.agora.log.service.bean.response.LogParamsRes;
import retrofit2.Call;
import retrofit2.http.GET;
import retrofit2.http.POST;
import retrofit2.http.Query;

public interface LogService {

    // osType 1 iOS 2 Android
    // terminalType 1 phone 2 pad
    @GET("/edu/v1/log/params?&osType=2&terminalType=1")
    Call<ResponseBody<LogParamsRes>> logParams(
            @Query("appId") String appId,
            @Query("appCode") String appCode,
            @Query("appVersion") String appVersion,
            @Query("roomId") String roomId
    );

    @POST("/edu/v1/log/sts/callback")
    Call<ResponseBody<String>> logStsCallback();

}
