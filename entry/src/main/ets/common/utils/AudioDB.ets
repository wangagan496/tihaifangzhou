// 导入关系型数据库模块和值桶类型
import { relationalStore, ValuesBucket } from '@kit.ArkData'

// 定义音频数据项接口，继承自ValuesBucket
export interface InterviewAudioItem extends ValuesBucket {
  // 音频记录的唯一标识ID
  id: number | null
  // 用户ID，用于区分不同用户的音频
  user_id: string
  // 音频文件的名称
  name: string
  // 音频文件的存储路径
  path: string
  // 音频的时长（单位：毫秒）
  duration: number
  // 音频文件的大小（单位：字节）
  size: number
  // 音频记录的创建时间戳
  create_time: number
}

// 音频数据库管理类
class AudioDB {
  // 关系型数据库存储实例，可选类型
  store?: relationalStore.RdbStore
  // 数据库表名常量
  tableName = 'interview_audio'

  // 初始化数据库方法
  async initStore() {
    // 从AppStorage中获取应用上下文
    const ctx = AppStorage.get<Context>('context')
    // 如果上下文存在则继续初始化
    if (ctx) {
      // 异步获取或创建关系型数据库实例
      const store = await relationalStore.getRdbStore(ctx, {
        // 指定数据库文件名称
        name: 'interview_audio.db',
        // 设置数据库安全级别为S1
        securityLevel: relationalStore.SecurityLevel.S1
      })
      // 定义创建表的SQL语句
      const sql = `
        CREATE TABLE IF NOT EXISTS ${this.tableName} (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          user_id TEXT NOT NULL,
          name TEXT NOT NULL,
          path TEXT NOT NULL,
          duration INTEGER NOT NULL,
          size INTEGER NOT NULL,
          create_time INTEGER NOT NULL
        )
      `
      // 执行SQL语句创建数据表
      await store.executeSql(sql)
      // 将数据库实例保存到类成员变量
      this.store = store
    }
  }

  // 插入音频记录方法
  async insert(item: InterviewAudioItem) {
    // 调用数据库insert方法插入数据，返回行ID
    const rowId = await this.store?.insert(this.tableName, item)
    // 如果行ID未定义或为-1表示插入失败
    if (rowId === undefined || rowId === -1) {
      // 返回失败的Promise
      return Promise.reject('insert fail')
    } else {
      // 返回成功的Promise
      return Promise.resolve()
    }
  }

  // 删除音频记录方法
  async delete(id: number) {
    // 创建数据库查询条件对象，指定表名
    const predicates = new relationalStore.RdbPredicates(this.tableName)
    // 设置查询条件为id等于传入的id值
    predicates.equalTo('id', id)
    // 执行删除操作，返回受影响的行数
    const rowCount = await this.store?.delete(predicates)
    // 如果行数未定义或小于等于0表示删除失败
    if (rowCount === undefined || rowCount <= 0) {
      // 返回失败的Promise
      return Promise.reject('delete fail')
    } else {
      // 返回成功的Promise
      return Promise.resolve()
    }
  }

  // 更新音频记录方法
  async update(item: InterviewAudioItem) {
    // 创建数据库查询条件对象，指定表名
    const predicates = new relationalStore.RdbPredicates(this.tableName)
    // 设置查询条件为id等于传入item的id值
    predicates.equalTo('id', item.id)
    // 执行更新操作，返回受影响的行数
    const rowCount = await this.store?.update(item, predicates)
    // 如果行数未定义或小于等于0表示更新失败
    if (rowCount === undefined || rowCount <= 0) {
      // 返回失败的Promise
      return Promise.reject('update fail')
    } else {
      // 返回成功的Promise
      return Promise.resolve()
    }
  }

  // 查询指定用户的音频记录方法
  async query(userId: string) {
    // 创建数据库查询条件对象，指定表名
    const predicates = new relationalStore.RdbPredicates(this.tableName)
    // 设置查询条件为user_id等于传入的userId
    predicates.equalTo('user_id', userId)
    // 执行查询操作，返回结果集
    const resultSet = await this.store?.query(predicates)
    // 如果结果集为空表示查询失败
    if (!resultSet) {
      // 返回失败的Promise
      return Promise.reject('query fail')
    }
    // 创建空的音频数据项数组用于存储查询结果
    const list: InterviewAudioItem[] = []
    // 遍历结果集中的每一行数据
    while (resultSet.goToNextRow()) {
      // 将当前行数据转换为对象并添加到数组中
      list.push({
        // 获取id字段值（长整型）
        id: resultSet.getLong(resultSet.getColumnIndex('id')),
        // 获取user_id字段值（字符串类型）
        user_id: resultSet.getString(resultSet.getColumnIndex('user_id')),
        // 获取name字段值（字符串类型）
        name: resultSet.getString(resultSet.getColumnIndex('name')),
        // 获取path字段值（字符串类型）
        path: resultSet.getString(resultSet.getColumnIndex('path')),
        // 获取duration字段值（长整型）
        duration: resultSet.getLong(resultSet.getColumnIndex('duration')),
        // 获取size字段值（长整型）
        size: resultSet.getLong(resultSet.getColumnIndex('size')),
        // 获取create_time字段值（长整型）
        create_time: resultSet.getLong(resultSet.getColumnIndex('create_time'))
      })
    }
    // 关闭结果集释放资源
    resultSet.close()
    // 返回包含所有音频记录的Promise
    return Promise.resolve(list)
  }
}

// 导出音频数据库管理类的单例实例
export const audioDB = new AudioDB()
