import { Logger, permissionPlugin } from 'basic';
import { window, KeyboardAvoidMode, promptAction } from '@kit.ArkUI'
import { searchGoodsApi } from '../api';
import { AudioSearchComp, VoiceState } from '../components/AudioSearchComp';
import { speechRecognizer } from '@kit.CoreSpeechKit';
import { audio } from '@kit.AudioKit';

// 1.1 子页的入口函数，必须以 @Builder 修饰
@Builder
function SearchViewBuilder() {
  // 1.2 子页结构需要用 NavDestination 包裹
  NavDestination() {
    // 页面结构封装成组件
    SearchView()
  }
  .hideTitleBar(true) // 隐藏默认标题栏
}

@Component
export struct SearchView {
  @StorageProp('safeTop') safeTop: number = 0
  @State keyword: string = ''
  @Consume pageStack: NavPathStack

  async aboutToAppear() {
    const isOk = await permissionPlugin.requestPermissions(['ohos.permission.MICROPHONE'])
    if(!isOk) {
      const isOk2 = await permissionPlugin.requestPermissionOnSetting(['ohos.permission.MICROPHONE'])
      if (!isOk2) {
        promptAction.showToast({message: 'no microphone permission'})
      }
    }
    window.getLastWindow(getContext())
      .then((win) => {
        win.setWindowSystemBarProperties({ statusBarContentColor: '#FFFFFF' })
        win.getUIContext().setKeyboardAvoidMode(KeyboardAvoidMode.RESIZE)
      })
  }

  aboutToDisappear(): void {
    window.getLastWindow(getContext())
      .then((win) => {
        win.setWindowSystemBarProperties({ statusBarContentColor: '#000000' })
      })
  }

  build() {
    Column() {
      // search
      Row() {
        // 返回按钮
        Image($r('[basic].media.ic_public_left'))
          .width(24)
          .aspectRatio(1)
          .fillColor($r('[basic].color.white'))
          .margin(13)
          .onClick(() => {
            // 返回上一页
            this.pageStack.pop()
          })

        // 搜索框
        Search({ placeholder: '商品关键字...', value: this.keyword })
          .searchIcon({ src: $r('[basic].media.ic_public_search'), color: $r('[basic].color.gray') })
          .placeholderColor($r('[basic].color.gray'))
          .placeholderFont({ size: 14 })
          .searchButton('搜索', { fontSize: 14, fontColor: $r('[basic].color.red') })
          .backgroundColor($r('[basic].color.white'))
          .textFont({ size: 14 })
          .layoutWeight(1)
          .padding(0)
          .margin(0)
          .height(36)
          .caretStyle({ color: $r('[basic].color.red') })
          .defaultFocus(true)
          .onSubmit((value) => {
            this.pageStack.pushPathByName('SearchResultView', value)
          })
      }
      .padding({ top: this.safeTop, right: 16 })
      .linearGradient({
        angle: 135,
        colors: [[$r('[basic].color.linear_begin'), 0], [$r('[basic].color.linear_end'), 1]]
      })

      // 语音搜索组件
      AudioSearchComp()
    }
  }
}