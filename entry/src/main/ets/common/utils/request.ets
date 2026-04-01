import axios from '@ohos/axios'

export const instance = axios.create({
  baseURL: 'https://api-harmony-teach.itheima.net'
})