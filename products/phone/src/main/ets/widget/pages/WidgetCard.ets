const storage = new LocalStorage()

@Entry(storage)
@Component
struct WidgetCard {
  @State
  rotateAngle: string | number = 0;
  @LocalStorageProp('formId') @Watch('formIdChange') formId: string = ''
  @LocalStorageProp('fileNameList') fileNameList: string[] = []
  @LocalStorageProp('formImages') formImages: string[] = []

  formIdChange() {
    postCardAction(this, {
      action: 'call',
      abilityName: 'EntryAbility',
      params: {
        method: 'formIdChange',
        formId: this.formId,
      }
    })
  }

  build() {
    Column() {
      Row() {
        Text('今日推荐')
          .fontColor('#fff')
          .fontSize(16)
        Image($r('app.media.ic_public_refresh'))
          .fillColor(Color.White)
          .width(30)
          .rotate({angle: this.rotateAngle})
          .animation({
            duration: 1000,
            onFinish: () => {
              this.rotateAngle = 0
            }
          })
          .onClick(() => {
            this.rotateAngle = 360 * 2
            postCardAction(this, {
              action: 'call',
              abilityName: 'EntryAbility', // 只能拉起当前应用下的UIAbility
              params: {
                method: 'RefreshImgList',
                formId: this.formId,
              }
            });
          })
      }
      .height(40)
      .width('100%')
      .justifyContent(FlexAlign.SpaceBetween)
      .padding({
        left: 5,
        right: 5
      })

      Row() {
        ForEach(
          this.fileNameList,
          (url: string) => {
            Row() {
              Image('memory://' + url)
                .borderRadius(12)
                .width(50)
                .aspectRatio(1)
            }
            .backgroundColor('#eee')
            .borderRadius(12)
          }
        )
      }
      .justifyContent(FlexAlign.SpaceBetween)
      .width('100%')
      .layoutWeight(1)
      .padding({
        left: 20,
        right: 20
      })
      .backgroundColor('#fff')
      .borderRadius({
        topRight: 16,
        topLeft: 16
      })
      .onClick(() => {
        postCardAction(this, {
          action: 'router',
          abilityName: 'EntryAbility',
          params: {
            targetPage: 'RecommendView'
          }
        });
      })
    }
    .linearGradient({
      angle: '135',
      colors: [
        ['#FD3F8F', 0],
        ['#FF773C', 1]
      ]
    })
    .height('100%')
  }
}