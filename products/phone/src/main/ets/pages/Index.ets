import { auth, BreakpointConstants, BreakPointType, CartKey, EmitterKey, MKNavPathStack } from 'basic';
import { emitter } from '@kit.BasicServicesKit';
import { CategoryView } from 'category';
import { HomeView } from 'home';
import { MineView } from 'mine';
import { CartView } from 'cart';

interface TabItem {
  text: string;
  normal: ResourceStr;
  active: ResourceStr;
}

@Entry
@Component
struct Index {
  @State activeIndex: number = 0;
  list: TabItem[] = [
    { text: '首页', normal: $r('app.media.ic_public_home_normal'), active: $r('app.media.ic_public_home_active') },
    { text: '分类', normal: $r('app.media.ic_public_pro_normal'), active: $r('app.media.ic_public_pro_active') },
    { text: '购物袋', normal: $r('app.media.ic_public_cart_normal'), active: $r('app.media.ic_public_cart_active') },
    { text: '我的', normal: $r('app.media.ic_public_my_normal'), active: $r('app.media.ic_public_my_active') },
  ];
  // 断点工具
  @StorageProp(BreakpointConstants.BREAK_POINT_KEY)
  breakPoint: string = BreakpointConstants.SM;
  // 底部安全区
  @StorageProp('safeBottom')
  safeBottom: number = 0;
  @Provide
  pageStack: NavPathStack = MKNavPathStack;
  @StorageProp(CartKey)
  count: number = 0;
  tabsController = new TabsController();

  @Builder
  TabItemBuilder(item: TabItem, index: number) {
    Badge({
      count: index === 2 && auth.getUser()
        .token ? this.count : 0,
      style: {}
    }) {
      Column() {
        Image(this.activeIndex === index ? item.active : item.normal)
          .width(24)
          .aspectRatio(1);
        Text(item.text)// 跨 HSP 访问资源，需要在 oh-package.json5中导入
          .fontColor($r('[basic].color.black'))
          .fontSize(12);
      }
      .justifyContent(FlexAlign.SpaceEvenly)
      .height(50);
    };
  }

  build() {
    Navigation(this.pageStack) {
      Column() {
        Tabs({ barPosition: BarPosition.End, controller: this.tabsController, index: $$this.activeIndex }) {
          ForEach(this.list, (item: TabItem, index: number) => {
            TabContent() {
              if (index === 0) {
                HomeView()
              } else if (index === 1) {
                CategoryView()
              } else if (index === 2) {
                CartView()
              } else {
                MineView()
              }
            }
            .tabBar(this.TabItemBuilder(item, index))
          })
        }
        .scrollable(false)
        .vertical(this.breakPoint === BreakpointConstants.LG ? true : false)
        .barPosition(new BreakPointType({
          sm: BarPosition.End,
          md: BarPosition.End,
          lg: BarPosition.Start
        }).getValue(this.breakPoint))
        .onTabBarClick(index => {
          this.activeIndex = index;
          if (index === 2) {
            emitter.emit(EmitterKey.REFRESH_LIST);
          }
        })
        .padding({ bottom: this.safeBottom });
      };
    }
    .hideTitleBar(true)
    .mode(NavigationMode.Stack);
  }
}