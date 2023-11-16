import {
  PullToRefreshNotification,
  PullToRefreshContainer,
  PullToRefreshIndicatorMode,
  PullToRefresh,
} from '@ohos/pull_to_refresh_notification'
import { LoadingMoreBase } from '../viewmodel/LoadingMoreBase';

@Entry
@Component
struct Index {
  @State message: string = 'Hello World';
  @Provide('a') refreshIndicatorMode: PullToRefreshIndicatorMode = PullToRefreshIndicatorMode.initial;
  @State offset1: number = 1;
  listData: ListData;
  @State testModel: TestModel = new TestModel();
  @State testModel1: PullToRefresh.ViewModel = new PullToRefresh.ViewModel();

  aboutToAppear() {
    this.listData = new ListData();
    for (let index = 0; index < 10; index++) {
      this.listData.push(index);
    }
  }

  @Builder
  PullToRefreshContainerBuilder(value: {
    state: PullToRefreshIndicatorMode,
    notificationDragOffset: number
  }) {
    Text(`${value.state}---${value.notificationDragOffset}`)
  }

  build() {

    Column() {
      Text(`offset1${this.offset1}`)

      ParentWidget({ testModel: this.testModel }) {
        ChildWidget({ testModel: this.testModel })
      }

      PullToRefreshNotification({ viewModel: this.testModel1 }) {
        PullToRefreshContainer(
          { viewModel: this.testModel1, builder: this.PullToRefreshContainerBuilder }
        )
        List() {
          LazyForEach(this.listData, (item, index) => {
            ListItem() {
              Text(`${index}`,)
            }.height(100)
          }, (item, index) => {
            return `${index}`;
          })
        }
      }

      // PullToRefreshNotification(
      //   { onStateChange: (s: PullToRefreshIndicatorMode, a: number) => {
      //     this.offset1 = a;
      //   }
      //   }
      // ) {
      //   List() {
      //     LazyForEach(this.listData, (item, index) => {
      //       ListItem() {
      //         Text(`${index}`,)
      //       }.height(100)
      //     }, (item, index) => {
      //       return `${index}`;
      //     })
      //   }
      //
      // }


      // .onStateChanged((state, offset) => {
      //   this.offset1 = offset;
      // })


    }
    .width('100%').height('100%')
  }
}


class ListData extends LoadingMoreBase<number> {
}


@Component
struct ParentWidget {
  testModel: TestModel;
  @BuilderParam
  private builder: () => void;

  build() {
    Column() {
      Button('你好').onClick((x) => {
        this.testModel.test += 'abc';
      })
      Text(`ParentWidget: ${this.testModel.test}`)
      if (this.builder)
        this.builder()
    }
  }
}

@Component
struct ChildWidget {
  @Link testModel: TestModel;

  build() {
    Column() {
      Text(`ChildWidget: ${this.testModel.test}`)
    }
  }
}

class TestModel {
  test: String = '';
}