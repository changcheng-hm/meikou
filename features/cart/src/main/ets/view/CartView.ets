import { auth, MkGuess, MkNavbar, MkUser, MkDialogLoading, CartGoodsModel, CartGoods, MkEmpty, EmitterKey,
  cart } from 'basic'
import { emitter } from '@kit.BasicServicesKit';

// 1.1 路由入口函数
@Builder
function CartViewBuilder() {
  // 1.2 子路由组件
  NavDestination() {
    CartView()
  }
  .hideTitleBar(true)
}

@Component
export struct CartView {
  // 用户信息
  @StorageProp(auth.KEY) user: MkUser = {} as MkUser
  // 商品信息
  @State cartList: CartGoodsModel[] = []
  // 页面栈
  @Consume pageStack: NavPathStack
  @State isShowLeftIcon: boolean = false
  // 自定义弹窗
  dialog = new CustomDialogController({
    builder: MkDialogLoading(), // loading
    customStyle: true,
  })

  // 获取数据
  async getData() {
    if (!auth.getUser()
      .token) {
      return
    }
    this.dialog.open()
    const res = await cart.list()
    this.cartList = res.data.result.map((v: CartGoods) => new CartGoodsModel(v))
    this.dialog.close()
  }

  aboutToAppear(): void {
    // 获取页面参数
    this.isShowLeftIcon = this.pageStack.getParamByName('CartView').pop() as boolean

    this.getData()
  }

  onCheckOrder() {
    AlertDialog.show({
      message: '去结算'
    })
  }

  // 获取是否全选
  isCheckAll() {
    return this.cartList.every(v => v.selected)
  }

  // 定义
  totalCount() {
    return this.cartList.filter(v => v.selected)
      .reduce((pre, item) => pre + item.count * item.price, 0)
      .toFixed(2)
  }

  @Builder
  DeleteBuilder(onDelete: () => void) {
    Text('删除')
      .fontSize(14)
      .width(60)
      .height(100)
      .backgroundColor($r('[basic].color.red'))
      .fontColor($r('[basic].color.white'))
      .textAlign(TextAlign.Center)
      .onClick(() => {
        onDelete()
      })
  }

  build() {
    Column() {
      MkNavbar({ title: '购物袋',
        showRightIcon: true,
        showLeftIcon: this.isShowLeftIcon,
        leftClickHandler: () => {
          this.pageStack.pop()
        }
      })
        .border({
          width: { bottom: 0.5 },
          color: '#e4e4e4'
        })
      List() {
        if (this.user.token) {

          if (this.cartList.length) {
            ForEach(this.cartList, (item: CartGoodsModel, index: number) => {
              ListItem() {
                CartItemComp({
                  cart: item,
                  onChangeSelected: selected => {
                    // 更新数据
                    // 更新页面
                  },
                  onChangeCount: count => {
                    // 更新数据
                    // 更新页面
                  }
                })
              }
              .backgroundColor($r('[basic].color.under'))
              .padding({ left: 8, right: 8 })
              .transition({ type: TransitionType.Delete, opacity: 0 })
              .swipeAction({
                end: this.DeleteBuilder(async () => {
                  AlertDialog.show({
                    title: '温馨提示',
                    message: '确定删除该商品吗？',
                    buttons: [
                      { value: '取消', fontColor: $r('[basic].color.gray'), action: () => { } },
                      {
                        value: '确定', fontColor: $r('[basic].color.black'), action: async () => {
                          this.dialog.open()
                          // 服务器端删除，根据 skuId 删除商品
                          await cart.remove({ ids: [item.skuId] })
                          // 本地删除
                          this.cartList.splice(index, 1)
                          // 更新购物袋数量
                          await cart.count()
                          this.dialog.close()
                        }
                      },
                    ]
                  })
                })
              })
            }, (cart: CartGoods) => cart.skuId)
          } else {
            ListItem() {
              MkEmpty({
                tip: '购物袋是空的~',
                buttonText: '去逛逛',
                onClickButton: () => {
                  // 发送事件
                  emitter.emit(EmitterKey.CHANGE_TAB, {
                    data: {
                      index: 0
                    }
                  })
                }
              })
            }
          }
        } else {
          // 未登录
          ListItem() {
            MkEmpty({
              tip: '购物袋是空的~',
              buttonText: '去逛逛',
              onClickButton: () => {
                // 发送事件
                emitter.emit(EmitterKey.CHANGE_TAB, {
                  data: {
                    index: 0
                  }
                })
              }
            })
          }
        }
        ListItem() {
          MkGuess()
            .margin({ top: 8, bottom: 8 })
        }

      }
      .contentStartOffset(8)
      .width('100%')
      .layoutWeight(1)
      .scrollBar(BarState.Off)

      if (this.cartList.length) {
        Row() {
          Checkbox()
            .selectedColor($r('[basic].color.red'))
            .select(this.isCheckAll())
            .onClick(async () => {
              this.dialog.open()
              const isCheckAllRes = this.isCheckAll()
              // 更新服务器的数据
              await cart.checkAll({ selected: !isCheckAllRes })
              // 更新本地数据
              this.cartList.forEach((item) => {
                item.selected = !isCheckAllRes
              })
              // 数组浅拷贝，主动触发 this.cartList 更新，从而使合计价格主动更新
              this.cartList = this.cartList.slice()
              this.dialog.close()
            })
          Text('全选')
            .fontSize(14)
            .fontColor($r('[basic].color.black'))
            .margin({ right: 20 })
          Text('合计:')
            .fontSize(14)
            .fontColor($r('[basic].color.black'))
            .margin({ right: 2 })
          Text(this.totalCount())
            .fontSize(16)
            .fontWeight(500)
            .fontColor($r('[basic].color.red'))
            .layoutWeight(1)
          Button('去结算')
            .fontSize(14)
            .height(36)
            .backgroundColor($r('[basic].color.red'))
            .onClick(() => {

            })
        }
        .height(50)
        .width('100%')
        .backgroundColor($r('[basic].color.white'))
        .border({
          width: { top: 0.5, bottom: 0.5 },
          color: '#e4e4e4'
        })
        .padding({ left: 16, right: 16 })
      }
    }
    .height('100%')
    .width('100%')
    .backgroundColor($r('[basic].color.under'))
    .onVisibleAreaChange([0, 1], (isVisible) => {
      if (isVisible) {
        this.getData()
      }
    })
  }
}

