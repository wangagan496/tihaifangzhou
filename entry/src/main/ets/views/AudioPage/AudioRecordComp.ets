import { media } from '@kit.MediaKit'
import { fileIo } from '@kit.CoreFileKit'
import { AudioBoComp } from './AudioBoComp'
import { auth } from '../../common/utils/Auth'
import dayjs from 'dayjs'
import { InterviewAudioItem } from '../../common/utils/AudioDB'

@Component
export struct AudioRecordComp {
  @StorageProp('bottomHeight') bottomHeight: number = 0
  avRecorder?: media.AVRecorder
  fd?: number
  filePath?: string
  timer?: number
  @State maxAmplitude: number = 0
  // 设置录制状态
  @State recording: boolean = false
  // 开始时间
  startTime: number = 0
  // 录制结束回传数据
  onRecordEnd: (item: InterviewAudioItem) => void = () => {

  }

  async startRecord() {
    // 1. 准备一个文件接收录音
    const ctx = this.getUIContext().getHostContext()!
    const filePath = ctx.filesDir + '/' + Date.now() + '.m4a'
    this.filePath = filePath
    const file = fileIo.openSync(filePath, fileIo.OpenMode.CREATE | fileIo.OpenMode.READ_WRITE)
    this.fd = file.fd
    // 2. 准备路由配置对象
    const config: media.AVRecorderConfig = {
      audioSourceType: media.AudioSourceType.AUDIO_SOURCE_TYPE_MIC,
      profile: {
        audioBitrate: 100000, // 音频比特率
        audioChannels: 1, // 音频声道数
        audioCodec: media.CodecMimeType.AUDIO_AAC, // 音频编码格式，当前只支持aac
        audioSampleRate: 48000, // 音频采样率
        fileFormat: media.ContainerFormatType.CFT_MPEG_4A, // 封装格式，当前只支持m4a
      },
      url: `fd://${file.fd}`
    }
    // 3. 开始录制
    const avRecorder = await media.createAVRecorder()
    await avRecorder.prepare(config)
    await avRecorder.start()
    this.avRecorder = avRecorder
    // 4. 每100ms获取一下声音振幅
    this.timer = setInterval(async () => {
      this.maxAmplitude = await avRecorder.getAudioCapturerMaxAmplitude()
    }, 100)
  }

  async stopRecord() {
    if (this.avRecorder) {
      clearInterval(this.timer)
      await this.avRecorder.stop()
      await this.avRecorder.release()
      fileIo.closeSync(this.fd)
      this.maxAmplitude = 0
    }
  }

  build() {
    Column() {
      AudioBoComp({ maxAmplitude: this.maxAmplitude })
      Row() {
        Image($r('sys.media.ohos_ic_public_voice'))
          .width(24)
          .aspectRatio(1)
          .fillColor($r('app.color.white'))
          .onClick(async () => {
            // TODO 开始和停止录音
            if (this.recording) {
              this.stopRecord() // ✅正确写法
              // ❎错误写法，由于在stopRecord当中将文件关闭，若是将stopRecord变成同步代码
              // 将无法获取到文件对象，因此让stopRecord异步执行即可
              // await this.stopRecord()

              this.recording = false
              const file = fileIo.statSync(this.fd)
              this.onRecordEnd({
                id: null,
                user_id: auth.getUser()!.id,
                name: dayjs().format('YYYY年MM月DD日_HH点mm分ss秒'),
                path: this.filePath!,
                duration: Date.now() - this.startTime,
                size: file.size,
                create_time: Date.now()
              })

            } else {
              this.startRecord()
              this.recording = true
              this.startTime = Date.now()
            }
          })
      }
      .justifyContent(FlexAlign.Center)
      .height(50)
      .width(50)
      .borderRadius(25)
      .margin({ top: 20 })
      .backgroundColor(this.recording ? Color.Black : $r('app.color.common_blue'))
    }
    .width('100%')
    .height(240)
    .backgroundColor($r('app.color.common_gray_bg'))
    .padding({
      bottom: this.bottomHeight,
      left: 80,
      right: 80,
      top: 20
    })
  }
}



