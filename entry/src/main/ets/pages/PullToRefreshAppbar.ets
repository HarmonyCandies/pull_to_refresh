import {
  PullToRefreshNotification,
// PullToRefreshContainer,
  PullToRefreshIndicatorMode,
  PullToRefresh,
} from '@ohos/pull_to_refresh_notification'
import { ScreenUtils } from '../util/ScreenUtils';
import { LoadingMoreBase } from '../viewmodel/LoadingMoreBase';
import router from '@ohos.router';

@Entry
@Component
struct PullToRefreshAppbar {
  @State listData: Array<number> = [];
  scroller: Scroller = new Scroller();
  @State mode: PullToRefreshIndicatorMode = PullToRefreshIndicatorMode.initial;
  @State dragOffset: number = 0;
  @State hitTestMode: HitTestMode = HitTestMode.Default;
  @State lastRefreshTime: number = Date.now();

  aboutToAppear() {
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

  @Builder
  NavigationMenus() {

  }

  build() {
    Column() {
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
          pullBackOnRefresh: true,
          maxDragOffset: 120,
          reachToRefreshOffset: 80,
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
        Stack({ alignContent: Alignment.Top }) {
          Column() {
            Image($r('app.media.467141054')).width("100%").height(this.dragOffset + 200).objectFit(ImageFit.Cover)
            List({ scroller: this.scroller }) {
              ForEach(this.listData, (item, index) => {
                ListItem() {
                  Text(`${item}`,).align(Alignment.Center)
                }.height(100).width('100%')
              }, (item, index) => {
                return `${item}`;
              })
            }.edgeEffect(EdgeEffect.None)
          }
          Row() {
            Text('back').onClick(() => {
              router.back();
            }).margin({ left: 15, top: 15 }).fontColor(Color.White)
            if (this.mode == PullToRefreshIndicatorMode.refresh)
              LoadingProgress().width(24).height(24).margin({ right: 15 })
            else
              Text('...')
                .width(24)
                .height(24).fontColor(Color.White)
          }
          .alignItems(VerticalAlign.Top)
          .align(Alignment.Top)
          .justifyContent(FlexAlign.SpaceBetween)
          .margin({ top: ScreenUtils.getStatusBarHeight() })
          .width('100%')
        }
      }
    }
  }
}


