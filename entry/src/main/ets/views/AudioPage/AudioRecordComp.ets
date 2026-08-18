import { media } from '@kit.MediaKit'
import { fileIo } from '@kit.CoreFileKit'
import { AudioBoComp } from './AudioBoComp'
import { AudioRecording } from './AudioRecording'

@Component
export struct AudioRecordComp {
  @StorageProp('bottomHeight') bottomHeight: number = 0
  avRecorder?: media.AVRecorder
  fd?: number
  filePath?: string
  timer: number = -1
  @State maxAmplitude: number = 0
  @State recording: boolean = false
  startTime: number = 0
  private amplitudeReading: boolean = false
  private validInputSamples: number = 0
  // The emulator reports a flat ~5-6 when its input route is silent. Keep the
  // guard just above that floor so ordinary low-volume speech is still saved.
  private readonly minimumInputAmplitude: number = 20
  private readonly minimumInputDuration: number = 2000
  private isTransitioning: boolean = false
  onRecordEnd: (recording: AudioRecording) => void = () => {}

  // 音频写入应用沙箱；FD 交给 AVRecorder，停止或失败时必须关闭。
  startRecord(): Promise<boolean> {
    const context = this.getUIContext().getHostContext()
    if (!context) {
      return Promise.resolve(false)
    }
    const path = `${context.filesDir}/${Date.now()}.m4a`
    let file: fileIo.File
    try {
      file = fileIo.openSync(path, fileIo.OpenMode.CREATE | fileIo.OpenMode.READ_WRITE)
    } catch (_) {
      return Promise.resolve(false)
    }
    this.fd = file.fd
    this.filePath = path
    this.validInputSamples = 0
    const config: media.AVRecorderConfig = {
      // Use the explicit microphone source required by the AVRecorder sample.
      // The emulator's host route is still selected by the system AudioPolicy.
      audioSourceType: media.AudioSourceType.AUDIO_SOURCE_TYPE_MIC,
      profile: {
        audioBitrate: 112000,
        audioChannels: 2,
        audioCodec: media.CodecMimeType.AUDIO_AAC,
        aacProfile: media.AacProfile.AAC_LC,
        audioSampleRate: 48000, fileFormat: media.ContainerFormatType.CFT_MPEG_4A
      },
      url: `fd://${file.fd}`
    }
    try {
      return media.createAVRecorder().then((recorder) => {
        return recorder.prepare(config).then(() => {
          return recorder.start().then(() => {
            this.avRecorder = recorder
            this.timer = setInterval(() => { this.readAmplitude(recorder) }, 100)
            return true
          }, () => {
            recorder.release().then(() => {}, () => {})
            this.clearRecordResources()
            return false
          })
        }, () => {
          recorder.release().then(() => {}, () => {})
          this.clearRecordResources()
          return false
        })
      }, () => {
        this.clearRecordResources()
        return false
      })
    } catch (_) {
      this.clearRecordResources()
      return Promise.resolve(false)
    }
  }

  private readAmplitude(recorder: media.AVRecorder): void {
    if (this.amplitudeReading || recorder !== this.avRecorder) {
      return
    }
    this.amplitudeReading = true
    try {
      recorder.getAudioCapturerMaxAmplitude().then((amplitude) => {
        this.maxAmplitude = amplitude
        if (amplitude >= this.minimumInputAmplitude) {
          this.validInputSamples++
        }
        this.amplitudeReading = false
      }, () => {
        this.amplitudeReading = false
      })
    } catch (_) {
      this.amplitudeReading = false
    }
  }

