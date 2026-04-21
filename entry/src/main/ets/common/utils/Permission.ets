// 1、保存context 上下文
// 2、在permission类中写两个方法，一：用户授权，二：拉起设置授权
// 3、实例化导出
// 4、在页面中使用授权工具
import { abilityAccessCtrl, PermissionRequestResult, Permissions } from '@kit.AbilityKit'

class Permission {
  private isAllow: boolean = false

  async requestPermissions(permissions: Permissions[]) {
    const mgr = abilityAccessCtrl.createAtManager()
    const ctx = AppStorage.get<Context>('context')
    await mgr.requestPermissionsFromUser(ctx, permissions).then((data: PermissionRequestResult) => {
      this.isAllow = data.authResults.every(item => item === abilityAccessCtrl.GrantStatus.PERMISSION_GRANTED)
    })
    return this.isAllow
  }

  async onSettingPermissions(permissions: Permissions[]) {
    const mgr = abilityAccessCtrl.createAtManager()
    const ctx = AppStorage.get<Context>('context')
    const res = await mgr.requestPermissionOnSetting(ctx, permissions)
    return res.every(i => i === abilityAccessCtrl.GrantStatus.PERMISSION_GRANTED)
  }
}

export const permission = new Permission()