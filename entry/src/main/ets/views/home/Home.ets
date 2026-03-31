@Component
export default struct Home {
  aboutToAppear(): void {
    console.log("Home aboutToAppear");
  }

  @StorageProp('topHeight') topHeight: number = 0;

  build() {
    Column() {
      Text("Home");
    }
    .padding({ top: this.topHeight })
    .width('100%')
    .height('100%')
    .backgroundColor(Color.Pink)
  }
}