import window from '@ohos.window';
import display from '@ohos.display'

export class ScreenUtils {
  static getStatusBarHeight() {
    let statusBarHeight = AppStorage.get<number>('statusBarHeight');
    return statusBarHeight;
  }

  static getBottomHeight() {
    return AppStorage.get<number>('bottomHeight');
  }

  static async enterImmersion(windowStage: window.WindowStage): Promise<void> {

    let windowClass: window.Window = await windowStage.getMainWindow()

    // 获取状态栏和导航栏的高度
    windowClass.on("avoidAreaChange", (options: window.AvoidAreaOptions) => {
      if (options.type == window.AvoidAreaType.TYPE_SYSTEM) {
        // 将状态栏和导航栏的高度保存在AppStorage中
        let defaultDisplay = display.getDefaultDisplaySync();
        AppStorage.setOrCreate<number>("statusBarHeight", options.area.topRect.height / defaultDisplay.densityPixels);
        AppStorage.setOrCreate<number>("bottomHeight", options.area.bottomRect.height / defaultDisplay.densityPixels);
      }
    })
    // 设置窗口布局为沉浸式布局
    await windowClass.setWindowLayoutFullScreen(true)
    await windowClass.setWindowSystemBarEnable(["status"])
    // 设置状态栏和导航栏的背景为透明
    await windowClass.setWindowSystemBarProperties({
      navigationBarColor: "#00000000",
      statusBarColor: "#00000000",
      navigationBarContentColor: "#FF0000",
      statusBarContentColor: "#FF0000"
    })
  }
}