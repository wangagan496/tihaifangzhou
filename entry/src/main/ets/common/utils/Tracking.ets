import { TimeItem } from '../../models/HomeModels';
import { tgRequest } from './request';
import { preferences } from '@kit.ArkData';
import { contextManager } from './ContextManager';

class Tracking {
  private timeItem: TimeItem = {} as TimeItem

  start(id: string): void {
    this.timeItem.questionId = id
    this.timeItem.startTime = Date.now()
  }

  save(): Promise<void> {
    this.timeItem.endTime = Date.now()
    const context = contextManager.getCtx()
    if (!context) {
      return Promise.resolve()
    }
    const trackFile = preferences.getPreferencesSync(context, { name: 'trackFile' })
    const list = trackFile.getSync('list', []) as TimeItem[]
    list.push(this.timeItem)
    if (list.length < 5) {
      trackFile.putSync('list', list)
      trackFile.flushSync()
      return Promise.resolve()
    }
    return tgRequest({ url: '/hm/time/tracking', method: 'POST', data: { timeList: list } }).then((): void => {
      trackFile.putSync('list', [])
      trackFile.flushSync()
    }, (): void => {
      trackFile.putSync('list', list)
      trackFile.flushSync()
    })
  }
}

export const tracking = new Tracking();
