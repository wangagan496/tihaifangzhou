import { AxiosResponse } from "@ohos/axios"
import { ILoginDta, ILoginRes } from "../../models/AccountModel"
import { IClockData, IClockRes } from "../../models/HomeModels"
import { instance, request } from "../utils/request"

@Component
export struct TgClockIn {
  @StorageProp('user') user: ILoginDta = {} as ILoginDta
  @Prop
  clockCount: number = 0

  async onClock() {
    // try {
    //   const res: AxiosResponse<IClockRes> =
    //     await request<IClockData>({
    //       url: '/hm/clockinInfo'
    //     })
    //   if (res.data.code === 10000) {
    //     this.clockCount = res.data.data.clockinNumbers
    //   }
    // } catch (e) {
    //   console.log(JSON.stringify(e))
    // }

    const res = await request<IClockData>({ url: '/hm/clockinInfo' })
    this.clockCount = res.clockinNumbers

  }

  build() {
    Stack({ alignContent: Alignment.End }) {
      Image(this.clockCount > 0 ? $r('app.media.clocked') : $r('app.media.unclock'))
        .objectFit(ImageFit.Fill)
      if (this.clockCount > 0) {
        Column() {
          Text('已连续打卡')
            .fontSize(8)
          Text() {
            Span(this.clockCount.toString())
              .fontWeight(600)
              .fontSize(12)
            Span(' 天')
              .fontSize(10)
          }
        }
        .width('50')
        .onClick(() => {
          this.getUIContext().getRouter().pushUrl({
            url: 'pages/ClockPage'
          })
        })
      } else {
        Text('打卡')
          .width('50')
          .textAlign(TextAlign.Center)
          .fontSize((18))
          .fontWeight(500)
          .fontColor('#333C4F')
          .margin({ bottom: (4) })
          .onClick(() => {
            this.onClock()
          })
      }
    }
    .width((74))
    .height((28))
  }
}