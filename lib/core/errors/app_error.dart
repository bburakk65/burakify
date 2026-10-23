/// Uygulamanın kendi hata türleri. [userMessage] kullanıcıya gösterilebilir,
/// teşhis bilgisi ayrıca [AppLog] ile (hassas veriler gizlenerek) yazılır.
enum AppErrorKind { storage, audio, filePicker, unknown }

class AppError implements Exception {
  const AppError(this.kind, this.userMessage);

  final AppErrorKind kind;
  final String userMessage;

  @override
  String toString() => 'AppError(${kind.name})';
}
