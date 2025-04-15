import { BreakpointConstants, BreakPointType, CategoryItem, CategoryItemChild, MkNavbar } from 'basic'

@Component
export struct CategoryView {
  //  Mock分类数据
  @StorageProp('categoryData')
  categories: CategoryItem[] = []
  // 当前高亮索引
  @State activeIndex: number = 0
  // 滚动控制器
  scroller: Scroller = new Scroller()

  // 通过 AppStorage 获取断点值
  @StorageProp(BreakpointConstants.BREAK_POINT_KEY) currentBreakpoint: string = BreakpointConstants.SM

  build() {
    Column() {
      MkNavbar({
        title: '分类',
        showLeftIcon: false,
        showRightIcon: true,
        rightIcon: $r('[basic].media.ic_public_search'),
        rightClickHandler: () => {
          AlertDialog.show({message: '点击了搜索'})
        },
      })
        .border({width: { bottom: 0.5}, color: $r('[basic].color.under')})

      Row() {
        Column() {
          ForEach(this.categories, (item: CategoryItem, i) => {
            Text(item.name)// 文本
              .backgroundColor(this.activeIndex === i ? $r('[basic].color.black') : $r('[basic].color.white'))
              .fontSize(14)
              .fontColor(this.activeIndex === i ? $r('[basic].color.white') : $r('[basic].color.black'))
              .textAlign(TextAlign.Center)
              .width('100%')
              .height(56)
              .onClick(() => {
                this.activeIndex = i
                // 切换菜单时，滚动到顶部
                this.scroller.scrollTo({ yOffset: 0, xOffset: 0, animation: true })
              })

          })
        }
        .width(88)
        .border({ width: { right: 0.5 }, color: $r('[basic].color.under') })

        Scroll(this.scroller) {
          Column() {
            // 顶部图片
            Image(this.categories[this.activeIndex]?.picture)
              .width('100%')
              .height(new BreakPointType({
                sm: 136,
                md: 200,
                lg: 220,
              }).getValue(this.currentBreakpoint))
              .objectFit(ImageFit.Contain)
              .backgroundColor('#f6f6f6')
              .borderRadius(8)
              .margin({ bottom: 8 })
            GridRow({ columns: {
              sm: 2,
              md: 3,
              lg: 4,
            }, gutter: 8 }) {
              // 子分类
              ForEach(this.categories[this.activeIndex]?.children, (sub: CategoryItemChild) => {
                GridCol() {
                  Column() {
                    // 图片
                    Image(sub.picture)
                      .width(64)
                      .aspectRatio(1)
                    Text(sub.name)// 文本
                      .fontSize(14)
                      .fontColor($r('[basic].color.text'))
                      .margin({ top: 8 })
                  }
                  .height('100%')
                  .justifyContent(FlexAlign.Center)
                }
                .aspectRatio(1)
                .backgroundColor('#f6f6f6')
                .borderRadius(8)
              })
            }
          }
          .padding(8)
        }
        .layoutWeight(1)
        .scrollBar(BarState.Off)
        .edgeEffect(EdgeEffect.Spring)
      }
      .layoutWeight(1)
      .alignItems(VerticalAlign.Top)
    }
    .width('100%')
    .height('100%')
  }
}