import { emitter } from '@kit.BasicServicesKit'

// 断点相关常量
export class BreakpointConstants {
  // 手表等超小屏
  static readonly XS: string = 'xs';
  // 手机竖屏
  static readonly SM: string = 'sm';
  // 手机横屏，折叠屏
  static readonly MD: string = 'md';
  // 平板，2in1 设备
  static readonly LG: string = 'lg';
  // AppStorage 中的 key
  static readonly BREAK_POINT_KEY: string = 'currentBreakpoint'
  static readonly GRID_ROW_COLUMNS: number[] = [4, 8, 12, 15, 11, 3, 6];
  /**
   * Grid column span list.
   */
  static readonly GRID_COLUMN_SPANS: number[] = [2, 3, 4, 8, 12, 5, 7];
  /**
   * Breakpoint ranges.
   */
  static readonly BREAKPOINT_RANGES: number[] = [320, 600, 840];
}


export class EmitterKey {
  // 切换到指定的 tab
  static CHANGE_TAB: emitter.InnerEvent = { eventId: 10001 }
  // 刷新购物车列表
  static REFRESH_LIST: emitter.InnerEvent = { eventId: 10002 }
  // 更新地址
  static REFRESH_ADDRESS: emitter.InnerEvent = { eventId: 10003 }
}