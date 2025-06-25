/// 基础仓储接口
/// 
/// 定义通用的数据访问操作接口
library;

/// 分页结果模型
class PageResult<T> {
  /// 数据列表
  final List<T> data;
  
  /// 总记录数
  final int total;
  
  /// 当前页码
  final int page;
  
  /// 每页大小
  final int size;
  
  /// 总页数
  int get totalPages => (total / size).ceil();
  
  /// 是否有下一页
  bool get hasNext => page < totalPages;
  
  /// 是否有上一页
  bool get hasPrevious => page > 1;

  const PageResult({
    required this.data,
    required this.total,
    required this.page,
    required this.size,
  });
}

/// 基础仓储接口
abstract class IBaseRepository<T, ID> {
  /// 插入实体
  Future<T> insert(T entity);
  
  /// 批量插入
  Future<List<T>> insertAll(List<T> entities);
  
  /// 根据ID查询
  Future<T?> findById(ID id);
  
  /// 查询所有
  Future<List<T>> findAll();
  
  /// 分页查询
  Future<PageResult<T>> findPage(int page, int size);
  
  /// 条件查询
  Future<List<T>> findWhere(String condition, [List<dynamic>? args]);
  
  /// 更新实体
  Future<T> update(T entity);
  
  /// 删除实体
  Future<void> delete(ID id);
  
  /// 批量删除
  Future<void> deleteAll(List<ID> ids);
  
  /// 统计记录数
  Future<int> count();
  
  /// 条件统计
  Future<int> countWhere(String condition, [List<dynamic>? args]);
  
  /// 检查是否存在
  Future<bool> exists(ID id);
  
  /// 清空表
  Future<void> clear();
}
