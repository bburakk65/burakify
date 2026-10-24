import '../audio/track.dart';

/// Çevrimiçi müzik kaynağı. Yeni kaynaklar (ör. Jamendo) bu arayüzü uygular.
abstract class CatalogSource {
  /// Kullanıcıya gösterilen kaynak adı.
  String get name;

  /// Kullanıcıya gösterilen, kaynağın içeriği hakkındaki dürüst açıklama.
  String get description;

  /// [query] ile eşleşen, internetten çalınabilir parçaları döndürür.
  /// Hata olursa [CatalogException] fırlatır.
  Future<List<Track>> search(String query);
}

/// Arayüzde olduğu gibi gösterilebilecek Türkçe bir hata iletisi taşır.
class CatalogException implements Exception {
  const CatalogException(this.message);

  final String message;

  @override
  String toString() => 'CatalogException: $message';
}
