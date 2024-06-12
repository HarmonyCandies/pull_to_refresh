import { PullToRefreshIndicatorMode, RefreshCallback } from '../common/RefreshConstants';

import pull_to_refresh from '../common/Controller';
import animator, { AnimatorOptions, AnimatorResult, } from '@ohos.animator';

@Component
export struct PullToRefresh {
  /// The children
  @BuilderParam
  builder: () => void;
  /// A function that's called when the user has dragged the refresh indicator
  /// far enough to demonstrate that they want the app to refresh. The returned
  /// [Future] must complete when the refresh operation is finished.
  onRefresh: RefreshCallback = async () => true;
  /// Whether we reach the edge to pull refresh
  onReachEdge: () => boolean = () => true;
  @Link controller: pull_to_refresh.Controller;
  /// The max drag offset
  @Prop maxDragOffset: number | undefined = undefined;
  /// The offset to be dragged far enough that an up event will run the onRefresh callback.
  @Prop reachToRefreshOffset: number | undefined = undefined;
  /// The offset to keep when it is refreshing
  @Prop refreshOffset: number | undefined = undefined;
  /// Whether start pull back animation when refresh.
  @Prop pullBackOnRefresh: boolean = false;
  /// The options of pull back animation
  @Prop pullBackAnimatorOptions: AnimatorOptions = {
    duration: 400,
    easing: "friction",
    delay: 0,
    fill: "forwards",
    direction: "normal",
    iterations: 1,
    begin: 1.0,
    end: 0.0
  };
  /// Whether start pull back animation when refresh failed.
  @Prop pullBackOnError: boolean = false;
  /// The animatorResult
  ///
  animatorResult: AnimatorResult | undefined = undefined;

  aboutToAppear() {
    this.controller.onRefresh = () => {
      this.refresh();
    };
  }

  aboutToDisappear() {
    if (this.animatorResult != undefined) {
      this.animatorResult.finish();
      this.animatorResult = undefined;
    }
  }

  build() {
    Column() {
      this.builder()
    }.onAreaChange((oldValue: Area, newValue: Area) => {
      if (this.maxDragOffset == undefined) {
        this.maxDragOffset = (newValue.height as number) / 5;
      }
      if (this.reachToRefreshOffset == undefined) {
        this.reachToRefreshOffset = this.maxDragOffset * 3 / 4;
      } else {
        this.reachToRefreshOffset = Math.min(this.reachToRefreshOffset, this.maxDragOffset);
      }
    })
    .parallelGesture(PanGesture({
      direction: PanDirection.Up | PanDirection.Down
    })
      .onActionStart((event?: GestureEvent) => {
        if (this.controller.mode == PullToRefreshIndicatorMode.initial) {
          this.onInnerNoticed(PullToRefreshIndicatorMode.drag, 0);
        }
      })
      .onActionUpdate(async (event?: GestureEvent) => {
        if (!event || this.animatorResult != undefined || this.controller.mode == PullToRefreshIndicatorMode.error) {
          return;
        }
        let offsetY = event.offsetY;
        if (offsetY > 0 && this.onReachEdge()) {
          offsetY = Math.min(this.maxDragOffset, offsetY);
          if (this.controller.dragOffset == offsetY) {
            return;
          }
          this.onInnerNoticed(offsetY >= this.reachToRefreshOffset! ? PullToRefreshIndicatorMode.armed :
          PullToRefreshIndicatorMode.drag, offsetY);
        }
      }).onActionEnd(async (event?: GestureEvent) => {
        if (!event || this.controller.mode == PullToRefreshIndicatorMode.error) {
          return;
        }
        let offsetY = this.controller.dragOffset;
        let isReadyToRefresh = offsetY > this.reachToRefreshOffset!;
        if (!isReadyToRefresh) {
          this.pullBack(offsetY, 0, this.pullBackAnimatorOptions.duration, () => PullToRefreshIndicatorMode.drag);
          return;
        }

        if (this.refreshOffset != undefined && isReadyToRefresh) {
          let refreshOffset = Math.min(this.refreshOffset, this.reachToRefreshOffset);
          await this.pullBack(offsetY, refreshOffset,
            this.pullBackAnimatorOptions.duration * (offsetY - refreshOffset) / offsetY,
            () => PullToRefreshIndicatorMode.snap);
        }
        this.refresh();
      }).onActionCancel((event?: GestureEvent) => {
        if (!event) {
          return;
        }

        this.onInnerNoticed(PullToRefreshIndicatorMode.initial, 0);
        if (this.animatorResult != undefined) {
          this.animatorResult.finish();
          this.animatorResult = undefined;
        }
      }))
  }

  private onInnerNoticed(mode: PullToRefreshIndicatorMode, dragOffset: number) {
    this.controller.mode = mode;
    this.controller.dragOffset = dragOffset;
  }

  refresh() {
    this.onInnerNoticed(PullToRefreshIndicatorMode.refresh, this.controller.dragOffset);
    if (this.pullBackOnRefresh) {
      let mode = PullToRefreshIndicatorMode.refresh;
      this.pullBack(this.controller.dragOffset, 0, this.pullBackAnimatorOptions.duration, () => mode);
      this.onRefresh().then((value) => {
        if (value) {
          mode = PullToRefreshIndicatorMode.done;
        } else {
          mode = PullToRefreshIndicatorMode.error;
        }
        if (this.controller.mode != mode) {
          this.onInnerNoticed(mode, this.controller.dragOffset);
        }
      });
    } else {
      this.onRefresh().then((value) => {
        if (value) {
          this.pullBack(this.controller.dragOffset, 0, this.pullBackAnimatorOptions.duration,
            () => PullToRefreshIndicatorMode.done);
        } else {
          if (this.pullBackOnError) {
            this.pullBack(this.controller.dragOffset, 0, this.pullBackAnimatorOptions.duration,
              () => PullToRefreshIndicatorMode.error);
          } else {
            this.onInnerNoticed(PullToRefreshIndicatorMode.error, this.controller.dragOffset);
          }

        }
      });
    }
  }

  private pullBack(begin: number, end: number, duration: number,
    getCurrentMode: () => PullToRefreshIndicatorMode): Promise<void> {
    let animatorOptions: AnimatorOptions = {
      duration: duration,
      easing: this.pullBackAnimatorOptions.easing,
      delay: this.pullBackAnimatorOptions.delay,
      fill: this.pullBackAnimatorOptions.fill,
      direction: "normal",
      iterations: 1,
      begin: begin,
      end: end
    };

    this.animatorResult = animator.create(animatorOptions);
    this.animatorResult.onframe = (progress
    ) => {
      let dragOffset = progress;
      this.onInnerNoticed(getCurrentMode(), dragOffset);
    }
    this.animatorResult.play();

    return new Promise<void>((resolve) => {
      if (this.animatorResult != null) {
        this.animatorResult!.onfinish = () => {
          if (end == 0) {
            this.onInnerNoticed(PullToRefreshIndicatorMode.initial, 0);
          }
          this.animatorResult = undefined;
          resolve();
        };
      }
    });
  }
}

