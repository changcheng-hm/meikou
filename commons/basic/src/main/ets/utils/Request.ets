import axios, { InternalAxiosRequestConfig, AxiosError, AxiosResponse, AxiosRequestConfig } from '@ohos/axios'
import { promptAction } from '@kit.ArkUI'
import { auth } from './Auth'
import { MKNavPathStack } from './MKNavPathStack'
import { Logger } from './Logger'

// 增加类型
export interface APIErrorType {
  message: string
  msg: string
  code: string
}

// 实例化 通用配置
export const axiosInstance = axios.create({
  baseURL: 'https://meikou-api.itheima.net',
  timeout: 5000
})

// 拦截器配置
// 请求拦截器
// token配置等
axiosInstance.interceptors.request.use((config: InternalAxiosRequestConfig) => {
  const user = auth.getUser()
  if (user.token) {
    config.headers['Authorization'] = `Bearer ${user.token}`
    // config.headers['Authorization'] = `dsafsdafsafd32fdvfdgerwqw`
  }
  return config
}, (error: AxiosError) => {

  return Promise.reject(error)
})


// 添加响应拦截器
// 错误统一处理等
axiosInstance.interceptors.response.use((response: AxiosResponse) => {
  return response
}, (error: AxiosError<APIErrorType>) => {
  Logger.error(error)
  // 400 打印错误信息
  if (error.response?.status == 400) {
    // 打印错误信息
    promptAction.showToast({
      message: error.response.data.message
    })
  } else if (error.response?.status == 401) {
    promptAction.showToast({
      message: '登录过期'
    })
    // 删除 用户信息 去登录页
    auth.removeUser()
    MKNavPathStack.pushPathByName('LoginView', null)
  }
  return Promise.reject(error)
})

// 后端返回的数据格式 code, msg, result
interface HttpResponse<T = string> {
  code: string
  msg: string
  result: T
  message?: string
}

// AxiosResponse 是 axios 响应类型
export type ResponseType<T> = AxiosResponse<HttpResponse<T>>

export class RequestAxios {
  // get -> params -> { params: {} }
  static get<T>(url: string, config?: AxiosRequestConfig): Promise<ResponseType<T>> {

    return axiosInstance.get<null, ResponseType<T>>(url, config)
  }

  // post -> data -> { data: {} }
  static post<T>(url: string, data?: object): Promise<ResponseType<T>> {
    return axiosInstance.post<null, ResponseType<T>>(url, data)
  }

  static delete<T>(url: string, data?: object): Promise<ResponseType<T>> {
    return axiosInstance.delete<null, ResponseType<T>>(url, data)
  }

  static put<T>(url: string, data?: object): Promise<ResponseType<T>> {
    return axiosInstance.put<null, ResponseType<T>>(url, data)
  }
}

