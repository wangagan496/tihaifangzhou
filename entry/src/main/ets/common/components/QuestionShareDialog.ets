import { ILoginDta } from "../../models/AccountModel"
import { QuestionDetail } from "../../pages/QuestionDetailPage"
import { componentSnapshot, promptAction } from "@kit.ArkUI"
import { image } from "@kit.ImageKit"
import { fileIo, fileUri } from "@kit.CoreFileKit"
import { photoAccessHelper } from "@kit.MediaLibraryKit"

@CustomDialog
export struct QuestionShareDialog {
  item: QuestionDetail = {} as QuestionDetail
  @StorageProp('user') user: ILoginDta = {} as ILoginDta
  controller: CustomDialogController

  // 1、拿到弹窗，
  // 2、截图
  // 3、保存图片
  // 4、saveButton，点击触发saveImage
  async saveImage() {
    // 进行截图
    const pixelMap = componentSnapshot.getSync('share')
    // 图片数据
    const imagePacker = image.createImagePacker()
    const arrayBuffer = await imagePacker.packToData(pixelMap, { format: 'image/jpeg', quality: 98 })
    // 存储图片
    const ctx = this.getUIContext().getHostContext()!
    const imagePath = ctx.cacheDir + '/' + Date.now() + '.jpeg'
    const file = fileIo.openSync(imagePath, fileIo.OpenMode.CREATE | fileIo.OpenMode.READ_WRITE)
    fileIo.writeSync(file.fd, arrayBuffer)
    fileIo.closeSync(file.fd)

    const uri = fileUri.getUriFromPath(imagePath)
    const phAccessHelper = photoAccessHelper.getPhotoAccessHelper(ctx)
    const assetChangeRequest = photoAccessHelper.MediaAssetChangeRequest.createImageAssetRequest(ctx, uri)

    await phAccessHelper.applyChanges(assetChangeRequest)
    this.controller.close()

    promptAction.openToast({
      message: '保存成功',
    })
  }

  build() {
    Stack({ alignContent: Alignment.BottomEnd }) {
      Column({ space: 20 }) {
        Image($r('app.media.icon'))
          .width(40)
          .height(40)
        Text('面试通，搞定企业面试题')
        Divider()
          .strokeWidth(0.5)
          .color($r('app.color.common_gray_border'))

        Text('大厂面试题：' + this.item.stem)
          .fontSize(12)
          .maxLines(2)
          .fontWeight(600)
          .width('100%')
          .lineHeight(24)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
        Column({ space: 20 }) {
          QRCode(this.item.id)
            .width(160)
            .height(160)
          Text('扫码查看答案')
            .fontSize(12)
            .alignSelf(ItemAlign.Center)
        }
        .width('100%')

        Blank()
        Text('分享来自：' + this.user.nickName || this.user.username)
          .fontSize(12)
      }
      .id('share')
      .padding(20)
      .alignItems(HorizontalAlign.Start)
      .width(300)
      .height(500)
      .backgroundColor('#fff')


      Row() {
        SaveButton({
          icon: SaveIconStyle.FULL_FILLED,
          text: SaveDescription.SAVE_IMAGE,
          buttonType: ButtonType.Normal
        })
          .fontColor($r('app.color.white'))
          .fontSize(14)
          .padding(12)
          .backgroundColor($r('app.color.common_blue'))
          .onClick((_event, result) => {
            if (result === SaveButtonOnClickResult.SUCCESS) {
              this.saveImage()
            }
          })
      }
      .borderRadius({ topLeft: 8 })
      .clip(true)
    }
    .borderRadius(8)
    .clip(true)
  }
}