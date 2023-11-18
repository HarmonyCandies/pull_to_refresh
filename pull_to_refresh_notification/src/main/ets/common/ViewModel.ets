import { PullToRefreshIndicatorMode } from './RefreshConstants';

namespace PullToRefresh {
  export class ViewModel {
    state: PullToRefreshIndicatorMode = PullToRefreshIndicatorMode.initial;
    notificationDragOffset: number = 0;
    private scroller: Scroller;

    public setScroller(scroller: Scroller): ViewModel {
      this.scroller = scroller;
      return this;
    }


    public isAtTop(): boolean {
      if (this.scroller == undefined) {
        throw new Error('The scroller should be initialized. call setScroller first');
      }
      let yOffset = this.scroller.currentOffset().yOffset;
      return Math.abs(yOffset) < 0.01;
      // return Math.abs(yOffset) < Number.EPSILON;
    }
  }
}

export default PullToRefresh;