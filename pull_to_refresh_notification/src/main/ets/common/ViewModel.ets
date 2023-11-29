import { PullToRefreshIndicatorMode, RefreshCallback } from './RefreshConstants';
import animator, { AnimatorOptions, AnimatorResult } from '@ohos.animator';


namespace pull_to_refresh_notification {
  export class ViewModel {
    /// The current drag offset
    dragOffset: number = 0;
    /// The current pull mode
    mode: PullToRefreshIndicatorMode = PullToRefreshIndicatorMode.initial;
    /// public begin
    /// The max drag offset
    maxDragOffset?: number;
    /// The offset to be dragged far enough that an up event will run the onRefresh callback.
    reachToRefreshOffset?: number;
    /// The offset to keep when it is refreshing
    refreshOffset?: number;
    /// Whether start pull back animation when refresh.
    pullBackOnRefresh: boolean = false;
    /// The options of pull back animation
    pullBackAnimatorOptions: AnimatorOptions = {
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
    pullBackOnError: boolean = false;
    /// public end

    /// The animatorResult
    ///
    animatorResult: AnimatorResult | null = null;
    /// The children should not join HitTest when start to pull to refresh
    hitTest: HitTestMode = HitTestMode.Default;
    /// A function that's called when the user has dragged the refresh indicator
    /// far enough to demonstrate that they want the app to refresh. The returned
    /// [Future] must complete when the refresh operation is finished.
    onRefresh: RefreshCallback = async () => true;

    /// Set the default value of [maxDragOffset,reachToRefreshOffset]
    onAreaChange(oldValue: Area, newValue: Area) {
      if (this.maxDragOffset == undefined) {
        this.maxDragOffset = (newValue.height as number) / 5;
      }
      if (this.reachToRefreshOffset == undefined) {
        this.reachToRefreshOffset = this.maxDragOffset * 3 / 4;
      }
      else {
        this.reachToRefreshOffset = Math.min(this.reachToRefreshOffset, this.maxDragOffset);
      }
    }

    onActionStart(event?: GestureEvent) {
      if (this.mode == PullToRefreshIndicatorMode.initial) {
        this.onInnerNoticed(PullToRefreshIndicatorMode.drag, 0);
        this.hitTest = HitTestMode.None;
      }
    }

    onActionUpdate(event: GestureEvent, onReachEdge: () => boolean) {
      if (!event || this.animatorResult != null || this.mode == PullToRefreshIndicatorMode.error) {
        return;
      }
      let offsetY = event.offsetY;
      if (offsetY > 0 && onReachEdge()) {
        offsetY = Math.min(this.maxDragOffset, offsetY);
        if (this.dragOffset == offsetY) {
          return;
        }
        this.onInnerNoticed(offsetY >= this.reachToRefreshOffset ? PullToRefreshIndicatorMode.armed : PullToRefreshIndicatorMode.drag, offsetY);
      }
    }

    async onActionEnd(event: GestureEvent, onRefresh: RefreshCallback): Promise<void> {
      if (!event || this.mode == PullToRefreshIndicatorMode.error) {
        return;
      }
      let offsetY = this.dragOffset;
      let isReadyToRefresh = offsetY > this.reachToRefreshOffset;
      if (!isReadyToRefresh) {
        this.pullBack(offsetY, 0, this.pullBackAnimatorOptions.duration, () => PullToRefreshIndicatorMode.drag);
        return;
      }

      if (this.refreshOffset != undefined && isReadyToRefresh) {
        let refreshOffset = Math.min(this.refreshOffset, this.reachToRefreshOffset);
        await this.pullBack(offsetY, refreshOffset, this.pullBackAnimatorOptions.duration * (offsetY - refreshOffset) / offsetY, () => PullToRefreshIndicatorMode.snap);
      }

      this.refresh();
    }

    onActionCancel(event: GestureEvent) {
      if (!event) {
        return;
      }

      this.onInnerNoticed(PullToRefreshIndicatorMode.initial, 0);
      this.hitTest = HitTestMode.Default;
      if (this.animatorResult != null) {
        this.animatorResult.finish();
        this.animatorResult = null;
      }
    }

    private onInnerNoticed(mode: PullToRefreshIndicatorMode, dragOffset: number) {
      this.mode = mode;
      this.dragOffset = dragOffset;
    }

    refresh() {
      this.onInnerNoticed(PullToRefreshIndicatorMode.refresh, this.dragOffset);
      if (this.pullBackOnRefresh) {
        let mode = PullToRefreshIndicatorMode.refresh;
        this.pullBack(this.dragOffset, 0, this.pullBackAnimatorOptions.duration, () => mode);
        this.onRefresh().then((value) => {
          if (value) {
            mode = PullToRefreshIndicatorMode.done;
          }
          else {
            mode = PullToRefreshIndicatorMode.error;
          }
          if (this.mode != mode) {
            this.onInnerNoticed(mode, this.dragOffset);
          }
        });
      }
      else {
        this.onRefresh().then((value) => {
          if (value) {
            this.pullBack(this.dragOffset, 0, this.pullBackAnimatorOptions.duration, () => PullToRefreshIndicatorMode.done);
          }
          else {
            if (this.pullBackOnError) {
              this.pullBack(this.dragOffset, 0, this.pullBackAnimatorOptions.duration, () => PullToRefreshIndicatorMode.error);
            }
            else {
              this.onInnerNoticed(PullToRefreshIndicatorMode.error, this.dragOffset);
            }

          }
        });
      }
    }


    private pullBack(begin: number, end: number, duration: number, getCurrentMode: () => PullToRefreshIndicatorMode): Promise<void> {
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
        this.animatorResult.onfinish = () => {
          if (end == 0) {
            this.onInnerNoticed(PullToRefreshIndicatorMode.initial, 0);
            this.hitTest = HitTestMode.Default;
          }
          this.animatorResult = null;
          resolve();
        };
      });
    }

    aboutToDisappear() {
      if (this.animatorResult != null) {
        this.animatorResult.finish();
        this.animatorResult = null;
      }
    }
  }
}

export default pull_to_refresh_notification;