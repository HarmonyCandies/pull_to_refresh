
import {PullToRefreshIndicatorMode} from './RefreshConstants';

 namespace PullToRefresh {
  export class ViewModel {
    state: PullToRefreshIndicatorMode = PullToRefreshIndicatorMode.initial;
    notificationDragOffset: number = 0;
  }
}

export default PullToRefresh;