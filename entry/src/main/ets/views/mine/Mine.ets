import { router } from '@kit.ArkUI'
import { windowManager } from '../../common/utils/WindowManager'
import { ILoginDta } from '../../models/AccountModel'

interface Nav {
  icon: ResourceStr
  name: string
  onClick?: () => void
  other?: string
}

interface Tool {
  icon: ResourceStr
  name: string
  value?: string
  onClick?: () => void
}

@Component
export default struct Mine {
  @StorageProp('user') user: ILoginDta = {} as ILoginDta

  aboutToAppear(): void {
    windowManager.setStatusBarLight()
  }

  aboutToDisappear(): void {
    windowManager.setStatusBarDark()
  }

  build() {
    Column({ space: 16 }) {
      Row({ space: 12 }) {
        Image(this.user.avatar || $r('app.media.ic_mine_avatar'))
          .width(55)
          .aspectRatio(1)
          .borderRadius(55)
        Column({ space: 4 }) {
          Text(this.user.nickName || '未登录')
            .fontSize(18)
            .fontWeight(600)
            .width('100%')
            .margin({ bottom: 5 })
          Row() {
            Text('编辑个人信息')
              .fontColor($r('app.color.ih_gray_color'))
              .fontSize(11)
              .margin({ right: 4 })
            Image($r('app.media.icon_edit'))
              .width(10)
              .height(10)
              .fillColor($r('app.color.ih_gray_color'))
          }.onClick(() => {
            router.pushUrl({
              url: '修改信息页面'
            })
          })
          .width('100%')

        }
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Start)

        Text('放打卡组件')
      }
      .width('100%')
      .height(100)

      GridRow({ columns: 4 }) {
        this.navBuilder({ icon: $r('app.media.ic_mine_history'), name: '历史记录' })
        this.navBuilder({ icon: $r('app.media.ic_mine_collect'), name: '我的收藏' })
        this.navBuilder({ icon: $r('app.media.ic_mine_like'), name: '我的点赞' })
        this.navBuilder({
          icon: $r('app.media.ic_mine_study'),
          name: '累计学时',
          other: '4 小时'
        ,
          onClick: () => {
            router.pushUrl({ url: '跳转到学习记录页面' })
          }
        })
      }
      .backgroundColor(Color.White)
      .padding(16)
      .borderRadius(8)

      Column() {
        this.toolsBuilder({ icon: $r('app.media.ic_mine_notes'), name: '前端常用词' })
        this.toolsBuilder({ icon: $r('app.media.ic_mine_ai'), name: '面通AI' })
        this.toolsBuilder({ icon: $r('app.media.ic_mine_invite'), name: '推荐分享' })
        this.toolsBuilder({ icon: $r('app.media.ic_mine_file'), name: '意见反馈' })
        this.toolsBuilder({ icon: $r('app.media.ic_mine_info'), name: '关于我们' })
        this.toolsBuilder({ icon: $r('app.media.ic_mine_setting'), name: '设置' })
      }
      .backgroundColor(Color.White)
      .borderRadius(8)

    }
    .padding($r('app.float.common_gutter'))
    .backgroundColor($r('app.color.common_gray_bg'))
    .linearGradient({
      colors: [[$r('app.color.common_blue'), 0], [$r('app.color.common_blue_bg'), 0.3], ['#f3f4f5', 1]]
    })
    .width('100%')
    .height('100%')
  }

  @Builder
  navBuilder(nav: Nav) {
    GridCol() {
      Column() {
        Image(nav.icon)
          .width(30)
          .aspectRatio(1)
          .margin({ bottom: 10 })
        Text(nav.name)
          .fontSize(14)
          .fontColor($r('app.color.common_gray_03'))
          .margin({ bottom: 4 })
        if (nav.other) {
          Row() {
            Text(nav.other)
              .fontSize(12)
              .fontColor($r('app.color.common_gray_01'))
            Image($r('sys.media.ohos_ic_public_arrow_right'))
              .width(12)
              .aspectRatio(1)
              .fillColor($r('app.color.common_gray_01'))
          }
        }
      }
      .onClick(() => {
        nav.onClick && nav.onClick()
      })
    }
  }

  @Builder
  toolsBuilder(tool: Tool) {
    Row() {
      Image(tool.icon)
        .width(16)
        .aspectRatio(1)
        .margin({ right: 12 })
      Text(tool.name)
        .fontSize(14)
      Blank()
      if (tool.value) {
        Text(tool.value)
          .fontSize(12)
          .fontColor($r('app.color.common_gray_01'))
      }
      Image($r('sys.media.ohos_ic_public_arrow_right'))
        .width(16)
        .aspectRatio(1)
        .fillColor($r('app.color.common_gray_01'))
    }
    .height(50)
    .width('100%')
    .padding({ left: 16, right: 10 })
  }
}