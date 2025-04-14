import { CategoryItem, MkGoodsItem, RequestAxios } from 'basic'
// 数据类型已经提供好了
import { Banner, HotResult } from '../viewmodel/index'

export const getBannerApi = () => {
  return RequestAxios.get<Banner[]>('/home/banner')
}

export const getCategoryApi = () => {
  return RequestAxios.get<CategoryItem[]>('/home/category/head')
}

// 首页-特惠推荐
export const getHotPreferenceApi = () => {
  return RequestAxios.get<HotResult>('/hot/preference')
}

// 首页-爆款推荐
export const getHotInVogueApi = () => {
  return RequestAxios.get<HotResult>('/hot/inVogue')
}

// 首页-一站买全
export const getHotOneStopApi = () => {
  return RequestAxios.get<HotResult>('/hot/oneStop')
}

// 获取新鲜好物数据
export const getNewApi = () => {
  return RequestAxios.get<MkGoodsItem[]>('/home/new')
}

export const getRecommendApi = (limit: number = 8) => {
  return RequestAxios.get<MkGoodsItem[]>('/home/recommend', { params: { limit } })
}