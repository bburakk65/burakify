/// Oynatılabilir parça: yerel dosya ([path] dosya yolu) veya çevrimiçi
/// kaynak ([path] http/https adresi).
class Track {
  const Track({
    required this.id,
    required this.path,
    required this.title,
    this.artist = '',
  });

  final String id;
  final String path;
  final String title;

  /// Boş olabilir (yerel dosyalarda etiket okunmuyor).
  final String artist;

  /// Parça internetten mi akıyor?
  bool get isOnline => isOnlinePath(path);

  @override
  bool operator ==(Object other) => other is Track && other.id == id;

  @override
  int get hashCode => id.hashCode;
}

/// Yol bir http/https adresi mi?
bool isOnlinePath(String path) {
  final String p = path.toLowerCase();
  return p.startsWith('https://') || p.startsWith('http://');
}

const List<String> kSupportedAudioExtensions = <String>[
  'mp3',
  'm4a',
  'aac',
  'flac',
  'ogg',
  'opus',
  'wav',
];

/// Dosya uzantısı desteklenen bir ses biçimi mi? (İçeriği doğrulamaz.)
bool isSupportedAudioPath(String path) {
  final int dot = path.lastIndexOf('.');
  if (dot < 0 || dot == path.length - 1) {
    return false;
  }
  final String ext = path.substring(dot + 1).toLowerCase();
  return kSupportedAudioExtensions.contains(ext);
}

/// Dosya adından görüntülenecek başlığı üretir (etiket okuma henüz yok).
String titleFromPath(String path) {
  final String name = path.split(RegExp(r'[\\/]')).last;
  final int dot = name.lastIndexOf('.');
  final String base = dot > 0 ? name.substring(0, dot) : name;
  final String cleaned = base.replaceAll('_', ' ').trim();
  return cleaned.isEmpty ? name : cleaned;
}

Track trackFromPath(String path) =>
    Track(id: path, path: path, title: titleFromPath(path));
