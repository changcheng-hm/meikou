import { HmSku, HmSpec, MkGoodsItem } from '@mk/basic';

export interface Banner {
  id: string;
  imgUrl: string;
  type: string;
}


export interface Params {
  title: string,
  subTitle: string,
  bg: ResourceStr,
  list: MkGoodsItem[]
}

export interface HotResult {
  id: string;
  subTypes: SubType[];
  title: string;
}

export interface SubType {
  goodsItems: GoodsItems;
  id: string;
  title: string;
}

export interface GoodsItems {
  counts: number;
  items: MkGoodsItem[];
  page: number;
  pages: number;
  pageSize: number;
}

class BasicDataSource implements IDataSource {
  private listeners: DataChangeListener[] = [];
  private originDataArray: object[] = [];

  public totalCount(): number {
    return 0;
  }

  public getData(index: number): object {
    return this.originDataArray[index];
  }

  // 该方法为框架侧调用，为LazyForEach组件向其数据源处添加listener监听
  registerDataChangeListener(listener: DataChangeListener): void {
    if (this.listeners.indexOf(listener) < 0) {
      console.info('add listener');
      this.listeners.push(listener);
    }
  }

  // 该方法为框架侧调用，为对应的LazyForEach组件在数据源处去除listener监听
  unregisterDataChangeListener(listener: DataChangeListener): void {
    const pos = this.listeners.indexOf(listener);
    if (pos >= 0) {
      console.info('remove listener');
      this.listeners.splice(pos, 1);
    }
  }

  // 通知LazyForEach组件需要重载所有子组件
  notifyDataReload(): void {
    this.listeners.forEach(listener => {
      listener.onDataReloaded();
    })
  }

  // 通知LazyForEach组件需要在index对应索引处添加子组件
  notifyDataAdd(index: number): void {
    this.listeners.forEach(listener => {
      listener.onDataAdd(index);
    })
  }

  // 通知LazyForEach组件在index对应索引处数据有变化，需要重建该子组件
  notifyDataChange(index: number): void {
    this.listeners.forEach(listener => {
      listener.onDataChange(index);
    })
  }

  // 通知LazyForEach组件需要在index对应索引处删除该子组件
  notifyDataDelete(index: number): void {
    this.listeners.forEach(listener => {
      listener.onDataDelete(index);
    })
  }

  // 通知LazyForEach组件将from索引和to索引处的子组件进行交换
  notifyDataMove(from: number, to: number): void {
    this.listeners.forEach(listener => {
      listener.onDataMove(from, to);
    })
  }
}

export class MKDataSource extends BasicDataSource {
  private dataArray: object[] = [];

  public totalCount(): number {
    return this.dataArray.length;
  }

  public getData(index: number): object {
    return this.dataArray[index];
  }

  public getAllData(): object[] {
    return this.dataArray;
  }

  public addData(index: number, data: object): void {
    this.dataArray.splice(index, 0, data);
    this.notifyDataAdd(index);
  }

  public pushData(data: object): void {
    this.dataArray.push(data);
    this.notifyDataAdd(this.dataArray.length - 1);
  }

  public reloadData(data: object[]) {
    this.dataArray = data
    this.notifyDataReload()
  }
}

// 查询的结果类型
export interface SearchResult {
  // conditions: Conditions;
  pageData: GoodsItems;
}

export interface GoodsProperty {
  name: string;
  value: string;
}

export interface GoodsDetail {
  pictures: string[];
  properties: GoodsProperty[];
}

export interface Goods extends MkGoodsItem {
  inventory: number
  mainPictures: string[]
  details: GoodsDetail
  specs: HmSpec[]
  skus: HmSku[]
}