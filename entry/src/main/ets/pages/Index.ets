import router from '@ohos.router'
import { ScreenUtils } from '../util/ScreenUtils';

@Entry
@Component
struct Index {
  title: string = 'pull_to_refresh demo';
  pages: Array<PageInfo> = [
    {
      description: 'Show how to use pull to refresh notification to build a pull refresh header,and hide it on refresh done',
      route: 'pages/PullToRefreshHeader',
    },
    {
      description: 'Show how to use pull to refresh notification to build a pull refresh appbar',
      route: 'pages/PullToRefreshAppbar',
    },
  ]

  build() {
    Column() {
      Text(`${this.title}`)
      List() {
        ForEach(this.pages, (item:PageInfo, index) => {
          ListItem() {
            Text(`${index + 1}. ${item.description}`).onClick((x) => {
              router.pushUrl({ url: item.route });
            }).margin(10)
          }.width('100%')
        })
      }.divider({ strokeWidth: 1, color: Color.Gray }).margin({ top: 10 })
    }
    .width('100%').height('100%').margin({ top: ScreenUtils.getStatusBarHeight() })
  }
}

interface PageInfo {
  description: string;
  route: string;
}


