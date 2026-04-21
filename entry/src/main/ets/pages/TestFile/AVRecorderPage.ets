import { media } from '@kit.MediaKit'
import { fileIo } from '@kit.CoreFileKit'
import { permission } from '../../common/utils/Permission'
import { promptAction } from '@kit.ArkUI'
import { Permissions } from '@kit.AbilityKit'
import { AudioBoComp } from '../../views/AudioPage/AudioBoComp'

@Entry
@Component
struct AVRecorderPage {
  // 权限
  permissions: Permissions[] = ['ohos.permission.MICROPHONE']
  // 弹框提示
  confirmConfig: promptAction.ShowDialogOptions = {
    title: "温馨提示",
    message: "未授权使用麦克风将无法使用该面试录音功能，是否前往设置进行授权？",
    buttons: [
      { text: '离开', color: $r('app.color.common_gray_01') },
      { text: '去授权', color: $r('app.color.common_blue') }
    ]
  }

  async getPermission() {
    try {
      // 第一次授权
      const isOk = await permission.requestPermissions(this.permissions)
      if (isOk) {
        return
      }
      const confirm = await this.getUIContext().getPromptAction().showDialog(this.confirmConfig)
      if (confirm.index === 1) {
        // 第二次授权
        const isAllow = await permission.onSettingPermissions(this.permissions)
        if (isAllow) {
          return
        }
      }
      this.getUIContext().getRouter().back()
    } catch (e) {
      promptAction.openToast({ message: '未授权' })
        .then(() => {
          this.getUIContext().getRouter().back()
        })

    }
  }

  aboutToAppear(): void {
    this.getPermission()
  }

  avRecorder: media.AVRecorder | null = null
  fd: number | null = null
  filePath: string = ''
  // 1、准备变量：振幅，定时器ID
  @State maxAmplitude: number = 0
  timerId: number | null = null

  // 2、导入显示振幅的组件

  // 3、使用api动态获取振幅，开始录制之后
  // 4、停止录制之后，关闭定时器


  async startRecord() {
    this.avRecorder = await media.createAVRecorder()
    let avProfile: media.AVRecorderProfile = {
      audioBitrate: 112000, // 音频比特率。
      audioChannels: 2, // 音频声道数。
      audioCodec: media.CodecMimeType.AUDIO_AAC, // 音频编码格式。
      aacProfile: media.AacProfile.AAC_HE, // 音频编码扩展格式。
      audioSampleRate: 48000, // 音频采样率。
      fileFormat: media.ContainerFormatType.CFT_MPEG_4A, // 封装格式。
    };
    const ctx = AppStorage.get<Context>('context')
    let filePath = ctx?.cacheDir + '/' + Date.now() + '.mp3'
    this.filePath = filePath
    const file = fileIo.openSync(filePath, fileIo.OpenMode.READ_WRITE | fileIo.OpenMode.CREATE)
    this.fd = file.fd

    let avConfig: media.AVRecorderConfig = {
      audioSourceType: media.AudioSourceType.AUDIO_SOURCE_TYPE_MIC, // 音频输入源，这里设置为麦克风。
      profile: avProfile,
      url: 'fd://' + this.fd.toString(), // 参考应用文件访问与管理中的开发示例获取创建的音频文件fd填入此处。
    };

    await this.avRecorder.prepare(avConfig)
    await this.avRecorder.start()
    this.timerId = setInterval(async () => {
      this.maxAmplitude = await this.avRecorder?.getAudioCapturerMaxAmplitude()!
    }, 100)
  }

  build() {
    Column({ space: 20 }) {
      Button('录制')
        .onClick(() => {
          this.startRecord()
        })
      Button('停止录制')
        .onClick(() => {
          this.avRecorder?.stop()
          this.avRecorder?.release()
          fileIo.closeSync(this.fd)
          clearInterval(this.timerId)
        })
      AudioBoComp({ maxAmplitude: this.maxAmplitude })
    }
    .height('100%')
    .width('100%')
  }
}