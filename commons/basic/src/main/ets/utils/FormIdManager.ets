import { preferences } from '@kit.ArkData'
import { Context } from '@kit.AbilityKit'

const FormIDKEY = 'mk_shop_formId_key'
const PreferName = 'mk_shop_formId'

export class FormIdManager {
  static context: Context

  // 获取store
  static getStore() {
    return preferences.getPreferencesSync(FormIdManager.context || getContext(), {
      name: PreferName
    })
  }

  // 存储卡片ID
  static async addFormId(formId: string) {
    const store = FormIdManager.getStore()
    const list = FormIdManager.getFormIdList()
    if (!list.some(id => id === formId)) {
      list.push(formId)
    }
    store.putSync(FormIDKEY, JSON.stringify(list))
    await store.flush()
  }

  // 获取卡片ID数组
  static getFormIdList() {
    const store = FormIdManager.getStore()
    return JSON.parse(store.getSync(FormIDKEY, '[]') as string) as string[]
  }

  static async delFormId(formId: string) {
    const store = FormIdManager.getStore()
    const list = FormIdManager.getFormIdList()
    const index = list.findIndex(id => id === formId)
    list.splice(index, 1)
    store.putSync(FormIDKEY, JSON.stringify(list))
    await store.flush()
  }
}