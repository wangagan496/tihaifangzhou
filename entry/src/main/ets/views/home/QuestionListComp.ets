import { request } from "../../common/utils/request"
import { IListData } from "../../models/HomeModels"
import { QuestionItem, QuestionItemComp } from "./QuestionItemComp"

@Component
export struct QuestionListComp {
  @Prop typeId: number
  // 定义状态属性，类型：QuestionItem[]
  @State list: QuestionItem[] = []

  aboutToAppear(): void {
    this.getListById()
  }

  // 1、HomeCategoryComp传递id
  //  2、在QuestionListComp中请求数据，通过id，必传：questionBankType：10
  // 3、QuestionItemComp，将数据传递给item组件
  async getListById() {
    const res = await request<IListData>({
      url: '/hm/question/list',
      params: {
        type: this.typeId,
        questionBankType: 10
      }
    })
    this.list = res.rows
  }

  build() {
    Column() {
      List() {
        ForEach(this.list, (item: QuestionItem) => {
          ListItem() {
            QuestionItemComp({
              item
            })
              .padding({ left: 10, right: 10 })
          }

        })
      }

    }
    .justifyContent(FlexAlign.Start)
    .layoutWeight(1)
  }
}