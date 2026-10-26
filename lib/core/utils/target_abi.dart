// 当前设备的 Android ABI；不支持 dart:ffi 的平台（Web）返回 null。
export 'target_abi_stub.dart' if (dart.library.ffi) 'target_abi_ffi.dart';
