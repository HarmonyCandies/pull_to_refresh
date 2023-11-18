import { PullToRefreshIndicatorMode, RefreshConstants } from '../common/RefreshConstants';
import { default as PullToRefresh } from '../common/ViewModel';
import animator, { AnimatorOptions,AnimatorResult } from '@ohos.animator';

@Component
export struct PullToRefreshNotification {
  @BuilderParam
  private builder: () => CommonMethod<any>;
  /// The max drag offset
  maxDragOffset?: number;
  /// The offset to be dragged far enough that an up event will run the onRefresh callback.
  reachToRefreshOffset?: number;
  /// The offset to keep when it is refreshing
  refreshOffset?: number;
  /// ViewModel
  viewModel: PullToRefresh.ViewModel;
  /// A function that's called when the user has dragged the refresh indicator
  /// far enough to demonstrate that they want the app to refresh. The returned
  /// [Future] must complete when the refresh operation is finished.
  onRefresh: () => Promise<boolean>;
  /// Whether start pull back animation when refresh.
  pullBackOnRefresh: boolean = false;

  /// xxx
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

  /// children should not join HitTest when start to pull to refresh
  @State private hitTest: HitTestMode = HitTestMode.Default;

  private animatorResult:AnimatorResult|null=null;

  aboutToAppear() {
    if (this.maxDragOffset == undefined) {
      this.maxDragOffset = Number.MAX_VALUE;
    }
  }

  build() {
    Column() {
      Column() {
        this.builder()
      }.hitTestBehavior(this.hitTest)
    }
    .parallelGesture(PanGesture({
      direction: PanDirection.Up | PanDirection.Down
    })
      .onActionStart((event?: GestureEvent)=>{
        this.viewModel.state=PullToRefreshIndicatorMode.drag;
      })
      .onActionUpdate((event?: GestureEvent) => {
      if (!event || this.animatorResult!=null) {
        return;
      }

      if (event.offsetY > 0 && this.viewModel.isAtTop()) {
        this.viewModel.notificationDragOffset = event.offsetY;
        this.hitTest = HitTestMode.None;
      }
    }).onActionEnd((event?: GestureEvent) => {
      if (!event) {
        return;
      }
      this.animatorResult= animator.create(this.pullBackAnimatorOptions);

      this.animatorResult.onframe=(progress
      )=>{
        this.viewModel.notificationDragOffset = event.offsetY*progress;
        if(this.refreshOffset!=undefined && this.viewModel.notificationDragOffset<=this.refreshOffset){
          this.animatorResult.pause();
        }
      }

      this.animatorResult.onfinish=()=>{
        this.viewModel.notificationDragOffset = 0;
        this.hitTest = HitTestMode.Default;
        this.animatorResult=null;
      };

      this.animatorResult.play();


    }).onActionCancel((event?: GestureEvent) => {
      if (!event) {
        return;
      }

      this.viewModel.notificationDragOffset = 0;
      this.hitTest = HitTestMode.Default;
      if(this.animatorResult!=null){
        this.animatorResult.finish();
        this.animatorResult=null;
      }
    }))
  }


  private pullBack(){

  }
}

