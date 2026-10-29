/// 教务系统类型，对应后端通用头 `x-loginMode`。
///
/// 0/缺省 = 本科生系统（swjw），1 = 研究生系统（gmis）。
enum LoginMode {
  undergraduate(0),
  graduate(1);

  const LoginMode(this.value);

  /// 写入 `x-loginMode` 请求头的值。
  final int value;

  /// 未知/缺失值一律按本科生系统处理（与后端约定一致）。
  static LoginMode fromValue(int? value) => value == LoginMode.graduate.value
      ? LoginMode.graduate
      : LoginMode.undergraduate;
}
