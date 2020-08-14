import React from 'react';
import { Tooltip } from '@material-ui/core';
import {t} from '@/i18n';
import {roomStore} from '@/stores/room';

export type ScaleControllerProps = {
  zoomScale: number
  zoomChange: (scale: number) => void
  onClick: () => void
  onClickBoardLock: () => void
};

export default class ScaleController extends React.Component<ScaleControllerProps, {}> {

  private static readonly syncDuration: number = 200;

  private static readonly dividingRule: ReadonlyArray<number> = Object.freeze(
      [
          0.10737418240000011,
          0.13421772800000012,
          0.16777216000000014,
          0.20971520000000016,
          0.26214400000000015,
          0.3276800000000002,
          0.4096000000000002,
          0.5120000000000001,
          0.6400000000000001,
          0.8,
          1,
          1.26,
          1.5876000000000001,
          2.000376,
          2.5204737600000002,
          3.1757969376000004,
          4.001504141376,
          5.041895218133761,
          6.352787974848539,
          8.00451284830916,
          10,
      ],
  );

  private tempRuleIndex?: number;
  private syncRuleIndexTimer: any = null;

  public constructor(props: ScaleControllerProps) {
      super(props);
  }

  private delaySyncRuleIndex(): void {
      if (this.syncRuleIndexTimer !== null) {
          clearTimeout(this.syncRuleIndexTimer);
          this.syncRuleIndexTimer = null;
      }
      this.syncRuleIndexTimer = setTimeout(() => {
          this.syncRuleIndexTimer = null;
          this.tempRuleIndex = undefined;

      }, ScaleController.syncDuration);
  }

  private static readRuleIndexByScale(scale: number): number {
      const {dividingRule} = ScaleController;

      if (scale < dividingRule[0]) {
          return 0;
      }
      for (let i = 0; i < dividingRule.length; ++i) {
          const prePoint = dividingRule[i - 1];
          const point = dividingRule[i];
          const nextPoint = dividingRule[i + 1];

          const begin = prePoint === undefined ? Number.MIN_SAFE_INTEGER : (prePoint + point) / 2;
          const end = nextPoint === undefined ? Number.MAX_SAFE_INTEGER : (nextPoint + point) / 2;

          if (scale >= begin && scale <= end) {
              return i;
          }
      }
      return dividingRule.length - 1;
  }

  private moveTo100(): void {
      this.tempRuleIndex = ScaleController.readRuleIndexByScale(1);
      this.delaySyncRuleIndex();
      this.props.zoomChange(1);
  }


  private moveRuleIndex(deltaIndex: number): void {

      if (this.tempRuleIndex === undefined) {
          this.tempRuleIndex = ScaleController.readRuleIndexByScale(this.props.zoomScale);
      }
      this.tempRuleIndex += deltaIndex;

      if (this.tempRuleIndex > ScaleController.dividingRule.length - 1) {
          this.tempRuleIndex = ScaleController.dividingRule.length - 1;

      } else if (this.tempRuleIndex < 0) {
          this.tempRuleIndex = 0;
      }
      const targetScale = ScaleController.dividingRule[this.tempRuleIndex];

      this.delaySyncRuleIndex();
      this.props.zoomChange(targetScale);
  }

  public render(): React.ReactNode {
      return (
        <div className="zoom-controls">
          <Tooltip title={t("zoom_control.folder")} placement="top">
            <div className="zoom-icon" onClick={() => this.props.onClick()}>
            </div>
          </Tooltip>
          <div className="zoom-hold"></div>
          <div className="zoom-size">{Math.ceil(this.props.zoomScale * 100)} %</div>
          <div className="zoom-items">
            <div className="item zoom-in" onClick={() => this.moveRuleIndex(-1)}>-</div>
            <div className="item zoom-out" onClick={() => this.moveRuleIndex(+1)}>+</div>
          </div>
          <Tooltip title={!roomStore.state.course.lockBoard ? t("zoom_control.lock_board") : t("zoom_control.unlock_board")} placement="top">
            <div className="lock-board" onClick={() => this.props.onClickBoardLock() }></div>
          </Tooltip>
        </div>
      );
  }
}