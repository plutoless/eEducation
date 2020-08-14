import React, { useMemo, useEffect, useState, useRef, useCallback } from 'react';
import Whiteboard from './whiteboard';
import VideoPlayer from '../components/video-player';
import Control from './whiteboard/control';
import { AgoraStream } from '../utils/types';
import useStream from '../hooks/use-streams';
import { useLocation } from 'react-router';
import Tools from './whiteboard/tools';
import { SketchPicker, RGBColor } from 'react-color';
import { AgoraElectronClient } from '../utils/agora-electron-client';
import { UploadBtn } from './whiteboard/upload/upload-btn';
import { ResourcesMenu } from './whiteboard/resources-menu';
import ScaleController from './whiteboard/scale-controller';
import { PPTProgressPhase } from '../utils/upload-manager';
import { UploadNoticeView } from '../components/whiteboard/upload/upload-notice';
import Progress from '../components/progress/progress';
import { useRoomState, useWhiteboardState, useGlobalState } from '../containers/root-container';
import { roomStore } from '../stores/room';
import { whiteboard } from '../stores/whiteboard';
import { globalStore } from '../stores/global';
import { platform } from '../utils/platform';
import "white-web-sdk/style/index.css";
import { ViewMode } from 'white-web-sdk';
import { t } from '../i18n';
import { Collapse, Paper} from '@material-ui/core';

const pathName = (path: string): string => {
  const reg = /\/([^/]*)\//g;
  reg.exec(path);
  if (RegExp.$1 === "aria") {
      return "";
  } else {
      return RegExp.$1;
  }
}

interface MediaBoardProps {
  handleClick?: (type: string) => void
  children?: any
}

