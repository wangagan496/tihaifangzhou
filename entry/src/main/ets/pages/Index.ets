import { hilog } from '@kit.PerformanceAnalysisKit';
import { Logger } from '../common/utils/Logger';

@Entry
@Component
struct Index {
  @State message: string = 'Hello World';

  build() {
    Column({ space: 20 }) {

      Button('hilog.info测试').onClick(() => {
        // 普通的info日志，使用info方法来打印
        // 第一个参数：0x0000 表示当前日志的域为0
        // 第二个参数：表示此系统的日志过滤关键字为 mylog,可以在deveco的日志面板中去过滤查看日志
        // 第三个参数：%{public}s表示以明文的形式来显示字符串日志
        // 第四个及其以后的参数：表示要打印的日志
        Logger.info('info111')
      })

      Button('hilog.debug测试').onClick(() => {
        // debug表示调试日志，将来上线之后不会被执行
        Logger.debug('debug111')
      })

      Button('hilog.warn测试').onClick(() => {
        // 警告日志
        Logger.warn('warn111')
      })

      Button('hilog.error测试').onClick(() => {
        // 错误日志，当代码出错时调用
        Logger.error('error111')
      })
    }.width('100%')
    .height('100%')
  }
}