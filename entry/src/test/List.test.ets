import trackingTest from './Tracking.test'
import authTest from './Auth.test'
import audioDBTest from './AudioDB.test'

export default function testsuite() {
  trackingTest()
  authTest()
  audioDBTest()
}
