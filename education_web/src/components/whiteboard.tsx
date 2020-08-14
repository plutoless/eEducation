import React, {useEffect, useRef} from 'react';
import './whiteboard.scss';
import { Room } from 'white-web-sdk';
import { whiteboard } from '../stores/whiteboard';
import { t } from '../i18n';
import { Progress } from '../components/progress/progress';

interface WhiteBoardProps {
  room?: Room | null
  className: string
  loading: boolean
}

export default function Whiteboard ({
  room,
  className,
  loading
}: WhiteBoardProps) {

  const domRef = useRef(null);

  useEffect(() => {
    if (!room || !whiteboard.state.room || !domRef.current) return;
    room.bindHtmlElement(domRef.current);
    whiteboard.updateRoomState();
    window.addEventListener("resize", (evt: any) => {
      if (whiteboard.state.room !== null && whiteboard.state.room.isWritable) {
        whiteboard.state.room.moveCamera({centerX: 0, centerY: 0});
        whiteboard.state.room.refreshViewSize();           
      }
    });
    return () => {
      if (whiteboard.state.room) {
        whiteboard.state.room.bindHtmlElement(null);
      }
      window.removeEventListener("resize", (evt: any) => {});
    }
  }, [room, domRef]);

  return (
    <div className="whiteboard">
      { loading || !room ? <Progress title={t("whiteboard.loading")}></Progress> : null}
      <div ref={domRef} id="whiteboard" className={`whiteboard-canvas ${className}`}></div>
    </div>
  )
}