@Component
export struct CartView {
  build() {
    Column() {
      Text('Cart')
    }.justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
  }
}