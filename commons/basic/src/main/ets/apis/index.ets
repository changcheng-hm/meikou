import { RequestAxios } from '../utils/Request';
import { GoodsItems } from '../viewmodel';

// 默认值为 6
export const getGuessLikeApi = (limit: number = 6) => {
  return RequestAxios.get<GoodsItems>('/home/goods/guessLike', {
    params: {
      limit
    }
  })
}
