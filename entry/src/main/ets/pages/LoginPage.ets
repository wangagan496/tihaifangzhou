import { auth, IRouterBackParams } from '../common/utils/Auth'
import { tgRequest } from '../common/utils/request'
import { ILoginBody, ILoginDta } from '../models/AccountModel'
import { router } from '@kit.ArkUI'
import { contextManager } from '../common/utils/ContextManager'

@Entry
@Component
struct LoginPage {
  @State username: string = 'hmheima'
  @State password: string = 'Hmheima%123'
  @State isAgree: boolean = false
  //
  @State isLoading: boolean = false
  routerParams: router.RouterOptions | undefined = undefined

  aboutToAppear(): void {
    contextManager.ctx = this.getUIContext().getHostContext()!
    contextManager.UiCtx = this.getUIContext()
    const params = this.getUIContext().getRouter().getParams()
    if (params) {
      this.routerParams = params as router.RouterOptions
    }
  }

  async login() {
    if (this.username === '' || this.password === '') {
      return this.getUIContext().getPromptAction().showToast({
        message: '请填写用户名或密码'
      })
    }
    if (!this.isAgree) {
      return this.getUIContext().getPromptAction().showToast({
        message: '请先阅读并同意用户协议和隐私政策'
      })
    }
    try {
      // 5、加载组件的显示隐藏
      this.isLoading = true
      // const res: AxiosResponse<ILoginRes> =
      //   await instance.post<null, AxiosResponse<ILoginRes>, ILoginBody>('/hm/login', {
      //     username: this.username,
      //     password: this.password
      //   })

      const res = await tgRequest<ILoginDta, ILoginBody>({
        url: '/hm/login',
        method: 'POST',
        data: {
          username: this.username,
          password: this.password
        }
      })
      const params = this.getUIContext().getRouter().getParams() as IRouterBackParams

      // 2、保存用户信息
      auth.setUser(res)
      if (!params) {
        this.getUIContext().getRouter().replaceUrl({ url: 'pages/Index' })
      } else {
        // 4.5 如果有返回页, 回到返回页
        this.getUIContext().getRouter().replaceUrl({ url: params.backUrl, params: params.backParams })
      }
      // 4、显示提示
      this.getUIContext().getPromptAction().showToast({
        message: '登录成功'
      })

    } finally {
      this.isLoading = false
    }
  }

  build() {
    Column() {
      // logo
      Column({ space: 10 }) {
        Image($r('app.media.icon'))
          .height(55)
          .aspectRatio(1)

        Text('刷题宝')
          .fontSize(28)
          .fontColor('#121826')

        Text('搞定学习难题，就用刷题宝')
          .fontSize(14)
          .fontColor('#6F6F6F')
      }
      .margin({ top: 170 })

      //  登录区域
      Column({ space: 20 }) {

        TextInput({ text: $$this.username })
          .backgroundColor(Color.White)
          .width('90%')
          .borderRadius(0)

        TextInput({ text: $$this.password })
          .type(InputType.Password)
          .backgroundColor(Color.White)
          .width('90%')

        Row() {
          Checkbox()
            .select($$this.isAgree)
            .selectedColor('#3a9bfc')

          Text('已阅读并同意')
            .fontSize(14)
            .fontColor($r('app.color.ih_gray_color'))
            .padding({ right: 4 })
          Text('用户协议')
            .fontSize(14)
            .padding({ right: 4 })
          Text('和')
            .fontSize(14)
            .fontColor($r('app.color.ih_gray_color'))
            .padding({ right: 4 })
          Text('隐私政策')
            .fontSize(14)
            .onClick(() => {
              // todo: 跳转至隐私协议
            })
        }
        .width('90%')

        Button() {
          Row() {
            if (this.isLoading) {
              LoadingProgress()
                .height(28)
                .aspectRatio(1)
                .color(Color.White)
            }

            Text('登录')
          }
        }
        .onClick(() => {
          this.login()
        })
        .borderRadius(4)
        .width(328)
        .height(45)
        .fontColor(Color.White)
        .linearGradient({
          angle: 135,
          colors: [
            ['#3a9bfa', 0],
            ['#3a9bfc', 1]
          ]
        })

      }
      .margin({ top: 50 })

    }
    .width('100%')
    .height('100%')
  }
}