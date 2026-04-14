interface iRouterParams {
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

  aboutToAppear(): void {

  }

  build() {
    Navigation() {
      Column({ space: 15 }) {
        TextInput({ placeholder: '回车搜索', text: $$this.keyword })
          .onSubmit(() => {
            //todo: 保存数据
          })

        Row() {
          Text('搜索记录').fontSize(20).fontWeight(800)

          Row() {
            if (this.isDel) {
              Text('全部删除')
                .onClick(() => {
                  // 3.  删除全部

                  // 4. 同步回硬盘中

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


            // 2. 同步到硬盘中

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