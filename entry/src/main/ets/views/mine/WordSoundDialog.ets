import { media } from '@kit.MediaKit'

@CustomDialog
export struct WordSoundDialog {
  controller: CustomDialogController // 必须要有的
  wordEn: string = '' // 英文单词
  wordZh: string = '' // 中文解释
  @State
  isGreen: boolean = false // 用来控制颜色切换的
  timer: number = -1
  streamId: number = -1
  // 1、新建一个弹窗，点击小喇叭，打开弹窗
  // 2、准备AVPlayer，朗读单词
  aVPlayer: media.AVPlayer | null = null

  // 3、http://dict.youdao.com/dictvoice?audio=hello&type=1，用于获取单词的音频
  // 4、监听AVPlayer的状态变化，准备完毕之后开始播放，开启循环播放
  // 5、在弹窗显示的时候开启播放，弹窗消失的时候停止播放
  aboutToAppear() {
    this.startPlay()
  }

  async startPlay() {
    if (this.aVPlayer === null) {
      this.aVPlayer = await media.createAVPlayer()
      this.aVPlayer.url = `http://dict.youdao.com/dictvoice?audio=${this.wordEn}&type=1`
      this.aVPlayer.on('stateChange', (state) => {
        switch (state) {
          case 'initialized': // 初始化完成
            this.aVPlayer?.prepare()
            break;
          case 'prepared': // 准备完成
            this.aVPlayer!.loop = true // 循环播放
            this.aVPlayer?.play() // 开始播放
            break;
        }
      })
    }
  }

  aboutToDisappear() {
    if (this.aVPlayer !== null) {
      this.aVPlayer?.stop() // 停止播放
        .then(() => {
          this.aVPlayer!.release() // 释放资源
        })
    }
  }

  build() {
    Column({ space: 10 }) {
      Row({ space: 10 }) {
        Text(this.wordEn)
          .fontSize(20)
          .fontColor(Color.White)
          .fontWeight(500)
        Image($r('app.media.icon_public_search'))
          .width(20)
          .aspectRatio(1)
          .fillColor(this.isGreen ? $r('app.color.common_green') : Color.White)
          .onAppear(() => {
            clearInterval(this.timer) // 清除之前的定时器
            this.timer = setInterval(() => { //新开一个定时器
              this.isGreen = !this.isGreen
            }, 500)
          })
          .onDisAppear(() => {
            clearInterval(this.timer) //清除定时器
          })
          .animation({ duration: 300 })
      }

      Text(this.wordZh)
        .fontColor(Color.White)
    }
    .constraintSize({ minWidth: 175 })
    .padding({ left: 16, right: 16 })
    .height(90)
    .borderRadius(45)
    .backgroundColor('#8f000000')
    .justifyContent(FlexAlign.Center)
  }
}