@Component
struct CartItemComp {
  @Prop cart: CartGoodsModel
  onChangeSelected: (selected: boolean) => void = () => {

  }
  onChangeCount: (count: number) => void = () => {

  }
  dialog = new CustomDialogController({
    builder: MkDialogLoading({ message: '' }),
    customStyle: true,
    alignment: DialogAlignment.Center,
  })

  build() {
    Row({ space: 10 }) {

      Checkbox()
        .selectedColor($r('[basic].color.red'))
        .size({ width: 14, height: 14 })
        .select(this.cart.selected)
        .onClick(async () => {
          this.dialog.open()
          await cart.update(this.cart.skuId, { selected: !this.cart.selected })
          // 更新本地的
          this.cart.selected = !this.cart.selected
          this.dialog.close()
          // 通知父组件
          this.onChangeSelected(this.cart.selected)
        })
      Image(this.cart.picture)
        .width(80)
        .height(80)
      Column({ space: 8 }) {
        Text(this.cart.name)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .maxLines(1)
          .fontSize(14)
          .fontColor($r('[basic].color.black'))
          .width('100%')
        Row() {
          Text(this.cart.attrsText)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
            .maxLines(1)
            .fontSize(12)
            .fontColor($r('[basic].color.text'))
            .layoutWeight(1)
          Image($r('sys.media.ohos_ic_public_arrow_down'))
            .fillColor($r('[basic].color.gray'))
            .width(16)
            .height(16)
        }
        .padding({ left: 6, right: 4 })
        .width(100)
        .height(24)
        .backgroundColor($r('[basic].color.under'))
        .borderRadius(2)

        Row() {
          Text(`¥${this.cart.price}`)
            .fontSize(14)
            .fontWeight(500)
          // 计数器
          Counter() {
            Text(this.cart.count.toString())
          }
          .enableDec(this.cart.count > 1) // 控制减号是否可用
          .enableInc(this.cart.count < this.cart.stock) // 控制加号是否可用
          .onInc(async () => {
            this.dialog.open()
            // 更新远程服务器数据
            await cart.update(this.cart.skuId, { count: this.cart.count + 1 })
            // 更新本地数据
            this.cart.count += 1
            // 更新购物袋数量
            await cart.count()
            this.dialog.close()
          })
          .onDec(async () => {
            this.dialog.open()
            // 更新远程服务器数据
            await cart.update(this.cart.skuId, { count: this.cart.count - 1 })
            // 更新本地数据
            this.cart.count -= 1
            // 更新购物袋数量
            await cart.count()
            this.dialog.close()
          })
        }
        .width('100%')
        .justifyContent(FlexAlign.SpaceBetween)
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)
    }
    .width('100%')
    .height(100)
    .padding(10)
    .border({ width: { bottom: 0.5 }, color: '#e4e4e4' })
    .backgroundColor($r('[basic].color.white'))
  }
}