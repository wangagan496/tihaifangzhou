import { LoadingDialog } from "../../common/components/LoadingDialog"
import { request } from "../../common/utils/request"
import { IListData } from "../../models/HomeModels"
import { QuestionItem, QuestionItemComp } from "./QuestionItemComp"
import { FaultLogExtensionAbility } from "@kit.PerformanceAnalysisKit"

@Component
export struct QuestionListComp {
  @Prop typeId: number
  // 定义状态属性，类型：QuestionItem[]
  @State list: QuestionItem[] = []
  // 控制刷新
  @State refreshing: boolean = false
  page: number = 0
  totalPage: number = 1
  // 请求中
  isRequesting: boolean = false

  // 1、HomeCategoryComp传递id
  //  2、在QuestionListComp中请求数据，通过id，必传：questionBankType：10
  // 3、QuestionItemComp，将数据传递给item组件

  async loadData(isLoadMore: boolean) {
    if (isLoadMore) {
      // 加载更多
      if (this.page >= this.totalPage) {
        this.isRequesting = false
        return
      }
      this.page++
      this.dialog.open()
    } else {
      // 刷新
      this.page = 1
    }
    // 请求数据,共用内容
    const res = await request<IListData>({
      url: '/hm/question/list',
      params: {
        type: this.typeId,
        questionBankType: 10,
        page: this.page
      }
    })
    this.totalPage = res.pageTotal

    if (isLoadMore) {
      // 加载更多
      this.list.push(...res.rows)
      this.isRequesting = false
      this.dialog.close()
    } else {
      // 刷新
      this.list = res.rows
      this.refreshing = false
    }
  }

  // 自定义弹窗
  dialog = new CustomDialogController({
    builder: LoadingDialog({ message: '加载中...' }),
    customStyle: true,
  })

  build() {
    Column() {
      Refresh({ refreshing: $$this.refreshing }) {
        List() {
          ForEach(this.list, (item: QuestionItem) => {
            ListItem() {
              QuestionItemComp({
                item
              })
                .padding({ left: 10, right: 10 })
            }
          })
        }.layoutWeight(1)
        .onReachEnd(() => {
          if (!this.isRequesting && this.page < this.totalPage) {
            this.loadData(true)
          }
        })
      }.layoutWeight(1)
      .onRefreshing(() => {
        this.loadData(false)
      })

    }
    .justifyContent(FlexAlign.Start)
    .layoutWeight(1)
  }
}