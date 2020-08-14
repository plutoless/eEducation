import React from 'react';
import VideoMarquee from '@/components/video-marquee';
import MediaBoard from '@/components/mediaboard';
import Roomboard from '@/components/roomboard';
import './small-class.scss';

export default function SmallClass() {
  return (
    <div className="room-container">
      <VideoMarquee />
      <div className="container">
        <MediaBoard />
        <Roomboard currentActive={'media'} />
      </div>
    </div>
  )
}