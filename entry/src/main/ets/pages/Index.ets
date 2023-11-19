import {
  PullToRefreshNotification,
  // PullToRefreshContainer,
  PullToRefreshIndicatorMode,
  PullToRefresh,
} from '@ohos/pull_to_refresh_notification'
import { LoadingMoreBase } from '../viewmodel/LoadingMoreBase';
import deviceInfo from '@ohos.deviceInfo'
import display from '@ohos.display'
import router from '@ohos.router'
import common from '@ohos.app.ability.common';
import window from '@ohos.window';
@Entry
@Component
struct Index {
  title: string = 'pull_to_refresh_notification demo';
  pages: Array<PageInfo> = [
    {
      description: 'Show how to use pull to refresh notification to build a pull refresh header,and hide it on refresh done',
      route: 'pages/PullToRefreshHeader',
    },

  ]

  // 获取UIAbility上下文
  context: common.UIAbilityContext = getContext(this) as common.UIAbilityContext
  async setSystemBar() {
    // 获取当前应用窗口
    let windowClass:window.Window = await window.getLastWindow(this.context)
    // 将状态栏和导航栏的背景色设置为跟应用窗口相同的颜色
    await windowClass.setWindowSystemBarProperties({
      navigationBarColor: "#00FF00",
      statusBarColor: "#00FF00",
      navigationBarContentColor: "#00FF00",
      statusBarContentColor: "#00FF00"
    })
  }

  aboutToAppear() {
    // this.setSystemBar()
  }

  build() {
    Column() {
      Text(`${this.title}`)
      List() {
        ForEach(this.pages, (item, index) => {
          ListItem() {
            Text(`${index+1}. ${item.description}`).onClick((x) => {
              router.pushUrl({ url: item.route });
            })
          }.width('100%')
        })
      }.divider({ strokeWidth: 1, color: Color.Gray }).margin({ top: 10 })
    }
    .width('100%').height('100%')
  }
}

interface PageInfo {
  description: String;
  route: String;
}


