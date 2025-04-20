import { AbilityConstant, ConfigurationConstant, UIAbility, Want } from '@kit.AbilityKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { window } from '@kit.ArkUI';
import {
  auth,
  BreakpointConstants,
  FormIdManager,
  getGuessLikeApi,
  KEY,
  LoadImageForFormData, Logger, MkGoodsItem, MKNavPathStack } from 'basic';
import { deviceInfo } from '@kit.BasicServicesKit';
import { rpc } from '@kit.IPCKit';
import { formBindingData, formProvider } from '@kit.FormKit';

const DOMAIN = 0x0000;

// 方案一：Fisher-Yates洗牌算法（推荐）
function shuffleArray<T>(arr: Array<T> | null): Array<T> {
  if (!arr || arr.length <= 1) {
    return arr ? [...arr] : [];
  }

  const shuffled = [...arr];
  for (let i: number = shuffled.length - 1; i > 0; i--) {
    const j: number = Math.floor(Math.random() * (i + 1));
    // 使用中间变量交换元素
    const temp: T = shuffled[i];
    shuffled[i] = shuffled[j];
    shuffled[j] = temp;
  }
  return shuffled;
}

// 卡片通讯的call事件的类型
class Params implements rpc.Parcelable {
  marshalling(messageSequence: rpc.MessageSequence): boolean {
    return true;
  }

  unmarshalling(messageSequence: rpc.MessageSequence): boolean {
    return true;
  }
}

export default class EntryAbility extends UIAbility {
  private curBp: string = ''
  private targetPage: string = ''

  // 根据当前窗口尺寸更新断点
  private updateBreakpoint(windowWidth: number): void {
    // 将长度的单位由px换算为vp
    let windowWidthVp = px2vp(windowWidth)
    let newBp: string = ''
    if (windowWidthVp < 320) {
      newBp = BreakpointConstants.XS
    } else if (windowWidthVp < 600) {
      newBp = BreakpointConstants.SM
    } else if (windowWidthVp < 840) {
      newBp = BreakpointConstants.MD
    } else {
      newBp = BreakpointConstants.LG
    }
    if (this.curBp !== newBp) {
      this.curBp = newBp
      // 使用状态变量记录当前断点值
      AppStorage.setOrCreate(BreakpointConstants.BREAK_POINT_KEY, this.curBp)
    }
  }

  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    this.context.getApplicationContext().setColorMode(ConfigurationConstant.ColorMode.COLOR_MODE_NOT_SET);
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onCreate');
    if (want.parameters?.targetPage) {
      this.targetPage = want.parameters.targetPage as string
    }

    class ParamsForm {
      formId: string = ""
    }

    // 刷新卡片图片数据
    this.callee.on("RefreshImgList", (data: rpc.MessageSequence) => {
      const dataObj = JSON.parse(data.readString()) as Record<string, string>
      getGuessLikeApi()
        .then((res)=>{
          const list = shuffleArray(res.data.result.items)
          AppStorage.setOrCreate('guessList', list)
          const imageList = list.map(item => item.picture as string).slice(0, 2)
          const downLoad = new LoadImageForFormData(
            this.context,
            imageList,
            (formInfo: formBindingData.FormBindingData) => {
              formProvider.updateForm(dataObj.formId, formInfo)
            })
          downLoad.startLoad()
        })

      // 只是为了不报错
      return new Params();
    })

    // 保存首选项所需的context参数
    FormIdManager.context = this.context
    this.callee.on('formIdChange', (data: rpc.MessageSequence) => {
      const dataObj = JSON.parse(data.readString()) as Record<string, string>
      FormIdManager.addFormId(dataObj.formId)
      return new Params()
    })
  }

  onDestroy(): void {
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onDestroy');
  }

  onWindowStageCreate(windowStage: window.WindowStage): void {
    // Main window is created, set main page for this ability
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onWindowStageCreate')
    windowStage.getMainWindow()
      .then((windowObj) => {
        // 获取应用启动时的窗口尺寸
        this.updateBreakpoint(windowObj.getWindowProperties()
          .windowRect
          .width)
        // 注册回调函数，监听窗口尺寸变化
        windowObj.on('windowSizeChange', (windowSize) => {
          this.updateBreakpoint(windowSize.width)
        })
      })
    if (deviceInfo.deviceType != '2in1') {
      // 开启全屏
      const win = windowStage.getMainWindowSync()
      win.setWindowLayoutFullScreen(true)

      // 获取规避区域
      const top = win.getWindowAvoidArea(window.AvoidAreaType.TYPE_SYSTEM).topRect
      AppStorage.setOrCreate<number>('safeTop', px2vp(top.height))
      const bottom = win.getWindowAvoidArea(window.AvoidAreaType.TYPE_NAVIGATION_INDICATOR).bottomRect
      AppStorage.setOrCreate<number>('safeBottom', px2vp(bottom.height))
    }
    // 把 AppStorage 的用户信息进行持久化 UI 状态存储，状态改变会自动同步到本地磁盘
    PersistentStorage.persistProp(KEY, { });
    windowStage.loadContent('pages/Index', (err) => {
      // 持久化存储用户信息
      auth.initUser()
      if (err.code) {
        hilog.error(DOMAIN, 'testTag', 'Failed to load the content. Cause: %{public}s', JSON.stringify(err))
        return
      }
      hilog.info(DOMAIN, 'testTag', 'Succeeded in loading the content.')
    })
    if(this.targetPage) {
      MKNavPathStack.pushPath({
        name: this.targetPage
      })
    }
  }

  onNewWant(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    // Logger.info(want)
    if(want.parameters?.params) {
      MKNavPathStack.pushPath({
        name: want.parameters.targetPage as string
      })

      MKNavPathStack.setInterception({
        willShow: (from: NavDestinationContext | NavBar, to: NavDestinationContext | NavBar) => {
          if(from !== 'navBar' && to !== 'navBar') {
            if((from as NavDestinationContext).pathInfo.name === (to as NavDestinationContext).pathInfo.name) {
              MKNavPathStack.pop()
            }
          }
        }
      })
    }

  }

  onWindowStageDestroy(): void {
    // Main window is destroyed, release UI related resources
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onWindowStageDestroy')
  }

  onForeground(): void {
    // Ability has brought to foreground
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onForeground')
  }

  onBackground(): void {
    // Ability has back to background
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onBackground')
  }
}