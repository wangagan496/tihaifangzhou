import { preferences } from '@kit.ArkData';
import { promptAction } from '@kit.ArkUI';
import { FilterParams } from '../views/home/QuestionFilterComp';
import { QuestionListComp } from '../views/home/QuestionListComp';

interface IRouterParams {
  keywordText: string
}

@Entry
@Component
struct SearchPage {
  @State message: string = 'Hello World';
  @State keyword: string = ''
  @StorageProp('topHeight') topHeight: number = 0
  @State isDel: boolean = false
  @State list: string[] = []
  @State isInput: boolean = false
  // 1、创建首选项数据库仓库
  // 【用户首选项-初始化】获取名为 'history' 的偏好设置实例
  // 数据存储在应用私有目录，应用卸载时自动清除
  historyFile = preferences.getPreferencesSync(this.getUIContext().getHostContext(), { name: 'history' })

  aboutToAppear(): void {
    // 2、获取搜索关键字
    let params = this.getUIContext().getRouter().getParams() as IRouterParams
    if (params) {
      this.keyword = params.keywordText
    }
    //  3、获取搜索历史数据
    this.list = this.historyFile.getSync('list', []) as string[]
  }

  onInputSubmit() {
    // 1、验证输入
    if (this.keyword.trim() === '') {
      promptAction.openToast({ message: '请输入内容' })
      return
    }
    // 2、去重
    const oldIndex = this.list.findIndex(item => item === this.keyword)
    if (oldIndex !== -1) {
      this.list.splice(oldIndex, 1)
    }
    // 3、list添加数据
    this.list.unshift(this.keyword)
    // 4、同步数据到硬盘中
    this.historyFile.putSync('list', this.list)
    this.historyFile.flushSync() // 持久化
    // 5、清空输入框
    this.keyword = ''
    // 6、退出输入模式
    this.isInput = false
  }

  build() {
    Navigation() {
      Column({ space: 15 }) {
        TextInput({ placeholder: '回车搜索', text: $$this.keyword })
          .onSubmit(() => {
            //todo: 保存数据
            this.onInputSubmit()
          })
          .onClick(() => {
            this.isInput = true
          })

        if (this.isInput) {
          Row() {
            Text('搜索记录').fontSize(20).fontWeight(800)

            Row() {
              if (this.isDel) {
                Text('全部删除')
                  .onClick(() => {
                    // 3.  删除全部
                    this.list = []
                    // 4. 同步回硬盘中
                    this.historyFile.putSync('list', this.list)
                    this.historyFile.flushSync()

                  })
                Text(' | ')
                Text('取消删除')
                  .onClick(() => {
                    this.isDel = false
                  })
              }


              Image($r('app.media.ic_common_delete'))
                .height(28)
                .onClick(() => {
                  this.isDel = true
                })
            }
          }
          .width('100%')
          .justifyContent(FlexAlign.SpaceBetween)

          Flex({ wrap: FlexWrap.Wrap }) {
            ForEach(this.list, (item: string) => {
              this.itemBuilder(item)
            })
          }
        } else {
          // todo: 显示搜索结果
          QuestionListComp({
            typeId: 0,
            selfIndex: 0,
            params: new FilterParams(),
            keyword: this.keyword
          })

        }
      }
      .padding(15)
    }
    .titleMode(NavigationTitleMode.Mini)
    .title('搜索页面')
    .padding({ top: this.topHeight })
  }

  @Builder
  itemBuilder(text: string) {
    Row({ space: 20 }) {
      Text(text)
      if (this.isDel) {
        Text('x')
          .height(30)
          .onClick(() => {
            // 1. 点谁通过index删除谁
            const index = this.list.findIndex(item => item === text)
            this.list.splice(index, 1)
            // 2. 同步到硬盘中
            this.historyFile.putSync('list', this.list)
            this.historyFile.flushSync()
          })
      }

    }
    .margin({ right: 10, top: 10 })
    .padding({
      left: 15,
      right: 15,
      top: 5,
      bottom: 5
    })
    .backgroundColor('rgba(0,0,0,0.05)')
    .borderRadius(20)
  }
}