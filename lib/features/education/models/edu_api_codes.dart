/// 与 XAUAT.EduApi 的 Controllers/V1/ApiCodes.cs 对应。
abstract final class EduApiCodes {
  static const int success = 0;
  static const int paramError = 10001;
  static const int authFailed = 20001;
  static const int wrongCredentials = 20002;
  static const int mfaRequired = 20003;
  static const int passwordExpired = 20004;
  static const int mfaSessionExpired = 20005;
  static const int mfaInvalidCode = 20006;
  static const int mfaMethodUnsupported = 20007;
  static const int notFound = 30001;
  static const int rateLimited = 40001;
  static const int internalError = 50001;
  static const int upstreamError = 50002;
  static const int dataFetchFailed = 50003;
  static const int mfaUnavailable = 50004;
}
