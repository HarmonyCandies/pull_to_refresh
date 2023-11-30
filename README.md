# pull_to_refresh_notification

快速自定义下拉刷新动画的组件

- [pull\_to\_refresh\_notification](#pull_to_refresh_notification)
  - [安装](#安装)
  - [参数](#参数)
    - [PullToRefreshIndicatorMode](#pulltorefreshindicatormode)
    - [ViewModel 配置参数](#viewmodel-配置参数)
    - [回调](#回调)
      - [onRefresh](#onrefresh)
      - [onReachEdge](#onreachedge)
  - [使用](#使用)
    - [导入引用](#导入引用)
    - [定义配置](#定义配置)
    - [设置配置](#设置配置)
    - [使用 PullToRefreshNotification](#使用-pulltorefreshnotification)
    - [自定义下拉刷新效果](#自定义下拉刷新效果)


## 安装

`ohpm install @ohos/pull_to_refresh_notification`

## 参数

### PullToRefreshIndicatorMode 

``` typescript
export enum PullToRefreshIndicatorMode {
  initial, // 初始状态
  drag, // 手势向下拉的状态.
  armed, // 被拖动得足够远，以至于触发“onRefresh”回调函数的上滑事件
  snap, // 用户没有拖动到足够远的地方并且释放回到初始化状态的过程
  refresh, // 正在执行刷新回调.
  done, // 刷新回调完成.
  canceled, // 用户取消了下拉刷新手势.
  error, // 刷新失败
}
```

### ViewModel 配置参数

配置参数通过对象 `ViewModel` 进行设置。


| 参数 | 类型 | 描述 |
| --- | --- |--- |
| maxDragOffset | number | 最大拖动距离(非必填) |
| reachToRefreshOffset | number | 到达满足触发刷新的距离(非必填) |
| refreshOffset | number | 触发刷新的时候，停留的刷新距离(非必填) |
| pullBackOnRefresh | boolean | 在触发刷新回调的时候是否执行回退动画(默认 `false`) |
| pullBackAnimatorOptions | AnimatorOptions | 回退动画的一些配置(duration，easing，delay,fill) |
| pullBackOnError | boolean | 刷新失败的时候，是否执行回退动画(默认 `false`) |

* `maxDragOffset` 和 `reachToRefreshOffset` 如果不定义的话，会根据当前容器的高度设置默认值。

```
/// Set the default value of [maxDragOffset,reachToRefreshOffset]
onAreaChange(oldValue: Area, newValue: Area) {
  if (this.maxDragOffset == undefined) {
    this.maxDragOffset = (newValue.height as number) / 5;
  }
  if (this.reachToRefreshOffset == undefined) {
    this.reachToRefreshOffset = this.maxDragOffset * 3 / 4;
  }
  else {
    this.reachToRefreshOffset = Math.min(this.reachToRefreshOffset, this.maxDragOffset);
  }
}
```

* `pullBackAnimatorOptions` 的默认值如下：

``` typescript
/// The options of pull back animation
pullBackAnimatorOptions: AnimatorOptions = {
  duration: 400,
  easing: "friction",
  delay: 0,
  fill: "forwards",
  direction: "normal",
  iterations: 1,
  begin: 1.0,
  end: 0.0
};
```
 
### 回调

#### onRefresh

触发的下拉刷新事件
``` typescript
/// A function that's called when the user has dragged the refresh indicator
/// far enough to demonstrate that they want the app to refresh. The returned
/// [Future] must complete when the refresh operation is finished.

onRefresh: RefreshCallback = async () => true;
```
#### onReachEdge

是否我们到达了下拉刷新的边界，比如说，下拉刷新的内容是一个列表，那么边界就是到达列表的顶部位置。
``` typescript
/// Whether we reach the edge to pull refresh
onReachEdge: () => boolean = () => true;
```

## 使用

### 导入引用
``` typescript
import {
  PullToRefreshNotification,
  pull_to_refresh_notification,
  PullToRefreshIndicatorMode,
} from '@ohos/pull_to_refresh_notification'
```

### 定义配置

``` typescript
@State viewModel: pull_to_refresh_notification.ViewModel = new pull_to_refresh_notification.ViewModel();
```

### 设置配置

``` typescript
aboutToAppear() {
  this.viewModel.refreshOffset = 150;
  this.viewModel.maxDragOffset = 300;
  this.viewModel.reachToRefreshOffset = 200;
}
```

### 使用 PullToRefreshNotification

将需要支持下拉刷新的部分，通过 `@BuilderParam` 修饰的 `builder` 回调传入，或者尾随闭包初始化组件。

[@BuilderParam装饰器：引用@Builder函数-快速入门-入门-HarmonyOS应用开发](https://developer.harmonyos.com/cn/docs/documentation/doc-guides-V3/arkts-builderparam-0000001524416541-V3)

``` typescript

  PullToRefreshNotification(
    {
      viewModel: this.viewModel,
      onRefresh: async () => {
        return new Promise<boolean>((resolve) => {
          setTimeout(() => {
            // 定义的刷新方法，当刷新成功之后，返回回调，模拟 2 秒之后刷新完毕
            this.onRefresh().then((value) => resolve(value));
          }, 2000);
        });
      },
      onReachEdge: () => {
        let yOffset = this.scroller.currentOffset().yOffset;
        return Math.abs(yOffset) < 0.001;
      }
    }) {
    // 我们自定义的下拉刷新头部
    PullToRefreshContainer({
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
    }
    // 必须设置 edgeEffect
    .edgeEffect(EdgeEffect.None)
    // 为了使下拉刷新的手势的过程中，不触发列表的滚动
    .onScrollFrameBegin((offset, state) => {
      if (this.viewModel.dragOffset > 0) {
        offset = 0;
      }
      return { offsetRemain: offset, };
    })
  }
}
```

### 自定义下拉刷新效果 

你可以通过对 `ViewModel` 中 `dragOffset` 和 `mode` 的状态，把创建属于自己的下拉刷新效果。如果下拉刷新失败了，你也可以通过调用 `ViewModel` 的 `refresh() `方法来重新执行刷新动画。

```
/// The current drag offset
dragOffset: number = 0;
/// The current pull mode
mode: PullToRefreshIndicatorMode = PullToRefreshIndicatorMode.initial;
```

下面是一个自定义下拉刷新头部的例子

```
@Component
struct PullToRefreshContainer {
  @Prop lastRefreshTime: number = 0;
  @Link viewModel: pull_to_refresh_notification.ViewModel;

  getShowText(): string {
    let text = '';
    if (this.viewModel.mode == PullToRefreshIndicatorMode.armed) {
      text = 'Release to refresh';
    } else if (this.viewModel.mode == PullToRefreshIndicatorMode.refresh ||
      this.viewModel.mode == PullToRefreshIndicatorMode.snap) {
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
        // 点击重新触发刷新动画
        this.viewModel.refresh();
      }
    })
    .backgroundColor('#22808080')
  }
}
```

