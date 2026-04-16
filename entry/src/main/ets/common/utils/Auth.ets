import { ILoginDta } from '../../models/AccountModel';
import { contextManager } from './ContextManager';
import { promptAction, router } from '@kit.ArkUI';

// 1、mine页面判断是否登录，登录了就显示用户信息，没有登录就显示未登录，点击跳转登录页
// 2、用户数据持久化工具类，封装了AppStorage和PersistentStorage，对原来存用户数据取用户数据的操作进行替换
class Auth {
  // 初始化用户信息,确保信息能够持久化
  initUser() {
    PersistentStorage.persistProp('user', {})
  }

  // 保存或修改用户信息
  setUser(user: ILoginDta) {
    AppStorage.set('user', user)
  }

  // 获取用户信息
  getUser() {
    return AppStorage.get<ILoginDta>('user')
  }

  // 移除用户信息
  removeUser() {
    AppStorage.set('user', {})
  }

  // 1、checkAuth函数，检查用户是否登录
  // 登录：直接跳转页面
  // 未登录：将参数携带到登录页面
  // 2、登录页面，登录成功后，将参数从登录页面取出，跳转页面，登录页面使用replaceUrl跳转
  // 3、原来url参数为LoginPage的，修改为目标页面
  // 4、使用getRouter跳转的都改为checkAuth，参数直接传递到checkAuth
  checkAuth(options: router.RouterOptions) {
    const user = this.getUser();
    // 登录了就跳转页面
    if (user?.token) {
      contextManager.UiCtx?.getRouter().pushUrl(options)

      // 未登录，将参数携带到登录页面
    } else {

      promptAction.openToast({
        message: '请先登录',
      }).then(() => {
        contextManager.UiCtx?.getRouter().pushUrl({
          url: 'pages/LoginPage',
          params: {
            url: options.url,
            params: options.params
          }
        })
      })
    }
  }
}

// 创建Auth实例
export const auth = new Auth();