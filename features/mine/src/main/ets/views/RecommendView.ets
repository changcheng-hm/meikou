import { FormIdManager, getGuessLikeApi, LoadImageForFormData, MkGoodsItem, MkNavbar } from 'basic'
import formBindingData from '@ohos.app.form.formBindingData';
import formProvider from '@ohos.app.form.formProvider';

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

@Builder
function RecommendViewBuilder() {
  RecommendView()
}

@Component
export struct RecommendView {
  @Consume
  pageStack: NavPathStack
  @StorageProp('guessList')
  list: MkGoodsItem[] = []

  aboutToAppear(): void {
    this.getData()
  }

  async getData() {
    const res = await getGuessLikeApi()
    this.list = shuffleArray(res.data.result.items)
    const imageUrls = this.list.slice(0, 2).map(v => v.picture as string)
    const downLoad = new LoadImageForFormData(
      getContext(),
      imageUrls,
      (formInfo: formBindingData.FormBindingData) => {
        FormIdManager.getFormIdList().forEach((formId) => {
          formProvider.updateForm(formId, formInfo)
        })
      }
    )
  }

  build() {
    NavDestination() {
      Column() {
        Column() {
          this.topBanner()
          // 轮播图
          Column() {
            Swiper(this.swiperController) {
              ForEach(
                this.list,
                (item: MkGoodsItem) => {
                  Column() {
                    Image(item.picture)
                      .width('100%')
                    Text(item.name)
                      .margin({
                        top: 10
                      })
                      .fontSize(14)
                      .fontColor('#434343')

                    Text(`￥${item.price}`)
                      .margin({
                        top: 10
                      })
                      .fontSize(20)
                      .fontColor('#191919')
                      .fontWeight(700)
                  }
                  .padding(30)
                  .backgroundColor('#fff')
                }
              )
            }
            .width(270)
            .borderRadius(16)
            .indicator(
              new DotIndicator()
                .itemWidth(6)
                .itemHeight(6)
                .selectedItemWidth(6)
                .selectedItemHeight(6)
                .color('#E9E8EC')
                .selectedColor('#191919')
            )
          }
          .margin({
            top: -60
          })
        }
        .height('80%')
        .justifyContent(FlexAlign.Start)
        .linearGradient({
          angle: 180,
          colors: [
            ['#51E1F8', 0],
            ['#F5F4F9', 1]
          ]
        })

        Row() {
          Row() {
            Text('换一批看看')
              .fontSize(16)
              .fontColor('#fff')
              .onClick(() => {
                this.getData()
              })
          }
          .width('100%')
          .height(46)
          .justifyContent(FlexAlign.Center)
          .backgroundColor('#00C6C6')
          .onClick(() => {

          })
        }
        .width('100%')
        .padding({
          left: 16,
          right: 16
        })
        .layoutWeight(1)
        .backgroundColor('#F5F4F9')
      }
    }
    .hideTitleBar(true)

  }

  // 顶部banner
  @Builder
  topBanner() {
    Stack({ alignContent: Alignment.TopStart }) {
      Image($r("app.media.ic_public_hot_banner_bg"))
        .width('100%')
      MkNavbar({
        bg: Color.Transparent,
        leftClickHandler: () => {
          this.pageStack.pop()
        }
      })
    }
  }

  // 轮播图
  swiperController: SwiperController = new SwiperController()
}