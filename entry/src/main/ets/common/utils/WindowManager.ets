import { window } from '@kit.ArkUI'
import { contextManager } from './ContextManager'

class WindowManager {
  // 启动全屏
  enableFullScreen() {
    if (contextManager.getCtx()) {
      window.getLastWindow(contextManager.getCtx())
        .then((win) => {
          win.setWindowLayoutFullScreen(true)
          const topHeight = win.getWindowAvoidArea(window.AvoidAreaType.TYPE_SYSTEM)
          if (contextManager.getUiCtx()) {
            AppStorage.setOrCreate('topHeight', contextManager.getUiCtx()!.px2vp(topHeight.topRect.height))
          }
        })
    }
  }

  // 关闭全屏
  disableFullScreen() {
    if (contextManager.getCtx()) {
      window.getLastWindow(contextManager.getCtx())
        .then((win) => {
          win.setWindowLayoutFullScreen(false)
          AppStorage.setOrCreate('topHeight', 0)
        })
    }
  }

  // 设置状态栏亮色
  setStatusBarLight() {
    if (contextManager.getCtx()) {
      window.getLastWindow(contextManager.getCtx())
        .then((win) => {
          win.setWindowSystemBarProperties({
            statusBarContentColor: "#ffffff"
          })

        })
    }
  }

  // 设置状态栏暗色
  setStatusBarDark() {
    if (contextManager.getCtx()) {
      window.getLastWindow(contextManager.getCtx())
        .then((win) => {
          win.setWindowSystemBarProperties({
            statusBarContentColor: "#000000"
          })
        })
    }
  }
}

export const windowManager = new WindowManager()