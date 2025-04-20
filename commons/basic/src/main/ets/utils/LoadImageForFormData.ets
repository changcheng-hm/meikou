import { formBindingData } from '@kit.FormKit'
import { request } from '@kit.BasicServicesKit'
import { fileIo } from '@kit.CoreFileKit'


// 作用：下载需要的图片资源 然后把图片资源处理为下发给card组件使用的标准格式
class FormData {
  // 卡片 地址数组
  fileNameList: string[]
  // 卡片 信息
  formImages: Record<string, string | number>

  constructor(fileNameList: string[], formImages: Record<string, string | number>) {
    this.fileNameList = fileNameList
    this.formImages = formImages
  }
}

// 图片下载的工具类
export class LoadImageForFormData {
  // 要下载的图片列表
  private imageUrls: string[]
  // 图片下载完毕执行函数
  private finishCb: (formInfo: formBindingData.FormBindingData) => void
  // 当前Ability
  private abilityContext: Context
  // 当前正在下载的图片下标
  private curIndex: number = 0
  // 本地地址
  private tempDir: string = ''
  // 内存中的图片对象
  private formImages: Record<string, string | number> = {}
  // 图片文件的名称列表
  private fileNameList: string[] = []
  // 初始FormData数据
  initialFormData = new FormData([], {})

  /**
   * 构造函数
   *
   * @param abilityContext 上下文对象，用于访问应用程序的全局信息
   * @param imageUrls 图片URL数组，用于存储将要展示的图片资源地址
   * @param finishCb 完成回调函数，当表单数据提交时调用，用于处理提交的数据
   */
  constructor(
    abilityContext: Context,
    imageUrls: string[],
    finishCb: (formInfo: formBindingData.FormBindingData) => void,
  ) {
    // 存储图片URL数组
    this.imageUrls = imageUrls
    // 存储完成回调函数
    this.finishCb = finishCb
    // 存储上下文对象
    this.abilityContext = abilityContext
    // 临时目录（缓存目录）
    this.tempDir = abilityContext.getApplicationContext()
      .tempDir
  }

  // 动态添加要下载的图片
  addImage(imageUrls: string[]) {
    this.imageUrls = imageUrls
    return this
  }

  // 开始下载图片
  startLoad() {
    if (this.imageUrls.length === 0) {
      console.error('please provide download imglist')
      return
    }

    let netFile = this.imageUrls[this.curIndex] // 需要在此处使用真实的网络图片下载链接
    let fileName = 'file' + Date.now() + '.jpg'
    let tmpFile = this.tempDir + '/' + fileName // 完整的临时目录路径
    // tmpFile: /data/storage/el2/base/temp/fileXxx.jpg
    request.downloadFile(
      this.abilityContext,
      {
        url: netFile, // 在线地址，指定要下载的文件在线URL
        filePath: tmpFile, // 保存到哪里，指定文件下载到本地的路径
        enableMetered: true, // 允许在流量受限的网络下下载，如移动数据网络
        enableRoaming: true // 允许在漫游网络下下载
      }
    )
      .then((task) => {
        // 开始下载图片了
        // on complete 下载完成
        task.on('complete', () => {
          try {
            // 根据本地路径，打开下载的图片文件
            const file = fileIo.openSync(tmpFile)
            // 保存打开图片文件的 fd
            this.formImages[fileName] = file.fd
          } catch (e) {
            console.error(`openSync failed: ${JSON.stringify(e)}`)
          }
          // 保存图片信息
          this.fileNameList.push(fileName)

          // 索引累加
          this.curIndex++
          // 判断是否还需继续加载
          if (this.curIndex < this.imageUrls.length) {
            // 如果还没下载完毕，继续下载
            this.startLoad()
          } else {
            // 全部下载完毕更新数据
            this.initialFormData.fileNameList = this.fileNameList
            this.initialFormData.formImages = this.formImages
            // 创建绑定给卡片的数据
            let formInfo = formBindingData.createFormBindingData(this.initialFormData)
            // 将包装好的图片信息，通过回调函数 传递出去，让外部可以接受并传递给卡片
            this.finishCb(formInfo)
          }
        })
      })
      .catch(() => { })
  }
}

// 页面使用 需要 new 创建实例后再使用