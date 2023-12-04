import { RefreshCallback } from '../common/RefreshConstants';

import pull_to_refresh from '../common/ViewModel';

@Component
export struct PullToRefresh {
  /// The children
  @BuilderParam
  private builder: () => void;
  /// A function that's called when the user has dragged the refresh indicator
  /// far enough to demonstrate that they want the app to refresh. The returned
  /// [Future] must complete when the refresh operation is finished.
  onRefresh: RefreshCallback = async () => true;
  /// Whether we reach the edge to pull refresh
  onReachEdge: () => boolean = () => true;
  @Link viewModel: pull_to_refresh.ViewModel;

  aboutToAppear() {
    this.viewModel.onRefresh = this.onRefresh;
  }

  aboutToDisappear() {
    this.viewModel.aboutToDisappear();
  }

  build() {
    Column() {
      this.builder()
    }.onAreaChange((oldValue: Area, newValue: Area) => {
      this.viewModel.onAreaChange(oldValue, newValue);
    })
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

