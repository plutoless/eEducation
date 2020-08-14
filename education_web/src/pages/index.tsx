import React from 'react';
import { Route } from 'react-router-dom';
import CustomBrowserRouter from '../containers/custom-browser-router';
import ThemeContainer from '../containers/theme-container';
import Home from './home';
import DeviceTest from './device-test';
import { RoomPage } from './classroom';
import Loading from '../components/loading';
import Toast from '../components/toast';
import '../icons.scss';
import { PlatformContainer } from '../containers/platform-container';
import ReplayContainer from './replay/replay';
import AgoraReplayContainer from './replay/agora-replay';
import { RootProvider } from '../containers/root-container';
import SmallClass from './classroom/small-class';
import OneToOne from './classroom/one-to-one';
import BigClass from './classroom/big-class';
import { PageNotFound } from './404';
import RoomDialog from '../components/dialog';
import { ReplayPageWrapper } from './replay';
import { ConfigPage } from './config';

export default function () {
  return (
    <ThemeContainer>
      <CustomBrowserRouter>
        <PlatformContainer>
        <RootProvider>
          <Loading />
          <Toast />
          <RoomDialog />
          <Route exact path="/device_test">
            <DeviceTest />
          </Route>
          <Route exact path="/classroom/one-to-one">
            <RoomPage >
              <OneToOne />
            </RoomPage>
          </Route>
          <Route exact path="/classroom/small-class">
            <RoomPage>
              <SmallClass />
            </RoomPage>
          </Route>
          <Route exact path="/classroom/big-class">
            <RoomPage>
              <BigClass />
            </RoomPage>
          </Route>
          <Route path="/replay/record/:recordId">
            <ReplayPageWrapper>
              <ReplayContainer />
            </ReplayPageWrapper>
          </Route>
          <Route path="/replay/agora_record/:recordId">
            <ReplayPageWrapper>
              <AgoraReplayContainer />
            </ReplayPageWrapper>
          </Route>
          <Route path="/config">
            <ConfigPage />
          </Route>
          <Route exact path="/">
            <Home />
          </Route>
          {/* <Route path="/error">
            <ErrorPage />
          </Route> */}
          <Route exact path="/404">
            <PageNotFound />
          </Route>
        </RootProvider>
        </PlatformContainer>
      </CustomBrowserRouter>
    </ThemeContainer>
  )
}
