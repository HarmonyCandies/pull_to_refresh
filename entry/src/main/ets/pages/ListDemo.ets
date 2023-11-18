import {
  PullToRefreshNotification,
  PullToRefreshContainer,
  PullToRefreshIndicatorMode,
  PullToRefresh,
} from '@ohos/pull_to_refresh_notification'
import { LoadingMoreBase } from '../viewmodel/LoadingMoreBase';

@Entry
@Component
struct ListDemo {
  @State message: string = 'Hello World';
  listData: ListData;
  @State testModel: PullToRefresh.ViewModel = new PullToRefresh.ViewModel();
  scroller: Scroller = new Scroller();

  aboutToAppear() {
    this.listData = new ListData();
    for (let index = 0; index < 100; index++) {
      this.listData.push(index);
    }
    this.testModel.setScroller(this.scroller);
  }

  @Builder
  PullToRefreshContainerBuilder(value: {
    state: PullToRefreshIndicatorMode,
    notificationDragOffset: number
  }) {
    Row() {
      if (value.notificationDragOffset != 0)
        Text(`${value.state}---${value.notificationDragOffset}`)
      if (value.notificationDragOffset != 0)
        LoadingProgress().width(50).height(50)
    }
    .height(value.notificationDragOffset)
    .width('100%')
    .backgroundColor(Color.Red)
  }

  build() {
    Column() {
      Navigation() {

        PullToRefreshNotification({ viewModel: this.testModel, onRefresh: async () => {
          return true;
        },
          refreshOffset: 200,
        }) {
          Column() {
            PullToRefreshContainer(
              { viewModel: this.testModel, builder: this.PullToRefreshContainerBuilder }
            )
            List({ scroller: this.scroller }) {
              LazyForEach(this.listData, (item, index) => {
                ListItem() {
                  Text(`${index}`,).align(Alignment.Center)
                }.height(100).width('100%')
              }, (item, index) => {
                return `${index}`;
              })
            }.edgeEffect(EdgeEffect.None).onReachStart(() => {
              console.log('到达顶点')
            }).hitTestBehavior(HitTestMode.None)
          }
        }
      }
      .titleMode(NavigationTitleMode.Mini)
      .title('List Demo')

    }
    .width('100%').height('100%')
  }
}


class ListData extends LoadingMoreBase<number> {
  protected hasMore: boolean;

  protected async loadData(isLoadMoreAction: boolean): Promise<boolean> {
    return true;
  }
}


