import { TgLoadingDialog } from '../common/components/TgLoadingDialog'
import { ILoginDta } from '../models/AccountModel'
import { photoAccessHelper } from '@kit.MediaLibraryKit'
import { promptAction } from '@kit.ArkUI'
import { fileIo } from '@kit.CoreFileKit'
import { request } from '@kit.BasicServicesKit'
import { tgRequest } from '../common/utils/request'
import { auth } from '../common/utils/Auth'
import image from '@ohos.multimedia.image'


@Entry
@Component
struct ProfileEditPage {
  @StorageLink('user') user: ILoginDta = {} as ILoginDta
  dialog: CustomDialogController = new CustomDialogController({
    builder: TgLoadingDialog({ message: '更新中...' }),
    customStyle: true,
    alignment: DialogAlignment.Center
  })
  @StorageProp('topHeight') topHeight: number = 0
  // 用户昵称
  @State nickName: string = this.user.nickName

  updateAvatar() {
    // 1、打开相册获取图片
    const options = new photoAccessHelper.PhotoSelectOptions()
    const picker = new photoAccessHelper.PhotoViewPicker()

    options.MIMEType = photoAccessHelper.PhotoViewMIMETypes.IMAGE_TYPE
    options.maxSelectNumber = 1
    // select,拉起相册
    picker.select(options)
      .then((res) => {
        if (res.photoUris.length) {
          // 2、拷贝图片到缓存目录.压缩图片
          const context = this.getUIContext().getHostContext()
          const file = fileIo.openSync(res.photoUris[0], fileIo.OpenMode.READ_ONLY)
          const imageSource = image.createImageSource(file.fd)
          const imagePacker = image.createImagePacker()
          const targetFilePath = context?.cacheDir + '/' + Date.now() + '.jpg'
          const targetFile = fileIo.openSync(targetFilePath, fileIo.OpenMode.CREATE | fileIo.OpenMode.READ_WRITE)
          imagePacker.packToFile(imageSource, targetFile.fd, {
            format: 'image/jpeg',
            quality: 70
          })
          this.dialog.open()
          // 3、上传图片
          request.uploadFile(context, {
            url: 'https://api-harmony-teach.itheima.net/hm/userInfo/avatar',
            method: 'POST',
            header: {
              'Content-Type': 'multipart/form-data',
              Authorization: 'Bearer ' + this.user.token
            },
            files: [{
              filename: targetFile.name, // 文件名
              type: '.jpg', // 文件类型
              name: 'file', // 后台决定
              uri: 'internal://cache/' + targetFile.name // 文件路径，固定写法
            }],
            data: []
          })
            .then((res) => {
              // 上传成功
              res.on('headerReceive', () => {

                promptAction.openToast({ message: '上传成功' })
                // 刷新用户信息
                tgRequest<ILoginDta>({ url: '/hm/userInfo' }).then((res) => {
                  this.user.avatar = res.avatar
                  auth.setUser(this.user)
                })
                this.dialog.close()

              })
              // 上传失败
              res.on('fail', () => {
                promptAction.openToast({ message: '上传失败' })
                this.dialog.close()
              })
            })

        } else {
          promptAction.openToast({
            message: '请选择图片'
          }).then(() => {
            return
          })
        }
      })
  }

  build() {
    Navigation() {
      Column() {
        List() {
          ListItem() {
            Row() {
              Text('头像')
              Image(this.user.avatar || $r('app.media.ic_mine_avatar'))
                .alt($r('app.media.ic_mine_avatar'))
                .width(40)
                .aspectRatio(1)
                .borderRadius(20)
                .border({ width: 0.5, color: $r('app.color.common_gray_border') })
                .onClick(() => {
                  // TODO 更新头像
                  this.updateAvatar()
                })
            }
            .width('100%')
            .height(60)
            .justifyContent(FlexAlign.SpaceBetween)
          }

          ListItem() {
            Row() {
              Text('昵称')
              TextInput({ text: $$this.nickName })
                .fontColor($r('app.color.common_gray_03'))
                .textAlign(TextAlign.End)
                .layoutWeight(1)
                .padding(0)
                .height(60)
                .backgroundColor($r('app.color.white'))
                .borderRadius(0)
                .onSubmit(() => {
                  // TODO 更新昵称
                  this.updateNickname()
                })
            }
            .width('100%')
            .justifyContent(FlexAlign.SpaceBetween)
          }
        }
        .width('100%')
        .height('100%')
        .padding({
          left: 35,
          right: 35,
          top: 15,
          bottom: 15
        })
        .divider({ strokeWidth: 0.5, color: $r('app.color.common_gray_bg') })
      }
    }.titleMode(NavigationTitleMode.Mini).title('编辑资料')
    .padding({ top: this.topHeight })

  }

  // 未登录

  async updateNickname() {
    // 更新服务器端
    await tgRequest({
      url: '/hm/userInfo/profile',
      method: 'POST',
      data: {
        nickName: this.nickName
      }
    })
    // 更新客户端
    this.user.nickName = this.nickName
    promptAction.openToast({ message: '更新成功' })

  }
}