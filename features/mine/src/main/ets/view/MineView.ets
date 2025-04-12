@Component
export struct MineView {
  build() {
    Column() {
      Text('Mine')
    }.justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
  }
}