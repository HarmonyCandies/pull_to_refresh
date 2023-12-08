import { PullToRefresh, pull_to_refresh, PullToRefreshIndicatorMode, } from '@candies/pull_to_refresh'
import { ScreenUtils } from '../util/ScreenUtils';

@Entry
@Component
struct PullToRefreshHeader {
  @State listData: Array<number> = [];
  scroller: Scroller = new Scroller();
  @State lastRefreshTime: number = Date.now();
  @State controller: pull_to_refresh.Controller = new pull_to_refresh.Controller();
  firstTime: boolean = true;

  aboutToAppear() {
    for (let index = 20; index > 0; index--) {
      this.listData.push(index);
    }
  }

  async onRefresh(): Promise<boolean> {
    if (this.firstTime) {
      this.firstTime = false;
      return false;
    }
    var length = this.listData.length;

    this.listData = [length + 3, length + 2, length + 1, ...this.listData];
    this.lastRefreshTime = Date.now();
    // this.listData.splice(0,0,...list.reverse());
    //this.listData.unshift(...list.reverse());

    return true;
  }

  build() {
    Navigation() {
      PullToRefresh(
        {
          refreshOffset: 150,
          maxDragOffset: 300,
          reachToRefreshOffset: 200,
          controller: this.controller,
          onRefresh: async () => {
            return new Promise<boolean>((resolve) => {
              setTimeout(() => {
                this.onRefresh().then((value) => resolve(value));
              }, 2000);
            });
          },
          onReachEdge: () => {
            let yOffset = this.scroller.currentOffset().yOffset;
            return Math.abs(yOffset) < 0.001;
          }
        }) {
        PullToRefreshContainer({
          lastRefreshTime: this.lastRefreshTime,
          controller: this.controller,
        })
        List({ scroller: this.scroller }) {
          ForEach(this.listData, (item, index) => {
            ListItem() {
              Text(`${item}`,).align(Alignment.Center)
            }.height(100).width('100%')
          }, (item, index) => {
            return `${item}`;
          })
        }
        // we must do this
        .edgeEffect(EdgeEffect.None)
        // if we are in pull to refresh gesture, the list should not be scroll
        .onScrollFrameBegin((offset, state) => {
          if (this.controller.dragOffset > 0) {
            offset = 0;
          }
          return { offsetRemain: offset, };
        })
      }
    }
    .titleMode(NavigationTitleMode.Mini)
    .title('PullToRefreshHeader').margin({ top: ScreenUtils.getStatusBarHeight() })

  }
}

@Component
struct PullToRefreshContainer {
  @Prop lastRefreshTime: number = 0;
  @Link controller: pull_to_refresh.Controller;

  getShowText(): string {
    let text = '';
    if (this.controller.mode == PullToRefreshIndicatorMode.armed) {
      text = 'Release to refresh';
    } else if (this.controller.mode == PullToRefreshIndicatorMode.refresh ||
      this.controller.mode == PullToRefreshIndicatorMode.snap) {
      text = 'Loading...';
    } else if (this.controller.mode == PullToRefreshIndicatorMode.done) {
      text = 'Refresh completed.';
    } else if (this.controller.mode == PullToRefreshIndicatorMode.drag) {
      text = 'Pull to refresh';
    } else if (this.controller.mode == PullToRefreshIndicatorMode.canceled) {
      text = 'Cancel refresh';
    } else if (this.controller.mode == PullToRefreshIndicatorMode.error) {
      text = 'Refresh failed';
    }
    return text;
  }

  getDate(): String {
    return (new Date(this.lastRefreshTime)).toTimeString();
  }

  build() {
    Row() {
      if (this.controller.dragOffset != 0)
        Text(`${this.getShowText()}---${this.getDate()}`)
      if (this.controller.dragOffset > 50 && this.controller.mode == PullToRefreshIndicatorMode.refresh)
        LoadingProgress().width(50).height(50)
    }
    .justifyContent(FlexAlign.Center)
    .height(this.controller.dragOffset)
    .width('100%')
    .onClick(() => {
      if (this.controller.mode == PullToRefreshIndicatorMode.error) {
        this.controller.refresh();
      }
    })
    .backgroundColor('#22808080')
  }
}