const MediaBoard: React.FC<MediaBoardProps> = ({
  handleClick,
  children
}) => {

  const location = useLocation()

  const roomState = useRoomState();

  const whiteboardState = useWhiteboardState();
  
  const role = roomState.me.role;
  const room = whiteboardState.room;
  const me = roomState.me;
  const course = roomState.course;
  const rtmState = roomState.rtm;
  
  const ref = useRef<any>(false);

  const [pageTool, setPageTool] = useState<string>('');

  const {sharedStream} = useStream();

  const handlePageTool: any = (evt: any, type: string) => {
    setPageTool(type);
    console.log("[page-tool] click ", type);
    if (type === 'first_page') {
      changePage(1, true);
    }

    if (type === 'last_page') {
      changePage(totalPage, true);
    }

    if (type === 'prev_page') {
      changePage(currentPage-1);
    }

    if (type === 'next_page') {
      changePage(currentPage+1);
    }

    if (type === 'peer_hands_up') {
      globalStore.showDialog({
        type: 'apply',
        message: `${globalStore.state.notice.text}`,
      })
      setPageTool('');
    }

    if (handleClick) {
      handleClick(type);
    }
  }

  const studentIsHost = useMemo(() => {
    if (
      location.pathname.match(/big-class/) 
      && me.role === 2 && me.coVideo) {
      return true
    }
    return false
  }, [me.role, me.coVideo, location])

  
  const current = useMemo(() => {
    return {
      totalPage: whiteboardState.totalPage,
      currentPage: whiteboardState.currentPage,
      type: whiteboardState.type
    }
  }, [whiteboardState.currentPage, whiteboardState.totalPage, whiteboardState.type]);

  const totalPage = useMemo(() => {
    if (!current) return 0;
    return current.totalPage;
  }, [current]);

  const currentPage = useMemo(() => {
    if (!current) return 0;
    return current.currentPage + 1;
  }, [current]);

  const addNewPage: any = (evt: any) => {
    if (!current || !room) return;
    // const newIndex = netlessClient.state.sceneState.scenes.length;
    const newIndex = room.state.sceneState.index + 1;
    const scenePath = room.state.sceneState.scenePath;
    const currentPath = `/${pathName(scenePath)}`;
    if (room.isWritable) {
      room.putScenes(currentPath, [{}], newIndex);
      room.setSceneIndex(newIndex);
    }

    whiteboard.updateRoomState();
  }

  const changePage = (idx: number, force?: boolean) => {
    if (ref.current || !current || !room || !room.isWritable) return;
    const _idx = idx -1;
    if (_idx < 0 || _idx >= current.totalPage) return;
    if (force) {
      room.setSceneIndex(_idx);
      whiteboard.updateRoomState();
      return
    }
    if (current.type === 'dynamic') {
      if (_idx > current.currentPage) {
        room.pptNextStep();
        console.log("room.pptNextStep");
      } else {
        room.pptPreviousStep();
        console.log("room.pptPreviousStep");
      }
    } else {
      room.setSceneIndex(_idx);
      console.log("room.setSceneIndex", _idx);
    }
    whiteboard.updateRoomState();
  }

  const showControl: boolean = useMemo(() => {
    if (+me.role === 1) return true;
    if (location.pathname.match(/big-class/)) {
      if (+me.role === 2) {
        return true;
      }
    }
    return false;
  }, []);

const items = [
  {
    name: 'selector'
  },
  {
    name: 'pencil'
  },
  {
    name: 'rectangle',
  },
  {
    name: 'ellipse'
  },
  {
    name: 'text'
  },
  {
    name: 'eraser'
  },
  {
    name: 'color_picker'
  },
  {
    name: 'add'
  },
  {
    name: 'upload'
  },
  {
    name: 'hand_tool'
  }
];

  const toolItems = useMemo(() => {
    return items.filter((item: any) => {
      if (+role === 1) return item;
      if (['add', 'folder', 'upload'].indexOf(item.name) === -1) {
        if (item.name === 'hand_tool') {
          if (course.lockBoard) {
            return false;
          } else {
            return true;
          }
        }
        return item;
      }
    });
  }, [course.lockBoard]);

  const drawable: string = useMemo(() => {
    if (location.pathname.match('small-class|big-class')) {
      if (+me.role === 1) {
        return 'drawable';
      }
      if (+me.role === 2) {
        if (Boolean(me.grantBoard)) {
          return 'drawable';
        } else {
          return 'panel';
        }
      }
    }
    return 'drawable';
  }, [me.role, me.grantBoard, location]);

  const [tool, setTool] = useState<string | any>(drawable === 'drawable' ? 'pencil' : '');
  
  const [selector, updateSelector] = useState<string>('');

  const handleToolClick = (evt: any, name: string) => {
    if (!room || !room.isWritable) return;
    if (['upload', 'color_picker', 'hand_tool'].indexOf(name) !== -1 && name === tool) {
      setTool('');
      if (name === 'hand_tool') {
        room.handToolActive = false;
        updateSelector('');
      }
      return;
    }
    if (name !== 'hand_tool') {
      room.handToolActive = false;
      updateSelector('');
    }
    setTool(name);
    if (name === 'upload'
      || name === 'folder'
      || name === 'color_picker'
      || name === 'add'
      || name === 'hand_tool'
    ) {
      if (name === 'hand_tool') {
        room.handToolActive = true;
        updateSelector('hand');
        room.setMemberState({currentApplianceName: 'selector'});
      } else {
        if (name === 'add' && addNewPage) {
          addNewPage();
        }
      }
      return;
    }
    room.setMemberState({currentApplianceName: name});
  }

  const onColorChanged = (color: any) => {
    if (!room || !room.isWritable) return;
    const {rgb} = color;
    const {r, g, b} = rgb;
    room.setMemberState({
      strokeColor: [r, g, b]
    });
  }

  const lock = useRef<boolean>(false);

  useEffect(() => {
    return () => {
      lock.current = true;
      whiteboard.destroy()
      .then(() => {
        console.log("destroy whiteboard");
      }).catch(console.warn);
    }
  }, []);

  useEffect(() => {
    if (!rtmState.joined) return;
    if (!lock.current && !whiteboard.state.room) {
      lock.current = true;
      whiteboard.join({
        rid: roomStore.state.course.rid,
        uuid: course.boardId,
        roomToken: course.boardToken,
        location: location.pathname,
        userPayload: {
          userId: roomStore.state.me.uid,
          identity: +roomStore.state.me.role === 1 ? 'host' : 'guest'
        }
      })
      .then(() => {
        console.log("join whiteboard success");
      }).catch((err: any) => {
        console.warn(err)
      })
      .finally(() => {
        lock.current = false;
      })
    }

  }, [JSON.stringify([rtmState.joined, course.boardId, course.boardToken])]);

  const [uploadPhase, updateUploadPhase] = useState<string>('');
  const [convertPhase, updateConvertPhase] = useState<string>('');

  useEffect(() => {
    console.log("uploading [mediaboard] uploadPhase: ", uploadPhase, " convertPhase: ", convertPhase);
  }, [uploadPhase, convertPhase]);

  const UploadPanel = useCallback(() => {
    if (tool !== 'upload' || !room) return null;
    return (<UploadBtn 
      room={room}
      uuid={room.uuid}
      roomToken={room.roomToken}
      didUpload={() => {
        setTool('')
      }}
      onProgress={(phase: PPTProgressPhase, percent: number) => {
        console.log("uploading [onProgress] phase: ", phase, " percent: ", percent, "uploadPhase: ", uploadPhase, "convertPhase: ", convertPhase);
        if (phase === PPTProgressPhase.Uploading) {
          if (percent < 1) {
            uploadPhase !== 'uploading' && updateUploadPhase('uploading');
          } else {
            updateUploadPhase('upload_success');
          }
          return;
        }

        if (phase === PPTProgressPhase.Converting) {
          if (percent < 1) {
            convertPhase !== 'converting' && updateConvertPhase('converting');
          } else {
            updateConvertPhase('convert_success');
          }
          return;
        }
      }}
      onSuccess={() => {
        uploadPhase && updateUploadPhase('');
        updateConvertPhase && updateConvertPhase('');
        console.log("uploading [onSuccess]", uploadPhase, convertPhase);
      }}
      onFailure={(err: any) => {
        // WARN: capture exception
        if (uploadPhase === 'uploading') {
          updateUploadPhase('upload_failure');
          return;
        }
        if (convertPhase === 'converting') {
          updateConvertPhase('convert_failure');
          return;
        }
      }}
    />)
  }, [tool, room]);

  useEffect(() => {
    if (uploadPhase === 'upload_success') {
      globalStore.showUploadNotice({
        title: t('room.upload_success'),
        type: 'ok',
      });
    }
    if (uploadPhase === 'convert_failure') {
      globalStore.showUploadNotice({
        title: t('room.upload_failure'),
        type: 'error',
      });
    }
  }, [uploadPhase]);

  useEffect(() => {
    if (convertPhase === 'convert_success') {
      globalStore.showUploadNotice({
        title: t('room.convert_success'),
        type: 'ok',
      });
    }
    if (convertPhase === 'convert_failure') {
      globalStore.showUploadNotice({
        title: t('room.convert_failure'),
        type: 'error',
      });
    }
  }, [convertPhase]);

  useMemo(() => {
    if (+roomState.me.role === 2 && +roomState.course.lockBoard === 1) {
      globalStore.showToast({
        type: "whiteboard",
        message: t("whiteboard.locked_board")
      })
    }
  }, [roomState.course.lockBoard, roomState.me.role])

  useEffect(() => {
    if (!me.role || !room) return;
    if (+me.role === 1) {
      if (roomStore.state.course.lockBoard) {
        room.setViewMode(ViewMode.Broadcaster);
      } else {
        room.setViewMode(ViewMode.Freedom);
      }
    }
    if (+me.role === 2) {
      if (roomStore.state.course.lockBoard) {
        room.handToolActive = false;
        room.disableCameraTransform = true;
        room.disableDeviceInputs = true;
      } else {
        room.disableCameraTransform = false;
        room.disableDeviceInputs = false;
      }
    }
  }, [room, roomStore.state.course.lockBoard, roomStore.state.me.role]);

  const globalState = useGlobalState();

  const scale = whiteboardState.scale ? whiteboardState.scale : 1;

  const UploadProgressView = useCallback(() => {
    if (uploadPhase === 'uploading') {
      return (
        <Progress title={t("room.uploading")} />
      )
    } else 
    if (convertPhase === 'converting') {
      return (
        <Progress title={t("room.converting")} />
      )
    }
    return null;
  }, [uploadPhase, convertPhase]);

  let strokeColor: RGBColor | undefined = undefined;

  if (whiteboardState.room && whiteboardState.room.state.memberState.strokeColor) {
    const color = whiteboardState.room.state.memberState.strokeColor;
    strokeColor = {
      r: color[0],
      g: color[1],
      b: color[2],
    }
  }

  // useEffect(() => {
  //   if (!room) return;
  //   if (drawable === 'panel') {
  //     room.disableDeviceInputs = true;
  //     room.disableCameraTransform = true;
  //     return;
  //   }
  //   room.disableDeviceInputs = false;
  //   room.disableCameraTransform = false;
  // }, [drawable, room]);

  const showTools = drawable === 'drawable';
  
  return (
    <div className={`media-board ${drawable}`}>
      {sharedStream ? 
        <VideoPlayer
          id={`${sharedStream.streamID}`}
          domId={`shared-${sharedStream.streamID}`}
          className={'screen-sharing'}
          streamID={sharedStream.streamID}
          stream={sharedStream.stream}
          video={true}
          audio={true}
          local={sharedStream.local}
        />
        :
        <Whiteboard
          loading={whiteboardState.loading}
          className={selector}
          room={room}
        />
      }
      <div className="layer">
        {!sharedStream ? 
        <>
          {showTools ? <Tools
          items={toolItems}
          currentTool={tool}
          handleToolClick={handleToolClick} /> : null}
          {tool === 'color_picker' && strokeColor ?
            <SketchPicker
              color={strokeColor}
              onChangeComplete={onColorChanged} />
          : null}
        </> : null}
        <UploadPanel />
        {children ? children : null}
      </div>
      {me.role === 1 && room ?
        <ScaleController
          zoomScale={scale}
          onClick={() => {
            setTool('folder');
          }}
          onClickBoardLock={() => {
            whiteboard.lock()
              .then(console.log)
              .catch(console.warn);
          }}
          zoomChange={(scale: number) => {
            room.moveCamera({scale});
            whiteboard.updateScale(scale);
          }}
        />
        :
        null
      }
      { showControl ?
      <Control
        notice={globalState.notice}
        role={role}
        sharing={Boolean(sharedStream)}
        current={pageTool}
        currentPage={currentPage}
        totalPage={totalPage}
        isHost={studentIsHost}
        onClick={handlePageTool}/> : null }
        {tool === 'folder' && whiteboardState.room ? 
        <ResourcesMenu
          activeScenePath={whiteboardState.currentScenePath}
          items={whiteboardState.dirs}
          onClick={(rootPath: string) => {
            if (room) {
              room.setScenePath(rootPath);
              room.setSceneIndex(0);
              whiteboard.updateRoomState();
            }
          }}
          onClose={(evt: any) => {
            setTool('')
          }}
        />
        : null}
      <UploadNoticeView />
      <UploadProgressView />
    </div>
  )
} 

export default React.memo(MediaBoard);