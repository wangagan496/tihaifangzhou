@Component
export default struct Home {
  aboutToAppear(): void {
    console.log("Home aboutToAppear");
  }
  build() {
    Column() {
      Text("Home");
    }
  }
}