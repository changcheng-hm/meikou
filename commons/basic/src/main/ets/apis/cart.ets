import { auth } from '../utils/Auth';
import { RequestAxios } from '../utils/Request'
import { CartGoods } from '../viewmodel';

interface UpdateParams {
  selected?: boolean
  count?: number
}

interface AddParams {
  skuId: string
  count: number
}

interface CountResult {
  count: number
}

interface CheckAllParams {
  selected: boolean
}

// 删除的参数
interface DeleteParams {
  ids: string[]
}

export class Cart {
  // AppStorage 的 Key
  CartKey: string = 'cartCount'
  // 添加
  add(data: AddParams) {
    return RequestAxios.post<null>('/member/cart', data)
  }

  // 获取购物车数量
  async count() {
    let count = 0
    // 用户已登录才发请求获取
    const userInfo = auth.getUser()
    if (userInfo.token) {
      // 获取购物车数量
      const res = await RequestAxios.get<CountResult>('/member/cart/count')
      // 更新变量，用于全局存储
      count = res.data.result.count
    }
    // 全局存储购物车数量
    AppStorage.setOrCreate(this.CartKey, count)
  }

  // 获取列表
  async list() {
    return RequestAxios.get<CartGoods[]>('/member/cart')
  }

  // 更新商品
  async update(skuId: string, data: UpdateParams) {
    return RequestAxios.put<CartGoods>(`/member/cart/${skuId}`, data)
  }

  // 全选
  async checkAll(data: CheckAllParams) {
    return RequestAxios.put<null>('/member/cart/selected', data)
  }

  // 删除
  async remove(data: DeleteParams) {
    return RequestAxios.delete<null>('/member/cart', data)
  }
}

export const cart = new Cart()