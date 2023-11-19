import { PullToRefreshIndicatorMode, RefreshConstants } from '../common/RefreshConstants';
import { default as PullToRefresh } from '../common/ViewModel';
import animator, { AnimatorOptions, AnimatorResult } from '@ohos.animator';

@Component
export struct PullToRefreshNotification {
  // PullToRefreshNotification():PullToRefreshNotification;
  @BuilderParam
  private builder: () => CommonMethod<any>;
  /// The max drag offset
  maxDragOffset?: number;
  /// The offset to be dragged far enough that an up event will run the onRefresh callback.
  reachToRefreshOffset?: number;
  /// The offset to keep when it is refreshing
  refreshOffset?: number;
  /// ViewModel
  // viewModel: PullToRefresh.ViewModel;
  /// A function that's called when the user has dragged the refresh indicator
  /// far enough to demonstrate that they want the app to refresh. The returned
  /// [Future] must complete when the refresh operation is finished.
  onRefresh: () => Promise<boolean>;
  /// Whether start pull back animation when refresh.
  pullBackOnRefresh: boolean = false;
  /// The options of pull back animation
  pullBackAnimatorOptions: AnimatorOptions = {
    duration: 2000,
    easing: "friction",
    delay: 0,
    fill: "forwards",
    direction: "normal",
    iterations: 1,
    begin: 1.0,
    end: 0.0
  };
  onStateChanged: (mode: PullToRefreshIndicatorMode, dragOffset: number, hitTestMode: HitTestMode) => void;
  onReachEdge: () => boolean;
  /// The children should not join HitTest when start to pull to refresh
  @State private hitTest: HitTestMode = HitTestMode.None;
  private animatorResult: AnimatorResult | null = null;
  private dragOffset: number = 0;
  private mode: PullToRefreshIndicatorMode = PullToRefreshIndicatorMode.initial;

  aboutToAppear() {

    if (this.onStateChanged == undefined) {
      throw new Error('The scroller should be initialized. call setScroller first');
    }

  }

  aboutToDisappear() {
    if (this.animatorResult != null) {
      this.animatorResult.finish();
    }
  }

  build() {
    Column() {
      Column() {
        this.builder()
      }
      // not work
      //.hitTestBehavior(HitTestMode.None)
      .onAreaChange((oldValue: Area, newValue: Area) => {
        console.log(`onAreaChange: ${newValue.height}`)
        if (this.maxDragOffset == undefined)
          this.maxDragOffset = (newValue.height as number) / 5;
        if (this.reachToRefreshOffset == undefined) {
          this.reachToRefreshOffset = this.maxDragOffset * 3 / 4;
        }
        else {
          this.reachToRefreshOffset = Math.min(this.reachToRefreshOffset, this.maxDragOffset);
        }
      })
    }
    .parallelGesture(PanGesture({
      direction: PanDirection.Up | PanDirection.Down
    })
      .onActionStart((event?: GestureEvent) => {
        this.onInnerNoticed(PullToRefreshIndicatorMode.drag, 0);
        this.hitTest = HitTestMode.None;
      })
      .onActionUpdate((event?: GestureEvent) => {
        if (!event || this.animatorResult != null || this.onReachEdge == undefined) {
          return;
        }
        let offsetY = event.offsetY;
        if (offsetY > 0 && this.onReachEdge()) {
          offsetY = Math.min(this.maxDragOffset, offsetY);
          if (this.dragOffset == offsetY) {
            return;
          }
          this.onInnerNoticed(offsetY >= this.reachToRefreshOffset ? PullToRefreshIndicatorMode.armed : PullToRefreshIndicatorMode.drag, offsetY);
          // this.viewModel.notificationDragOffset = event.offsetY;
        }
      }).onActionEnd((event?: GestureEvent) => {
        if (!event) {
          return;
        }
        let offsetY = this.dragOffset;
        let isReadyToRefresh = offsetY > this.reachToRefreshOffset;
        if (!isReadyToRefresh) {
          this.pullBack(offsetY, 0, this.pullBackAnimatorOptions.duration * this.dragOffset / offsetY, PullToRefreshIndicatorMode.drag);
          return;
        }


        let completer: Promise<void> = new Promise<void>((resolve) => {

          if (this.refreshOffset != undefined && isReadyToRefresh) {
            let refreshOffset = Math.min(this.refreshOffset, this.reachToRefreshOffset);
            this.pullBack(offsetY, refreshOffset, this.pullBackAnimatorOptions.duration * (offsetY - refreshOffset) / offsetY, PullToRefreshIndicatorMode.snap)
              .then(() => {
                resolve();
              });
          }
          else {
            resolve();
          }
        });

        // onRefresh
        completer.then(() => {
          this.onInnerNoticed(PullToRefreshIndicatorMode.refresh, this.dragOffset, HitTestMode.None);
          this.onRefresh().then((value) => {
            if (value) {
              this.pullBack(this.dragOffset, 0, this.pullBackAnimatorOptions.duration * this.dragOffset / offsetY, PullToRefreshIndicatorMode.done);
            }
          });
        });

      }).onActionCancel((event?: GestureEvent) => {
        if (!event) {
          return;
        }

        this.onInnerNoticed(PullToRefreshIndicatorMode.initial, 0, HitTestMode.Default);
        this.hitTest = HitTestMode.Default;
        if (this.animatorResult != null) {
          this.animatorResult.finish();
          this.animatorResult = null;
        }
      }))
  }

  private pullBack(begin: number, end: number, duration: number, mode: PullToRefreshIndicatorMode): Promise<void> {
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
      this.onInnerNoticed(mode, dragOffset);
    }
    this.animatorResult.play();

    return new Promise<void>((resolve) => {
      this.animatorResult.onfinish = () => {
        if (end == 0) {
          this.onInnerNoticed(PullToRefreshIndicatorMode.initial, 0, HitTestMode.Default);
          this.hitTest = HitTestMode.Default;
        }
        this.animatorResult = null;
        resolve();
      };
    });
  }

  private onInnerNoticed(mode: PullToRefreshIndicatorMode, dragOffset: number, hitTestMode?: HitTestMode) {
    this.mode = mode;
    this.dragOffset = dragOffset;
    if (this.onStateChanged != undefined) {
      this.onStateChanged(mode, dragOffset, hitTestMode == undefined ? HitTestMode.None : hitTestMode);
    }
  }
}

