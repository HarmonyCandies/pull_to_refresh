import { PullToRefreshIndicatorMode, RefreshConstants } from '../common/RefreshConstants';
import { default as PullToRefresh } from '../common/ViewModel';


@Component
export struct PullToRefreshContainer {
  @Link viewModel: PullToRefresh.ViewModel;
  // @Watch('onStateChanged')
  ///@Prop state: PullToRefreshIndicatorMode=PullToRefreshIndicatorMode.initial;
  @BuilderParam builder: (value: {
    state: PullToRefreshIndicatorMode,
    notificationDragOffset: number
  }) => any;

  build() {
    this.builder({ state: this.viewModel.state, notificationDragOffset: this.viewModel.notificationDragOffset, })
  }
}