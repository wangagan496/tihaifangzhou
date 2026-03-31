import { windowManager } from "../../common/utils/WindowManager";

@Component
export default struct Mine {
  aboutToAppear(): void {
    //  设置状态栏颜色白色
    windowManager.setStatusBarLight()
  }

  aboutToDisappear(): void {
    //  设置状态栏颜色黑色
    windowManager.setStatusBarDark()
  }

  @StorageProp('topHeight') topHeight: number = 0;

  build() {
    Column() {
      Text("Mine");
    }
    .padding({ top: this.topHeight })
    .width('100%')
    .height('100%')
    .backgroundColor(Color.Pink)
  }
}