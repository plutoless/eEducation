package io.agora.timeline;

public interface Timeline {
    void start();

    void pause();

    void seekTo(long positionMs);

    void stop();

    @TimelineState
    int getState();
}
