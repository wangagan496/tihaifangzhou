import { auth } from '../common/utils/Auth';
import { SettingsThemeDialog } from '../views/SettingsPage/SettingsThemeDialog';

export interface Tool {
  icon?: ResourceStr
  name: string
  value?: string
  onClick?: () => void,
  radius?: 0 | 1 | 2
}

@Entry
@Component
struct SettingsPage {
  @StorageProp('topHeight') topHeight: number = 0
  dialog = new CustomDialogController({
    builder: SettingsThemeDialog(),
    customStyle: true,
    alignment: DialogAlignment.Bottom
  })

  build() {
    Navigation() {
      Column({ space: 0.5 }) {
        Blank()
          .height(15)
        this.toolsBuilder({
          name: '编辑资料', radius: 1, onClick: () => {
            auth.checkAuth({
              url: 'pages/ProfileEditPage'
            })
          }
        })
        this.toolsBuilder({ name: '账号设置', radius: 2 })
        Blank()
          .height(15)
        this.toolsBuilder({ name: '消息推送', radius: 1 })
        this.toolsBuilder({
          name: '深色模式',
          value: '已关闭',
          radius: 1,
          onClick: () => {
            // TODO 设置主题
            this.dialog.open()
          }
        })
        this.toolsBuilder({
          name: '清除应用缓存', value: '10MB', onClick: () => {
            // TODO 清除缓存
          }
        })
        this.toolsBuilder({ name: '当前版本', value: '1.0.0', radius: 2 })
        Blank()
          .height(15)
        Text('退出账号')
          .height(50)
          .fontColor($r('app.color.common_main_color'))
          .opacity(0.6)
          .onClick(async () => {
            auth.removeUser()
            this.getUIContext().getRouter().back()
          })
      }
      .layoutWeight(1)
      .padding({ right: 15, left: 15 })
      .backgroundColor($r('app.color.common_gray_bg'))
    }
    .title('设置')
    .titleMode(NavigationTitleMode.Mini)
    .padding({ top: this.topHeight })

  }

  @Builder
  toolsBuilder(tool: Tool) {
    Row() {
      if (tool.icon) {
        Image(tool.icon)
          .width(16)
          .aspectRatio(1)
          .margin({ right: 12 })
      }
      Text(tool.name)
        .fontSize(16)
        .fontColor($r('app.color.common_gray_01'))
      Blank()
      if (tool.value) {
        Text(tool.value)
          .fontSize(14)
          .fontColor($r('app.color.common_gray_01'))
          .margin({ right: 10 })
      }
      Image($r('sys.media.ohos_ic_public_arrow_right'))
        .width(18)
        .aspectRatio(1)
        .fillColor($r('app.color.common_gray_01'))
    }
    .height(50)
    .width('100%')
    .backgroundColor('#ffffff')
    .padding({ left: 16, right: 10 })
    .borderRadius({
      topLeft: tool.radius === 1 ? 8 : 0,
      topRight: tool.radius === 1 ? 8 : 0,
      bottomLeft: tool.radius === 2 ? 8 : 0,
      bottomRight: tool.radius === 2 ? 8 : 0
    })
    .onClick(() => {
      tool.onClick && tool.onClick()
    })
  }
}