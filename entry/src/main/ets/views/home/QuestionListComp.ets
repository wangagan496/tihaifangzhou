import { LoadingDialog } from "../../common/components/LoadingDialog"
import { request } from "../../common/utils/request"
import { IListData } from "../../models/HomeModels"
import { QuestionItem, QuestionItemComp } from "./QuestionItemComp"

@Component
export struct QuestionListComp {
  @Prop typeId: number
  // 定义状态属性，类型：QuestionItem[]
  @State list: QuestionItem[] = []
  // 控制刷新
  @State refreshing: boolean = false
  page: number = 0
  total: number = 1
  // 请求中
  isRequesting: boolean = false

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

  async onFresh() {
    await this.getListById()
    this.refreshing = false
    this.page = 1
    this.isRequesting = false
  }

  async onLoadMore() {
    if (this.isRequesting === true) {
      return
    }
    this.isRequesting = true

    if (this.total <= this.list.length) {
      return
    }
    this.page++
    console.log('this.page---', this.page)
    this.dialog.open()
    const res = await request<IListData>({
      url: '/hm/question/list',
      params: {
        type: this.typeId,
        questionBankType: 10,
        page: this.page
      }
    })
    this.dialog.close()
    console.log('res.rows---', res.rows)
    this.total = res.total
    this.list.push(...res.rows)
    this.isRequesting = false
  }

  // 1、列表项不居顶问题，给list加高度
  // 2、Refresh组件，onRefreshing
  // 3、状态变量，refreshing，控制下拉刷新


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
          this.onLoadMore()
        })
      }.layoutWeight(1)
      .onRefreshing(() => {
        this.onFresh()
      })

    }
    .justifyContent(FlexAlign.Start)
    .layoutWeight(1)
  }
}