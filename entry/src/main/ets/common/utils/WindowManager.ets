import { window } from '@kit.ArkUI'
import { Context } from '@kit.AbilityKit'

class WindowManager {
  UiCtx: UIContext | null = null
  ctx: Context | null = null

  // 启动全屏
  enableFullScreen() {
    if (this.ctx) {
      window.getLastWindow(this.ctx)
        .then((win) => {
          win.setWindowLayoutFullScreen(true)
          const topHeight = win.getWindowAvoidArea(window.AvoidAreaType.TYPE_SYSTEM)
          if (this.UiCtx) {
            AppStorage.setOrCreate('topHeight', this.UiCtx.px2vp(topHeight.topRect.height))
          }
        })
    }
  }

  // 关闭全屏
  disableFullScreen() {
    if (this.ctx) {
      window.getLastWindow(this.ctx)
        .then((win) => {
          win.setWindowLayoutFullScreen(false)
          AppStorage.setOrCreate('topHeight', 0)
        })
    }
  }

  // 设置状态栏亮色
  setStatusBarLight() {
    if (this.ctx) {
      window.getLastWindow(this.ctx)
        .then((win) => {
          win.setWindowSystemBarProperties({
            statusBarContentColor: "#ffffff"
          })

        })
    }
  }

  // 设置状态栏暗色
  setStatusBarDark() {
    if (this.ctx) {
      window.getLastWindow(this.ctx)
        .then((win) => {
          win.setWindowSystemBarProperties({
            statusBarContentColor: "#000000"
          })
        })
    }
  }
}

export const windowManager = new WindowManager()