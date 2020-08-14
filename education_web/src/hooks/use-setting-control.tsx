import { usePlatform } from '../containers/platform-container';
import React, { useState, useEffect, useMemo, useRef, useCallback } from 'react';
import VoiceVolume from '../components/volume/voice';
import {AgoraWebClient} from '../utils/agora-web-client';
import { AgoraElectronClient } from '../utils/agora-electron-client';
import VideoPlayer from '../components/video-player';
import { useRoomState } from '../containers/root-container';
import { roomStore, MediaDeviceState } from '../stores/room';

export default function useSettingControl () {

  const [devices, setDevices] = useState<any[]>([]);

  const {platform} = usePlatform();

  const cameraList = useMemo(() => {
    return devices
    .filter((it: Device) => 
      it.kind === 'videoinput');
  }, [devices]);

  const microphoneList = useMemo(() => {
    return devices
    .filter((it: Device) => 
      it.kind === 'audioinput');
  }, [devices]);

  const speakerList = useMemo(() => {
    return devices
    .filter((it: Device) => 
      it.kind === 'audiooutput');
  }, [devices]);

  const roomState = useRoomState();

  const mediaDevice = useMemo(() => {
    return roomState.mediaDevice;
  }, [roomState.mediaDevice]);

  const [camera, setCamera] = useState(mediaDevice.camera);
  const [microphone, setMicrophone] = useState(mediaDevice.microphone);
  const [speaker, setSpeaker] = useState(mediaDevice.speaker);
  const [speakerVolume, setSpeakerVolume] = useState<number>(mediaDevice.speakerVolume);
  const [volume, setVolume] = useState<number>(0);

  let mounted = false;

  useEffect(() => {
    const rtcClient: AgoraWebClient | AgoraElectronClient = roomStore.rtcClient;
    if (!platform || !rtcClient) return;

    if (platform === 'web' && !mounted) {
      const webClient = rtcClient as AgoraWebClient;
      const onChange = async () => {
        const devices: Device[] = await webClient.getDevices();
        setDevices(devices.map((item: Device) => ({
          value: item.deviceId,
          text: item.label,
          kind: item.kind
        })));
      }
      window.addEventListener('devicechange', onChange);
      onChange().then(() => {
      }).catch(console.warn);
      mounted = true;
      return () => {
        window.removeEventListener('devicechange', onChange);
      }
    }

    if (platform === 'electron' && !mounted) {
      const nativeClient = rtcClient as AgoraElectronClient;

      const onChange = async () => {
        let microphoneIds = await nativeClient.rtcEngine.getAudioRecordingDevices();
        let speakerIds = await nativeClient.rtcEngine.getAudioPlaybackDevices();
        let cameraIds = await nativeClient.rtcEngine.getVideoDevices();

        const microphones = microphoneIds.map((it: any) => (
          {
            kind: 'audioinput',
            text: it.devicename,
            value: it.deviceid
          }
        ));
        const speakers = speakerIds.map((it: any) => ({
          kind: 'audiooutput',
          text: it.devicename,
          value: it.deviceid,
        }));
        const cameras = cameraIds.map((it: any) => ({
          kind: 'videoinput',
          text: it.devicename,
          value: it.deviceid,
        }));
        setDevices([].concat(microphones).concat(speakers).concat(cameras));
      }
      onChange().then(() => console.log('electron devices changed'))
        .catch(console.warn);

      nativeClient.on('videodevicestatechanged', onChange);
      nativeClient.on('audiodevicestatechanged', onChange);
      mounted = true;
      return () => {
        nativeClient.off('videodevicestatechanged', onChange);
        nativeClient.off('audiodevicestatechanged', onChange);
      }
    }
  }, [platform]);

  const cameraId: string = useMemo(() => {
    return cameraList[camera] ? cameraList[camera].value : '';
  }, [cameraList, camera]);

  const microphoneId: string = useMemo(() => {
    return microphoneList[microphone] ? microphoneList[microphone].value : '';
  }, [microphoneList, microphone]);

  const speakerId: string = useMemo(() => {
    return speakerList[speaker] ? speakerList[speaker].value : '';
  }, [speakerList, speaker]);

  const [stream, setStream] = useState<any>(null);

  const ref = useRef<boolean>(false);

  useEffect(() => {
    return () => {
      ref.current = true;
    }
  }, []);

  const lock = useRef<boolean>(false);

  useEffect(() => {
    return () => {
      lock.current = true;
    }
  }, []);
  useEffect(() => {
    if (lock.current || !speakerId || !cameraId || !microphoneId) return;
    const rtcClient: AgoraWebClient | AgoraElectronClient = roomStore.rtcClient;
    lock.current = true;
    if (platform === 'web') {
      const webClient = rtcClient as AgoraWebClient;
      !ref.current &&
      webClient.createPreviewStream({
        cameraId,
        microphoneId,
        speakerId,
      }).then((stream: any) => {
        !ref.current && setStream(stream);
      }).finally(() => {
        lock.current = false;
      })
    }

    if (platform === 'electron') {
      const nativeClient = rtcClient as AgoraElectronClient;
      const stream = nativeClient.createStream({
        streamID: 0,
        cameraId,
        microphoneId,
        speakerId,
      })
      setStream(stream);
      lock.current = false;
    }
  }, [platform, speakerId, cameraId, microphoneId]);

  const interval = useRef<any>(null);

  useEffect(() => {
    if (!stream || !stream.getAudioLevel) return;
    interval.current = setInterval(() => {
      !ref.current && setVolume(stream.getAudioLevel())
    }, 300);
    return () => {
      interval.current && clearInterval(interval.current);
      interval.current = null;
    }
  }, [stream]);

  useEffect(() => {
    if (!stream) return;
    if (platform === 'electron') {
      console.log("[electron-client] add volume event listener");
      const onVolumeChange = (speakers: any[], speakerNumber: number, totalVolume: number)=> {
        setVolume(Number((totalVolume / 255).toFixed(3)))
      }
      const rtcClient: AgoraWebClient | AgoraElectronClient = roomStore.rtcClient;
      const nativeClient = rtcClient as AgoraElectronClient;
      nativeClient.rtcEngine.setClientRole(1);
      const res = nativeClient.rtcEngine.enableAudioVolumeIndication(1000, 3, true);
      console.log("enableAudioVolumeIndication(1000, 3, true), ", res)
      nativeClient.rtcEngine.on('groupAudioVolumeIndication', onVolumeChange);
      console.log('startplayback on result', nativeClient.rtcEngine.startAudioRecordingDeviceTest(300));
      return () => {
        nativeClient.rtcEngine.off("groupAudioVolumeIndication", onVolumeChange);
        console.log('startplayback off result', nativeClient.rtcEngine.stopAudioPlaybackDeviceTest());
      }
    }
  }, [stream]);

  const PreviewPlayer = useCallback(() => {
    if (!stream) return null;
    return (
      <VideoPlayer
        domId={"local"}
        preview={true}
        stream={stream}
        streamID={0}
        video={true}
        audio={true}
        local={true}
      />
    )

  }, [stream]);

  const MicrophoneVolume = useCallback(() => {
    return (<VoiceVolume volume={volume}/>)
  }, [volume]);

  const handleSave = (args: {camera: number, microphone: number, speaker: number, speakerVolume: number}) => {
    const { camera, microphone, speaker, speakerVolume } = args;
    const cameraId = cameraList[camera] ? cameraList[camera].value : '';
    const microphoneId = microphoneList[microphone] ? microphoneList[microphone].value : '';
    const speakerId = speakerList[speaker] ? speakerList[speaker].value : '';
    const mediaInfo: MediaDeviceState = {
      cameraId,
      microphoneId,
      speakerId,
      camera,
      microphone,
      speaker,
      speakerVolume,
    }
    ref.current = true;
    roomStore.updateDevice(mediaInfo);
    if (stream && stream.close) {
      stream.close();
    }
  }

  return {
    volume,
    cameraList,
    microphoneList,
    speakerList,
    camera,
    microphone,
    speaker,
    setCamera,
    setMicrophone,
    setSpeaker,
    speakerVolume,
    setSpeakerVolume,
    PreviewPlayer,
    MicrophoneVolume,
    save: handleSave,
  }
}
