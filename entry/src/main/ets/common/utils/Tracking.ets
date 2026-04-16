import { TimeItem } from '../../models/HomeModels';
import { tgRequest } from './request';
import { promptAction } from '@kit.ArkUI';
import { preferences } from '@kit.ArkData';
import { contextManager } from './ContextManager';

// 积累五条数据上报一次
class Tracking {
  private timeItem: TimeItem = {} as TimeItem

  // 记录
  start(id: string) {
    this.timeItem.questionId = id
    this.timeItem.startTime = Date.now()
  }

  // 上报
  async save() {
    this.timeItem.endTime = Date.now()

    const trackFile = preferences.getPreferencesSync(contextManager.getCtx(), { name: 'trackFile' })
    const list = trackFile.getSync('list', []) as TimeItem[]
    list.push(this.timeItem)
    if (list.length === 5) {
      await tgRequest({ url: '/hm/time/tracking', method: 'POST', data: { timeList: list } })
      promptAction.openToast({ message: '上报成功' })
        .then(() => {
          trackFile.putSync('list', [])
          trackFile.flushSync()
        })
    } else {
      trackFile.putSync('list', list)
      trackFile.flushSync()
    }

  }
}


export const tracking = new Tracking();