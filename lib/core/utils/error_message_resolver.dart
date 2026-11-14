import '../../features/education/models/edu_api_codes.dart';
import '../../l10n/app_localizations.dart';
import '../services/network_exception.dart';

String? resolveEduApiCode(int? code, AppLocalizations l10n) => switch (code) {
  EduApiCodes.paramError => l10n.apiInvalidParameters,
  EduApiCodes.authFailed => l10n.pleaseLoginEduAccount,
  EduApiCodes.wrongCredentials => l10n.loginFailed,
  EduApiCodes.mfaRequired => l10n.apiMfaRequired,
  EduApiCodes.passwordExpired => l10n.loginPasswordExpired,
  EduApiCodes.mfaSessionExpired => l10n.apiMfaSessionExpired,
  EduApiCodes.mfaInvalidCode => l10n.apiMfaInvalidCode,
  EduApiCodes.mfaMethodUnsupported => l10n.apiMfaMethodUnsupported,
  EduApiCodes.notFound => l10n.apiResourceNotFound,
  EduApiCodes.rateLimited => l10n.tooManyRequests,
  EduApiCodes.internalError || EduApiCodes.upstreamError => l10n.serverError,
  EduApiCodes.dataFetchFailed => l10n.fetchFailed,
  EduApiCodes.mfaUnavailable => l10n.apiMfaUnavailable,
  _ => null,
};

String resolveEduErrorMessage(
  Object error,
  AppLocalizations l10n, {
  required String fallback,
  bool isLogin = false,
}) {
  if (error is! NetworkException) return fallback;
  return resolveEduApiCode(error.apiCode, l10n) ??
      switch (error) {
        ConnectionException() => l10n.networkError,
        _ => switch (error.statusCode) {
          401 => isLogin ? l10n.loginFailed : l10n.pleaseLoginEduAccount,
          403 => l10n.apiForbidden,
          404 => l10n.apiResourceNotFound,
          408 => isLogin ? l10n.loginTimeout : l10n.requestTimeout,
          429 => l10n.tooManyRequests,
          int() && >= 500 => l10n.serverError,
          _ => fallback,
        },
      };
}

/// Maps error codes from service/notifier layer (no BuildContext) to
/// localized user-facing strings for display in the UI layer.
String resolveErrorMessage(String code, AppLocalizations l10n) {
  switch (code) {
    case 'auth_required':
      return l10n.pleaseLoginEduAccount;
    case 'load_failed':
      return l10n.loadFailedTapRetry;
    case 'exam_auth_required':
      return l10n.examNotLoggedIn;
    case 'auth_failed':
      return l10n.examAuthFailed;
    case 'fetch_failed':
      return l10n.examFetchFailed;
    case 'stale_data':
      return l10n.busRefreshStale;
    case 'network_error':
      return l10n.networkError;
    default:
      return code;
  }
}
