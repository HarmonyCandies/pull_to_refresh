import {
  PullToRefreshNotification,
// PullToRefreshContainer,
  PullToRefreshIndicatorMode,
  PullToRefresh,
} from '@ohos/pull_to_refresh_notification'
import { ScreenUtils } from '../util/ScreenUtils';
import { LoadingMoreBase } from '../viewmodel/LoadingMoreBase';

@Entry
@Component
struct PullToRefreshHeader {
  @State listData: Array<number> = [];
  scroller: Scroller = new Scroller();
  @State mode: PullToRefreshIndicatorMode = PullToRefreshIndicatorMode.initial;
  @State dragOffset: number = 0;
  @State hitTestMode: HitTestMode = HitTestMode.Default;
  @State lastRefreshTime: number = Date.now();

  aboutToAppear() {
    this.listData = new ListData();
    for (let index = 20; index > 0; index--) {
      this.listData.push(index);
    }

  }

  onRefresh(): void {
    var length = this.listData.length;
    let list: Array<number> = [];
    for (let index = length; index < length + 20; index++) {
      list.push(index);
    }
    this.listData = [length + 1, ...this.listData];
    this.lastRefreshTime = Date.now();
    // this.listData.splice(0,0,...list.reverse());
    //this.listData.unshift(...list.reverse());
  }

  build() {
    Navigation() {
      PullToRefreshNotification(
        {
          onRefresh: async () => {
            return new Promise<boolean>((resolve) => {
              setTimeout(() => {
                resolve(true);
                this.onRefresh();
              }, 2000);
            });
          },
          refreshOffset: 150,
          maxDragOffset: 300,
          reachToRefreshOffset: 200,
          onStateChanged: (mode: PullToRefreshIndicatorMode, dragOffset: number, hitTestMode: HitTestMode) => {
            this.mode = mode;
            this.dragOffset = dragOffset;
            this.hitTestMode = hitTestMode;
          },
          onReachEdge: () => {
            let yOffset = this.scroller.currentOffset().yOffset;
            return Math.abs(yOffset) < 0.001;
          }
        }) {
        Column() {
          PullToRefreshContainer({
            dragOffset: this.dragOffset,
            mode: this.mode,
            lastRefreshTime: this.lastRefreshTime,
          })
          List({ scroller: this.scroller }) {
            ForEach(this.listData, (item, index) => {
              ListItem() {
                Text(`${item}`,).align(Alignment.Center)
              }.height(100).width('100%')
            }, (item, index) => {
              return `${item}`;
            })
          }.edgeEffect(EdgeEffect.None)

          // TODO
          // .hitTestBehavior(this.hitTestMode)
        }

      }
    }
    .titleMode(NavigationTitleMode.Mini)
    .title('PullToRefreshHeader').margin({ top: ScreenUtils.getStatusBarHeight() })

  }
}

@Component
struct PullToRefreshContainer {
  @Prop mode: PullToRefreshIndicatorMode = PullToRefreshIndicatorMode.initial;
  @Prop dragOffset: number = 0;
  @Prop lastRefreshTime: number = 0;

  getShowText(): string {
    let text = '';
    if (this.mode == PullToRefreshIndicatorMode.armed) {
      text = 'Release to refresh';
    } else if (this.mode == PullToRefreshIndicatorMode.refresh ||
      this.mode == PullToRefreshIndicatorMode.snap) {
      text = 'Loading...';
    } else if (this.mode == PullToRefreshIndicatorMode.done) {
      text = 'Refresh completed.';
    } else if (this.mode == PullToRefreshIndicatorMode.drag) {
      text = 'Pull to refresh';
    } else if (this.mode == PullToRefreshIndicatorMode.canceled) {
      text = 'Cancel refresh';
    }
    return text;
  }

  getDate(): String {
    return (new Date(this.lastRefreshTime)).toTimeString();
  }

  build() {
    Row() {
      if (this.dragOffset != 0)
        Text(`${this.getShowText()}---${this.getDate()}`)
      if (this.dragOffset > 50)
        LoadingProgress().width(50).height(50)
    }
    .justifyContent(FlexAlign.Center)
    .height(this.dragOffset)
    .width('100%')
  }
}


class ListData extends LoadingMoreBase<number> {
  protected hasMore: boolean;

  protected async loadData(isLoadMoreAction: boolean): Promise<boolean> {
    return true;
  }
}