  stopRecord(): Promise<boolean> {
    const recorder = this.avRecorder
    if (!recorder) {
      this.clearRecordResources()
      return Promise.resolve(false)
    }
    this.clearTimer()
    try {
      return recorder.stop().then(() => {
        return recorder.release().then(() => {
          this.avRecorder = undefined
          this.closeFile()
          this.maxAmplitude = 0
          return true
        }, () => {
          this.avRecorder = undefined
          this.closeFile()
          this.maxAmplitude = 0
          return false
        })
      }, () => {
        return recorder.release().then(() => {
          this.avRecorder = undefined
          this.closeFile()
          this.maxAmplitude = 0
          return false
        }, () => {
          this.avRecorder = undefined
          this.closeFile()
          this.maxAmplitude = 0
          return false
        })
      })
    } catch (_) {
      this.clearRecordResources()
      return Promise.resolve(false)
    }
  }

  private clearTimer(): void {
    if (this.timer !== -1) { clearInterval(this.timer); this.timer = -1 }
  }

  private closeFile(): void {
    if (this.fd !== undefined) {
      try {
        fileIo.closeSync(this.fd)
      } catch (_) {
        // A failed recorder transition may already have closed the descriptor.
      }
      this.fd = undefined
    }
  }

  private clearRecordResources(): void {
    this.clearTimer()
    this.closeFile()
    this.avRecorder = undefined
    this.maxAmplitude = 0
    this.validInputSamples = 0
  }

  private discardFile(path: string): void {
    try {
      fileIo.unlinkSync(path)
    } catch (_) {
      // The recorder may already have removed an incomplete output file.
    }
  }

  // 退出页面也统一停止录制、释放 AVRecorder 并关闭文件描述符。
  aboutToDisappear(): void {
    if (this.avRecorder) { this.stopRecord() } else { this.clearRecordResources() }
  }

  private toggleRecord(): void {
    if (this.isTransitioning) { return }
    this.isTransitioning = true
    if (!this.recording) {
      this.startRecord().then((started) => {
        this.isTransitioning = false
        if (!started) { this.showToast('无法开始录音'); return }
        this.startTime = Date.now()
        this.recording = true
      }, () => {
        this.isTransitioning = false
        this.clearRecordResources()
        this.showToast('录音操作失败')
      })
      return
    }
    const path = this.filePath
    const duration = Date.now() - this.startTime
    const hasAudioInput = this.validInputSamples >= 3
    this.stopRecord().then((stopped) => {
      this.isTransitioning = false
      this.recording = false
      if (!stopped || !path) {
        if (path) { this.discardFile(path) }
        this.showToast('录音保存失败')
        return
      }
      if (duration >= this.minimumInputDuration && !hasAudioInput) {
        this.discardFile(path)
        this.showToast('未检测到麦克风输入，请检查模拟器或系统麦克风设置')
        return
      }
      try {
        const file = fileIo.statSync(path)
        this.onRecordEnd({ path, duration, size: file.size, createTime: Date.now() })
      } catch (_) {
        this.discardFile(path)
        this.showToast('无法读取录音文件')
      }
    }, () => {
      this.isTransitioning = false
      this.recording = false
      this.clearRecordResources()
      this.showToast('录音操作失败')
    })
  }

  private showToast(message: string): void {
    try {
      this.getUIContext().getPromptAction().showToast({ message })
    } catch (_) {
      return
    }
  }

  build() {
    Column() {
      AudioBoComp({ maxAmplitude: this.maxAmplitude, active: this.recording })

      Row() {
        Image($r('sys.media.ohos_ic_public_voice'))
          .width(22)
          .aspectRatio(1)
          .fillColor($r('app.color.white'))
          .onClick(() => { this.toggleRecord() })
      }
      .justifyContent(FlexAlign.Center)
      .height(52)
      .width(52)
      .borderRadius(26)
      .margin({ top: 8 })
      .backgroundColor(this.recording ? '#E5484D' : $r('app.color.common_blue'))
      .shadow({ radius: 8, color: this.recording ? '#E5484D44' : '#3A9BFC44', offsetX: 0, offsetY: 3 })

    }
    .width('100%')
    .height(190)
    .backgroundColor('#F7F9FB')
    .border({ width: 1, color: '#E8EDF2' })
    .padding({ bottom: this.bottomHeight + 10, left: 20, right: 20, top: 12 })
  }
}
