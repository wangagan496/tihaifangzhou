import { LoadingDialog } from "../../common/components/LoadingDialog"
import { request } from "../../common/utils/request"
import { IListData } from "../../models/HomeModels"
import { QuestionItem, QuestionItemComp } from "./QuestionItemComp"
import { FaultLogExtensionAbility } from "@kit.PerformanceAnalysisKit"
import { FilterParams } from "./QuestionFilterComp"

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
  // 监听参数变化
  @Watch('onFilterParamsChange')
  @Prop params: FilterParams
  selfIndex: number = 0

  onFilterParamsChange() {
    this.loadData(false)
  }

  // 1、给列表传递selfIndex
  // 2、比较selfIndex和params.index，如果相同则加载数据

  async loadData(isLoadMore: boolean) {
    if (this.selfIndex !== this.params.index) {
      return
    }

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
        page: this.page,
        sort: this.params.sort,
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
                .onClick(()=>{
                  this.getUIContext().getRouter().pushUrl({
                    url:'pages/QuestionDetailPage',
                    params: {
                      id: item.id
                    }})
                })
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