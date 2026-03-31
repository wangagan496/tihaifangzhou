import Home from '../views/home/Home'
import Interview from '../views/interview/Interview'
import Mine from '../views/mine/Mine'
import Project from '../views/project/Project'

@Entry
@Component
struct Index {
  @State currentIndex: number = 0 // 表示默认选中的是第一个tab栏

  // 自定义tab的标签栏
  @Builder
  tabBuilder(text: string, icon: ResourceStr, selectedIcon: ResourceStr, index: number) {
    Column({ space: 5 }) {
      Image(this.currentIndex === index ? selectedIcon : icon)
        .height(26)
        .aspectRatio(1)
      Text(text)
        .fontSize(12)
        .fontColor(this.currentIndex === index ? $r('app.color.common_blue') : Color.Black)
    }
  }

  build() {
    Tabs({ index: $$this.currentIndex }) {
      TabContent() {
        Home()
      }.tabBar(this.tabBuilder('首页', $r('app.media.home'), $r('app.media.home_select'), 0))

      TabContent() {
        Project()
      }.tabBar(this.tabBuilder('项目', $r('app.media.tabbar_project'), $r('app.media.project_select'), 1))

      TabContent() {
        Interview()
      }.tabBar(this.tabBuilder('面经', $r('app.media.interview'), $r('app.media.interview_select'), 2))

      TabContent() {
        Mine()
      }.tabBar(this.tabBuilder('我的', $r('app.media.tabbar_mine'), $r('app.media.mine_select'), 3))

    }
    .animationDuration(0) // 去掉切换动画
    .barPosition(BarPosition.End) // tabs在底部显示
  }
}