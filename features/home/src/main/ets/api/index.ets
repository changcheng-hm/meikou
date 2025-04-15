import { CategoryItem, MkGoodsItem, RequestAxios } from 'basic'
// 数据类型已经提供好了
import { Banner, HotResult, SearchResult } from '../viewmodel/index'
import { SearchParams } from '../views/SearchResultView';

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

/**
 * 商品搜索API接口
 *
 * @param data - 搜索参数对象，包含以下字段：
 *               - keyword: 搜索关键词
 *               - categoryId: 商品分类ID（可选）
 *               - sortType: 排序方式（可选）
 *               - pageSize: 分页大小
 *               - pageNum: 页码
 * @returns 返回Promise对象，resolve时携带搜索结果对象，包含：
 *          - total: 总结果数
 *          - list: 商品数据列表
 *          - pageNum: 当前页码
 *          - pageSize: 每页数量
 */
export const searchGoodsApi = (data: SearchParams) => {
  // 发起POST请求到搜索接口，携带分页参数和搜索条件
  return RequestAxios.post<SearchResult>('/search/all', data)
}
