export interface MkUser {
  token: string
  nickname: string
  avatar: string
  account: string
}

export const KEY: string = 'user'

class Auth {
  // 整个项目中，有且只能初始化一次
  initUser() {
    // 把 AppStorage 的用户信息进行持久化 UI 状态存储，状态改变自动同步到本地磁盘
    PersistentStorage.persistProp<MkUser>(KEY,{ } as MkUser)
  }

  getUser() {
    return AppStorage.get<MkUser>(KEY) || {} as MkUser
  }

  saveUser(user: MkUser) {
    AppStorage.setOrCreate<MkUser>(KEY, user)
  }

  removeUser() {
    AppStorage.setOrCreate<MkUser>(KEY, {} as MkUser)
  }
}

// 导出实例化对象
export const auth = new Auth()