import { cart } from '../apis/cart';

export interface MkUser {
  token: string
  nickname: string
  avatar: string
  account: string
}

class Auth {

  KEY: string = 'user'
  // 整个项目中，有且只能初始化一次
  initUser() {
    // 把 AppStorage 的用户信息进行持久化 UI 状态存储，状态改变自动同步到本地磁盘
    PersistentStorage.persistProp<MkUser>(this.KEY,{ } as MkUser)
  }

  getUser() {
    return AppStorage.get<MkUser>(this.KEY) || {} as MkUser
  }

  saveUser(user: MkUser) {
    AppStorage.setOrCreate<MkUser>(this.KEY, user)
    // 登录时，更新购物车数量
    cart.count()
  }

  removeUser() {
    AppStorage.setOrCreate<MkUser>(this.KEY, {} as MkUser)
    // 登录时，更新购物车数量
    cart.count()
  }
}

// 导出实例化对象
export const auth = new Auth()