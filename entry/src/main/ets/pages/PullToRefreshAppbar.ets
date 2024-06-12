import { PullToRefresh, pull_to_refresh, PullToRefreshIndicatorMode, } from '@candies/pull_to_refresh'
import { ScreenUtils } from '../util/ScreenUtils';
import router from '@ohos.router';

@Entry
@Component
struct PullToRefreshAppbar {
  @State listData: Array<number> = [];
  scroller: Scroller = new Scroller();
  @State lastRefreshTime: number = Date.now();
  @State controller: pull_to_refresh.Controller = new pull_to_refresh.Controller();

  aboutToAppear() {
    for (let index = 20; index > 0; index--) {
      this.listData.push(index);
    }
  }

  onRefresh(): void {
    let length = this.listData.length;
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
      PullToRefresh(
        {
          pullBackOnRefresh: true,
          maxDragOffset: 120,
          reachToRefreshOffset: 80,
          pullBackAnimatorOptions: {
            duration: 2000,
            easing: "friction",
            delay: 0,
            fill: "forwards",
            direction: "normal",
            iterations: 1,
            begin: 1.0,
            end: 0.0
          },
          controller: this.controller,
          onRefresh: async () => {
            return new Promise<boolean>((resolve) => {
              setTimeout(() => {
                resolve(true);
                this.onRefresh();
              }, 2000);
            });
          },
          onReachEdge: () => {
            let yOffset = this.scroller.currentOffset().yOffset;
            return Math.abs(yOffset) < 0.001;
          }
        }) {
        Stack({ alignContent: Alignment.Top }) {
          Column() {
            Image($r('app.media.467141054'))
              .width("100%")
              .height(this.controller.dragOffset + 200)
              .objectFit(ImageFit.Cover)
            List({ scroller: this.scroller }) {
              ForEach(this.listData, (item:number, index) => {
                ListItem() {
                  Text(`${item}`,).align(Alignment.Center)
                }.height(100).width('100%')
              }, (item:number, index) => {
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
            },)
          }

          Row() {
            Text('back').onClick(() => {
              router.back();
            }).margin({ left: 15, top: 15 }).fontColor(Color.White)
            if (this.controller.mode == PullToRefreshIndicatorMode.refresh)
              LoadingProgress().width(35).height(35).margin({ right: 15 }).color(Color.White)
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


