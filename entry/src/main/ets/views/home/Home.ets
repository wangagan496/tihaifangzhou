import { TgClockIn } from "../../common/components/TgClockIn"
import { TgSearch } from "../../common/components/TgSearch"
import { HomeCategoryComp } from "./HomeCategoryComp"


@Component
export default struct Home {
  // 获取AppStorage中的数据
  @StorageProp("topHeight") topHeight: number = 0

  build() {
    Column() {
      Row({ space: 10 }) {
        // 1.0 搜索组件静态
        TgSearch()
          .layoutWeight(3) // 占3/4份
        // 2.0 打卡组件
        TgClockIn()
          .layoutWeight(1) //占1/4
      }
      .padding(10)

      // 3.0 轮播图
      Swiper() {
        Image($r('app.media.banner_qa'))
          .objectFit(ImageFit.Fill)
          .height(200)
          .borderRadius(10)


        Image($r('app.media.banner_pj'))
          .objectFit(ImageFit.Fill)
          .height(200)
          .borderRadius(10)


        Image($r('app.media.banner_ai'))
          .objectFit(ImageFit.Fill)
          .height(200)
          .borderRadius(10)

      }
      .padding(10)
      .autoPlay(true)
      .indicator(DotIndicator.dot()
        .selectedColor(Color.White)
        .bottom(20))

      //   4.0 使用题目的分类组件
      HomeCategoryComp()
    }
    .padding({ top: this.topHeight })
    .height('100%')
    .width('100%')
  }
}