@Component
export struct HomeView {
  build() {
    Column() {
      Text('Home')
    }.justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
  }
}