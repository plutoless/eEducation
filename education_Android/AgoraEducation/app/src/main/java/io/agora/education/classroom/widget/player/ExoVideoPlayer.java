package io.agora.education.classroom.widget.player;

import android.content.Context;
import android.net.Uri;
import android.webkit.URLUtil;

import androidx.annotation.NonNull;

import com.google.android.exoplayer2.ExoPlayer;
import com.google.android.exoplayer2.ExoPlayerFactory;
import com.google.android.exoplayer2.Player;
import com.google.android.exoplayer2.source.ExtractorMediaSource;
import com.google.android.exoplayer2.source.MediaSource;
import com.google.android.exoplayer2.source.hls.HlsMediaSource;
import com.google.android.exoplayer2.trackselection.AdaptiveTrackSelection;
import com.google.android.exoplayer2.trackselection.DefaultTrackSelector;
import com.google.android.exoplayer2.trackselection.TrackSelection;
import com.google.android.exoplayer2.trackselection.TrackSelector;
import com.google.android.exoplayer2.ui.PlayerView;
import com.google.android.exoplayer2.upstream.BandwidthMeter;
import com.google.android.exoplayer2.upstream.DataSource;
import com.google.android.exoplayer2.upstream.DefaultBandwidthMeter;
import com.google.android.exoplayer2.upstream.DefaultDataSourceFactory;
import com.google.android.exoplayer2.util.Util;

import io.agora.timeline.Timeline;
import io.agora.timeline.TimelineState;

public class ExoVideoPlayer implements Timeline {
    private ExoPlayer mPlayer;

    ExoVideoPlayer(@NonNull PlayerView playerView, String url) {
        if (URLUtil.isNetworkUrl(url)) {
            initVideoPlayer(playerView.getContext());
            initVideoSource(playerView.getContext(), url);
            playerView.setPlayer(mPlayer);
        }
    }

    private void initVideoPlayer(Context context) {
        BandwidthMeter bandwidthMeter = new DefaultBandwidthMeter();
        TrackSelection.Factory videoTrackSelectionFactory = new AdaptiveTrackSelection.Factory(bandwidthMeter);
        TrackSelector trackSelector = new DefaultTrackSelector(videoTrackSelectionFactory);
        mPlayer = ExoPlayerFactory.newSimpleInstance(context, trackSelector);
    }

    private void initVideoSource(Context context, String url) {
        DataSource.Factory dataSourceFactory = new DefaultDataSourceFactory(context, Util.getUserAgent(context, context.getPackageName()));
        Uri uri = Uri.parse(url);
        MediaSource source;
        if (url.endsWith(".m3u8")) {
            source = new HlsMediaSource.Factory(dataSourceFactory).createMediaSource(uri);
        } else {
            source = new ExtractorMediaSource.Factory(dataSourceFactory).createMediaSource(uri);
        }
        mPlayer.setPlayWhenReady(false);
        mPlayer.prepare(source);
    }

    public void release() {
        if (mPlayer != null) {
            mPlayer.release();
        }
    }

    @Override
    public void start() {
        mPlayer.setPlayWhenReady(true);
    }

    @Override
    public void pause() {
        mPlayer.setPlayWhenReady(false);
    }

    @Override
    public void seekTo(long positionMs) {
        mPlayer.seekTo(positionMs);
    }

    @Override
    public void stop() {
        mPlayer.stop();
    }

    @TimelineState
    @Override
    public int getState() {
        switch (mPlayer.getPlaybackState()) {
            case Player.STATE_IDLE:
                return TimelineState.STATE_IDLE;
            case Player.STATE_BUFFERING:
                return TimelineState.STATE_BUFFERING;
            case Player.STATE_READY:
                return mPlayer.getPlayWhenReady() ? TimelineState.STATE_START : TimelineState.STATE_PAUSE;
            case Player.STATE_ENDED:
                return TimelineState.STATE_STOP;
        }
        return TimelineState.STATE_IDLE;
    }
}
