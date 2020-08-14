package io.agora.base.network;

import androidx.annotation.NonNull;

import java.io.IOException;
import java.util.HashMap;
import java.util.Map;
import java.util.concurrent.TimeUnit;

import okhttp3.OkHttpClient;
import okhttp3.Request;
import retrofit2.Call;
import retrofit2.Response;
import retrofit2.Retrofit;
import retrofit2.converter.gson.GsonConverterFactory;

public class RetrofitManager {

    private static RetrofitManager instance;

    private OkHttpClient client;
    private Map<String, String> headers = new HashMap<>();

    private RetrofitManager() {
        OkHttpClient.Builder clientBuilder = new OkHttpClient.Builder();
        clientBuilder.connectTimeout(30, TimeUnit.SECONDS);
        clientBuilder.readTimeout(30, TimeUnit.SECONDS);
        clientBuilder.addInterceptor(chain -> {
            Request request = chain.request();
            Request.Builder requestBuilder = request.newBuilder()
                    .method(request.method(), request.body());
            if (headers != null) {
                for (Map.Entry<String, String> entry : headers.entrySet()) {
                    requestBuilder.addHeader(entry.getKey(), entry.getValue());
                }
            }
            return chain.proceed(requestBuilder.build());
        });
        client = clientBuilder.build();
    }

    public static RetrofitManager instance() {
        if (instance == null) {
            synchronized (RetrofitManager.class) {
                if (instance == null) {
                    instance = new RetrofitManager();
                }
            }
        }
        return instance;
    }

    public void addHeader(String key, String value) {
        headers.put(key, value);
    }

    public <T> T getService(String baseUrl, Class<T> tClass) {
        Retrofit retrofit = new Retrofit.Builder()
                .client(client)
                .baseUrl(baseUrl)
                .addConverterFactory(GsonConverterFactory.create())
                .build();
        return retrofit.create(tClass);
    }

    public static class Callback<T extends ResponseBody> implements retrofit2.Callback<T> {
        private int code;
        private io.agora.base.Callback<T> callback;

        public Callback(int code, @NonNull io.agora.base.Callback<T> callback) {
            this.code = code;
            this.callback = callback;
        }

        @Override
        public void onResponse(@NonNull Call<T> call, @NonNull Response<T> response) {
            if (response.errorBody() != null) {
                try {
                    callback.onFailure(new Throwable(response.errorBody().string()));
                } catch (IOException e) {
                    callback.onFailure(e);
                }
            } else {
                T body = response.body();
                if (body == null) {
                    callback.onFailure(new Throwable("response body is null"));
                } else {
                    if (body.code != code) {
                        callback.onFailure(new BusinessException(body.code, body.msg.toString()));
                    } else {
                        callback.onSuccess(body);
                    }
                }
            }
        }

        @Override
        public void onFailure(@NonNull Call<T> call, @NonNull Throwable t) {
            callback.onFailure(t);
        }
    }

}
