import { PullToRefreshIndicatorMode, RefreshConstants } from '../common/RefreshConstants';
import { default as PullToRefresh } from '../common/ViewModel';
@Component
export struct PullToRefreshNotification {
  @BuilderParam
  private builder: () => any;
  viewModel:PullToRefresh.ViewModel;
  build() {
    Column() {
      Button('你好').onClick((x) => {
         this.viewModel.state=PullToRefreshIndicatorMode.drag;
      })
      this.builder()
    }
    .parallelGesture(PanGesture({
      direction: PanDirection.Up | PanDirection.Down
    }).onActionStart((x) => {
      let xxx = x.target;

    }))
    .onTouch((event?: TouchEvent) => {
      if (!event) {
        return;
      }
      switch (event.type) {
        case TouchType.Down:

          break;
        case TouchType.Move:

          break;
        case TouchType.Up:

          break;
        case TouchType.Cancel:

          break;
        default:
          break;
      }
      let xxx = event.target;

      console.info(`${xxx.area.position.y}`);
    })
  }
}

