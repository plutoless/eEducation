package io.agora.education.service;

import io.agora.education.service.bean.ResponseBody;
import io.agora.education.service.bean.response.RecordRes;
import retrofit2.Call;
import retrofit2.http.GET;
import retrofit2.http.Path;

public interface RecordService {

    @GET("/edu/v1/apps/{appId}/room/{roomId}/record/{recordId}")
    Call<ResponseBody<RecordRes>> record(
            @Path("appId") String appId,
            @Path("roomId") String roomId,
            @Path("recordId") String recordId
    );

}
