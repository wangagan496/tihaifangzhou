import { request } from "../../common/utils/request"
import { IQuestionType } from "../../models/CategoryModel"
import { QuestionListComp } from "./QuestionListComp"

@Component
export struct HomeCategoryComp {
  @State index: number = 0
  @State questionTypeList: IQuestionType[] = []

  aboutToAppear(): void {
    this.getTabBarData()
  }

  async getTabBarData() {
    const res = await request<IQuestionType[]>({ url: '/hm/question/type' })
    this.questionTypeList = res
  }

  @Builder
  TabItemBuilder(q: IQuestionType, index: number) {
    Row() {
      Stack({ alignContent: Alignment.Bottom }) {
        Text(q.name)
          .fontSize(15)
          .height(43)
          .fontColor(this.index === index ? Color.Black : Color.Gray)
        Text()
          .width(this.index === index ? 20 : 0)
          .height(2)
          .backgroundColor(Color.Black)
          .animation({ duration: this.index === index ? 300 : 0 })
      }
      .padding({ left: index === 0 ? 16 : 0, })

      if (q.displayNewestFlag === 1) {
        Image($r("app.media.ic_home_new"))
          .width(32)
          .height(14)
          .objectFit(ImageFit.Contain)
          .margin({ left: 4 })
      }
    }
    .padding({ right: this.questionTypeList.length === index + 1 ? 54 : 16 })
  }

  build() {
    Stack({ alignContent: Alignment.TopEnd }) { //设置堆叠位置为右上角
      Tabs({ index: this.index }) {
        ForEach(this.questionTypeList, (item: IQuestionType, index: number) => {
          TabContent() {
            QuestionListComp({ typeId: item.id })
          }.tabBar(this.TabItemBuilder(item, index))
        })
      }
      .height(450)
      .divider({
        strokeWidth: $r('app.float.common_border_width'),
        color: $r('app.color.common_gray_border')
      }) //设置tabbar下面的横线样式
      .barMode(BarMode.Scrollable) // 设置tabs可以滚动
      .barHeight(44)
      .onChange(i => this.index = i) // 切换tabbar内容

      Row() {
        // 过滤条件按钮
        Image($r('app.media.ic_home_filter'))
          .width(22)
          .height(44)
          .objectFit(ImageFit.Contain) // 设置图片按照容器大小填满
      }
      .width(54)
      .height(44)
      .justifyContent(FlexAlign.Center) // 图片居中对齐
      .backgroundColor(Color.White) // 设置背景色位白色，使过滤条件图标能遮盖住tabbar的文字
    }
  }
}