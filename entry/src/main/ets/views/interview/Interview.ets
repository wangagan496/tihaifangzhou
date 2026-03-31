@Component
export default struct Interview {
  aboutToAppear(): void {
    console.log("Interview aboutToAppear")
  }

  build() {
    Column() {
      Text("Interview");
    }
  }
}