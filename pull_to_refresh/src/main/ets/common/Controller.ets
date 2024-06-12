import { PullToRefreshIndicatorMode, RefreshCallback } from './RefreshConstants';
import animator, { AnimatorOptions, AnimatorResult } from '@ohos.animator';


namespace pull_to_refresh {
  export class Controller {
    /// The current drag offset
    dragOffset: number = 0;
    /// The current pull mode
    mode: PullToRefreshIndicatorMode = PullToRefreshIndicatorMode.initial;
    /// internal
    onRefresh?: () => void | undefined = undefined;

    refresh() {
      if (this.onRefresh != undefined) {
        this.onRefresh();
      }
    }
  }
}

export default pull_to_refresh;