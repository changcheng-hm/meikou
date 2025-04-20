import { audio } from '@kit.AudioKit'
import { speechRecognizer } from '@kit.CoreSpeechKit'
import { Logger } from 'basic';
import { promptAction } from '@kit.ArkUI';

export enum VoiceState {
  DEFAULT,
  VOICING,
  VOICEOVER
}

@Component
export struct AudioSearchComp {
  @State voiceState: VoiceState = VoiceState.DEFAULT
  @State keyword: string = ''
  audioCapturer: audio.AudioCapturer | null = null
  asrEngine: speechRecognizer.SpeechRecognitionEngine | null = null
  onChange: (keyword: string) => void = () => { }
  onComplete: (keyword: string) => void = () => { }

  // 开始语音识别
  async startRecord() {
    if(!canIUse('SystemCapability.AI.SpeechRecognizer')) {
      promptAction.showToast({message: '设备不支持语音识别哦'})
      return
    }
    // 初始化语音识别引擎
    this.asrEngine = await speechRecognizer.createEngine({
      language: 'zh-CN', // 中文
      online: 1 // 在线识别
    })
    // 设置回调
    this.asrEngine.setListener({
      // 开始识别成功回调
      onStart(sessionId: string, eventMessage: string) {
        Logger.info(`onStart, sessionId: ${sessionId} eventMessage: ${eventMessage}`);
      },
      // 事件回调
      onEvent(sessionId: string, eventCode: number, eventMessage: string) {
        Logger.info(`onEvent, sessionId: ${sessionId} eventCode: ${eventCode} eventMessage: ${eventMessage}`);
      },
      // 识别结果回调，包括中间结果和最终结果
      onResult(sessionId: string, result: speechRecognizer.SpeechRecognitionResult) {
        Logger.info(`onResult, sessionId: ${sessionId} sessionId: ${JSON.stringify(result)}`);
      },
      // 识别完成回调
      onComplete: (sessionId: string, eventMessage: string) => {
        this.voiceState = VoiceState.DEFAULT
        Logger.info(`onComplete, sessionId: ${sessionId} eventMessage: ${eventMessage}`);
      },
      // 错误回调，错误码通过本方法返回
      onError(sessionId: string, errorCode: number, errorMessage: string) {
        Logger.error(`onError, sessionId: ${sessionId} errorCode: ${errorCode} errorMessage: ${errorMessage}`);
      }
    })

    // 调用开始识别方法
    this.asrEngine?.startListening({
      sessionId: '10000',
      audioInfo: {
        audioType: 'pcm',
        sampleRate: 16000,
        soundChannel: 1,
        sampleBit: 16
      }
    })

    // 录音参数
    const audioStreamInfo: audio.AudioStreamInfo = {
      samplingRate: audio.AudioSamplingRate.SAMPLE_RATE_16000,
      channels: audio.AudioChannel.CHANNEL_1,
      sampleFormat: audio.AudioSampleFormat.SAMPLE_FORMAT_S16LE,
      encodingType: audio.AudioEncodingType.ENCODING_TYPE_RAW
    }
    const audioCapturerInfo: audio.AudioCapturerInfo = {
      source: audio.SourceType.SOURCE_TYPE_MIC,
      capturerFlags: 0
    }
    const audioCapturerOptions: audio.AudioCapturerOptions = {
      streamInfo: audioStreamInfo,
      capturerInfo: audioCapturerInfo
    }
    // 创建录音采集器
    this.audioCapturer = await audio.createAudioCapturer(audioCapturerOptions)
    // 注册事件
    this.audioCapturer.on('readData', (buffer) => {
      // 写入音频流
      this.asrEngine?.writeAudio('10000', new Uint8Array(buffer))
    })
    // 开始录音
    await this.audioCapturer.start()
    // 设置录音状态：录音中
    this.voiceState = VoiceState.VOICING
  }

  // 结束语音识别
  async closeRecord() {
    // 停止录音
    this.audioCapturer?.stop()
    // 释放录音采集器
    this.audioCapturer?.release()
    // 结束识别
    this.asrEngine?.finish('10000')
    // 释放语音识别引擎
    this.asrEngine?.shutdown()
    // 设置录音状态：录音结束
    this.voiceState = VoiceState.VOICEOVER
  }

  build() {
    Column() {
      if (this.voiceState !== VoiceState.DEFAULT) {
        Column({ space: 16 }) {
          if (this.voiceState === VoiceState.VOICING) {
            Text('请说，我在聆听...')
              .fontSize(14)
          } else if (this.voiceState === VoiceState.VOICEOVER && this.keyword === '') {
            Text('未检测到语音，请长按按钮重试')
              .fontSize(14)
          }
          Text() {
            Span('你可以这样说：')
            Span('太阳眼镜/冬款连衣裙')
              .fontColor($r('[basic].color.gray'))
          }
          .fontSize(12)
        }
        .justifyContent(FlexAlign.Center)
        .height(150)
      }
      Blank()
      Button() {
        Row({ space: 4 }) {
          Image($r('sys.media.ohos_ic_public_voice'))
            .width(16)
            .aspectRatio(1)
            .fillColor($r('[basic].color.white'))
          if (this.voiceState === VoiceState.VOICING) {
            Text('松开立即搜索')
              .fontSize(14)
              .fontColor($r('[basic].color.white'))
          } else {
            Text('长按语音搜索')
              .fontSize(14)
              .fontColor($r('[basic].color.white'))

          }
        }
      }
      .padding({ left: 12, right: 12 })
      .height(36)
      .linearGradient({
        angle: 135,
        colors: [[$r('[basic].color.linear_begin'), 0], [$r('[basic].color.linear_end'), 1]]
      })
      .margin({ bottom: 16 })
      .gesture(LongPressGesture()
        .onAction(() => {
          this.startRecord()
        })
        .onActionEnd(() => {
          this.closeRecord()
        })
        .onActionCancel(() => {
          this.closeRecord()
        }))
    }
    .layoutWeight(1)
    .width('100%')
    .backgroundImage($r('app.media.search_bg'))
    .backgroundImageSize(ImageSize.Contain)
    .backgroundImagePosition(Alignment.Bottom)
    .onVisibleAreaChange([0, 1], () => {
      this.keyword = ''
      this.voiceState = VoiceState.DEFAULT
    })
  }
}