@Component
export struct CategoryView {
  build() {
    Column() {
      Text('Category')
    }.justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
  }
}