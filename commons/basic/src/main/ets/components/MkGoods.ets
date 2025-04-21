import { MkGoodsItem } from '../viewmodel'

@Reusable
@Component
export struct MkGoods {
  @Prop
  goods: MkGoodsItem = {} as MkGoodsItem
  smallImage: boolean = false
  @Consume
  pageStack: NavPathStack

  aboutToReuse(params: Record<string, Object>): void {
    this.goods = params.goods as MkGoodsItem
    // Logger.debug('Reuse')
  }

  aboutToRecycle(): void {
    // Logger.debug('Recycle')
  }

  aboutToAppear(): void {
    // Logger.debug('Appear')
  }

  aboutToDisappear(): void {
    // Logger.debug('Disappear')
  }

  build() {
    Column({ space: 10 }) {
      if (this.smallImage) {
        Row() {
          Image(this.goods.picture)
            .width('100%')
            .aspectRatio(1)
        }
        .width('100%')
        .padding(20)
      } else {
        Image(this.goods.picture)
          .width('100%')
          .aspectRatio(1)
      }
      Text(this.goods.name)
        .fontSize(14)
        .fontColor($r('app.color.text'))
        .maxLines(2)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
        .width('100%')
        .padding({ left: 10, right: 10 })
      Row({ space: 4 }) {
        Text('¥' + Number(this.goods.price))
          .fontSize(14)
          .fontWeight(FontWeight.Bold)
          .fontColor($r('app.color.black'))
        Text('¥999')
          .fontSize(8)
          .fontColor($r('app.color.gray'))
          .decoration({ type: TextDecorationType.LineThrough, color: $r('app.color.gray') })
        Blank()
        Text('2.9万+人付款')
          .fontSize(10)
          .fontColor($r('app.color.gray'))
      }
      .alignItems(VerticalAlign.Bottom)
      .width('100%')
      .margin({ bottom: 10 })
      .padding({ left: 10, right: 10 })
    }
    .width('100%')
    .backgroundColor($r('app.color.white'))
    .borderRadius(8)
    .clip(true)
    .onClick(() => {
      this.pageStack.pushPathByName('GoodsView', this.goods)
    })
  }
}