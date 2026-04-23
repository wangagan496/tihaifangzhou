import { audioDB, InterviewAudioItem } from '../../common/utils/AudioDB'
import { auth } from '../../common/utils/Auth'
import { AudioItemComp } from './AudioItemComp'
import { AudioRecordComp } from './AudioRecordComp'
import { promptAction } from '@kit.ArkUI'
import { InputDialog } from './InputDialog'
import { AudioPlayer } from './AudioPlay'

@Component
export struct AudioView {
  @StorageProp('topHeight') topHeight: number = 0
  @State list: InterviewAudioItem[] = []
  @State currentItem: InterviewAudioItem | null = null
  @State isShow: boolean = false
  // 1、拿到弹窗，
  // 2、在AudioView中实例化弹窗，name使用当前的currentItem.name赋值，回填
  // 3、弹窗提交事件，拿到name，更新item.name，更新数据库，获取list
  dialog = new CustomDialogController({
    builder: InputDialog({
      name: this.currentItem?.name,
      onSubmit: (name: string) => {
        const item = this.currentItem
        item!.name = name
        audioDB.update(item!)
          .then(() => {
            this.getList()
              .then(() => {
                this.dialog.close()
              })
          })
      }
    }),
    customStyle: true
  })

  aboutToAppear(): void {
    audioDB.initStore()
      .then(() => {
        this.getList()
      })
  }

  // 获取录音列表方法
  async getList() {
    this.list = await audioDB.query(auth.getUser()?.id!)
  }

  // 1、获取录音列表 getList
  // 2、页面创建时加载数据，插入数据后加载数据

  // 1、AudioRecordComp 麦克风按钮点击切换录制状态，
  // 2、定义startTime ，onRecordEnd方法，获取录音时长，保存录音信息，回传给父组件，
  // 3、父组件AudioVIew 初始化数据库，插入添加的数据
  build() {
    Navigation() {
      Column() {
        Column() {
          List() {
            ForEach(this.list, (item: InterviewAudioItem) => {
              ListItem() {
                AudioItemComp({
                  item
                })
              }.swipeAction({
                end: this.ListItemSwiperBuilder(item)
              })
              .onClick(() => {
                this.currentItem = item
                this.isShow = true
              })
            })
          }
          .width('100%')
          .height('100%')
        }
        .width('100%')
        .layoutWeight(1)

        AudioRecordComp({
          onRecordEnd: (i: InterviewAudioItem) => {
            audioDB.insert(i)
              .then(() => {
                this.getList()
              })
              .catch(() => {
                promptAction.openToast({ message: '保存失败' + JSON.stringify(i) })
              })
          }
        })
      }
      .width('100%')
      .height('100%')
    }.titleMode(NavigationTitleMode.Mini)
    .title('音频')
    .padding({ top: this.topHeight })
    .bindSheet($$this.isShow, this.audioPlayBuilder())

  }

  @Builder
  audioPlayBuilder() {
    Column() {
      AudioPlayer({
        item: this.currentItem!
      })
    }
  }

  // 增加Builder
  @Builder
  ListItemSwiperBuilder(item: InterviewAudioItem) {
    Row() {
      Text('编辑')
        .actionButton($r('app.color.common_blue'))
        .onClick(() => {
          this.currentItem = item
          this.dialog.open()
        })
      Text('删除')
        .actionButton('#FF0033')
        .onClick(() => {
          // 1、给listItem一个swipeAction属性，end：this.ListItemSwiperBuilder(item)
          // 2、删除item，调用audioDB.delete方法，删除成功后重新获取list
          audioDB.delete(item.id!)
            .then(() => {
              this.getList()
            })
        })
    }
    .height('100%')
  }
}

// 配套的 Extend
@Extend(Text)
function actionButton(color: ResourceColor) {
  .width(80)
  .aspectRatio(1)
  .backgroundColor(color)
  .textAlign(TextAlign.Center)
  .fontColor($r('app.color.white'))
}