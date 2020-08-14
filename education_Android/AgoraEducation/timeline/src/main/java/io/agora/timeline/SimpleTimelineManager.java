package io.agora.timeline;

import java.util.ArrayList;
import java.util.List;

public class SimpleTimelineManager extends TimelineDecorator {
    private List<Timeline> timelineList;

    public SimpleTimelineManager(SimpleTimeline timeline) {
        super(timeline);
        timelineList = new ArrayList<>();
    }

    public void addTimeline(Timeline timeline) {
        timelineList.add(new TimelineDecorator(timeline) {
        });
    }

    @Override
    public void start() {
        for (Timeline timeline : timelineList) {
            if (timeline.getState() == TimelineState.STATE_BUFFERING) {
                return;
            }
        }
        super.start();
        for (Timeline timeline : timelineList) {
            timeline.start();
        }
    }

    @Override
    public void pause() {
        for (Timeline timeline : timelineList) {
            if (timeline.getState() == TimelineState.STATE_BUFFERING) {
                return;
            }
        }
        super.pause();
        for (Timeline timeline : timelineList) {
            timeline.pause();
        }
    }

    @Override
    public void seekTo(long positionMs) {
        for (Timeline timeline : timelineList) {
            if (timeline.getState() == TimelineState.STATE_BUFFERING) {
                return;
            }
        }
        super.seekTo(positionMs);
        for (Timeline timeline : timelineList) {
            timeline.seekTo(positionMs);
        }
    }

    @Override
    public void stop() {
        for (Timeline timeline : timelineList) {
            if (timeline.getState() == TimelineState.STATE_BUFFERING) {
                return;
            }
        }
        super.stop();
        for (Timeline timeline : timelineList) {
            timeline.stop();
        }
    }

    @TimelineState
    @Override
    public int getState() {
        return super.getState();
    }
}
