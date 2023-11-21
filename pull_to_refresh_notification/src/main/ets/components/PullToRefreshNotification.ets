import { PullToRefreshIndicatorMode, RefreshCallback } from '../common/RefreshConstants';
import animator, { AnimatorOptions, AnimatorResult } from '@ohos.animator';

import pull_to_refresh_notification from '../common/ViewModel';

@Component
export struct PullToRefreshNotification {
  /// The child or children
  @BuilderParam
  private builder: () => void;
  /// A function that's called when the user has dragged the refresh indicator
  /// far enough to demonstrate that they want the app to refresh. The returned
  /// [Future] must complete when the refresh operation is finished.
  onRefresh: RefreshCallback;
  /// Whether we reach the edge to pull refresh
  onReachEdge: () => boolean;
  @Link @Watch('onViewModelChanged') viewModel: pull_to_refresh_notification.ViewModel;

  onViewModelChanged() {
    if (this.viewModel.mode == PullToRefreshIndicatorMode.refresh) {
      this.viewModel.refresh(this.onRefresh);
    }
  }

  aboutToDisappear() {
    this.viewModel.aboutToDisappear();
  }

  build() {
    Column() {
      Column() {
        this.builder()
      }
      // not work
      .hitTestBehavior(this.viewModel.hitTest)
      .onAreaChange((oldValue: Area, newValue: Area) => {
        this.viewModel.onAreaChange(oldValue, newValue);
      })
    }
    .parallelGesture(PanGesture({
      direction: PanDirection.Up | PanDirection.Down
    })
      .onActionStart((event?: GestureEvent) => {
        this.viewModel.onActionStart(event);
      })
      .onActionUpdate((event?: GestureEvent) => {
        this.viewModel.onActionUpdate(event, this.onReachEdge);

      }).onActionEnd((event?: GestureEvent) => {
        this.viewModel.onActionEnd(event, this.onRefresh);

      }).onActionCancel((event?: GestureEvent) => {
        this.viewModel.onActionCancel(event);
      }))
  }
}

