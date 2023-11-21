import {
  PullToRefreshNotification,
  pull_to_refresh_notification,
  PullToRefreshIndicatorMode,
} from '@ohos/pull_to_refresh_notification'
import { ScreenUtils } from '../util/ScreenUtils';

@Entry
@Component
struct PullToRefreshHeader {
  @State listData: Array<number> = [];
  scroller: Scroller = new Scroller();
  @State mode: PullToRefreshIndicatorMode = PullToRefreshIndicatorMode.initial;
  @State dragOffset: number = 0;
  @State lastRefreshTime: number = Date.now();
  @State viewModel: pull_to_refresh_notification.ViewModel = new pull_to_refresh_notification.ViewModel();

  aboutToAppear() {
    for (let index = 20; index > 0; index--) {
      this.listData.push(index);
    }
    this.viewModel.refreshOffset = 150;
    this.viewModel.maxDragOffset = 300;
    this.viewModel.reachToRefreshOffset = 200;

  }

  async onRefresh(): Promise<boolean> {

    return false;
    var length = this.listData.length;
    let list: Array<number> = [];
    for (let index = length; index < length + 20; index++) {
      list.push(index);
    }
    this.listData = [length + 1, ...this.listData];
    this.lastRefreshTime = Date.now();
    // this.listData.splice(0,0,...list.reverse());
    //this.listData.unshift(...list.reverse());

    return true;
  }

  build() {
    Navigation() {
      PullToRefreshNotification(
        {
          viewModel: this.viewModel,
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
        Column() {
          PullToRefreshContainer({
            dragOffset: this.dragOffset,
            mode: this.mode,
            lastRefreshTime: this.lastRefreshTime,
            viewModel: this.viewModel,
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
  @Link viewModel: pull_to_refresh_notification.ViewModel;

  getShowText(): string {
    let text = '';
    if (this.viewModel.mode == PullToRefreshIndicatorMode.armed) {
      text = 'Release to refresh';
    } else if (this.viewModel.mode == PullToRefreshIndicatorMode.refresh ||
      this.mode == PullToRefreshIndicatorMode.snap) {
      text = 'Loading...';
    } else if (this.viewModel.mode == PullToRefreshIndicatorMode.done) {
      text = 'Refresh completed.';
    } else if (this.viewModel.mode == PullToRefreshIndicatorMode.drag) {
      text = 'Pull to refresh';
    } else if (this.viewModel.mode == PullToRefreshIndicatorMode.canceled) {
      text = 'Cancel refresh';
    } else if (this.viewModel.mode == PullToRefreshIndicatorMode.error) {
      text = 'Refresh failed';
    }
    return text;
  }

  getDate(): String {
    return (new Date(this.lastRefreshTime)).toTimeString();
  }

  build() {
    Row() {
      if (this.viewModel.dragOffset != 0)
        Text(`${this.getShowText()}---${this.getDate()}`)
      if (this.viewModel.dragOffset > 50 && this.viewModel.mode == PullToRefreshIndicatorMode.refresh)
        LoadingProgress().width(50).height(50)
    }
    .justifyContent(FlexAlign.Center)
    .height(this.viewModel.dragOffset)
    .width('100%')
    .onClick(() => {
      if (this.viewModel.mode == PullToRefreshIndicatorMode.error) {
        this.viewModel.mode = PullToRefreshIndicatorMode.refresh;
      }
    })
    .backgroundColor('#22808080')
  }
}



