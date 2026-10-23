import 'package:burakify/core/data/library_controller.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('desteklenen dosyaları ekler, desteklenmeyenleri sayar', () {
    final LibraryController lib = LibraryController();
    final AddResult r = lib.addPaths(<String>['/m/a.mp3', '/m/b.txt', '/m/c.wav']);
    expect(r.added, 2);
    expect(r.unsupported, 1);
    expect(lib.tracks.length, 2);
  });

  test('aynı dosya ikinci kez eklenmez', () {
    final LibraryController lib = LibraryController();
    lib.addPaths(<String>['/m/a.mp3']);
    final AddResult r = lib.addPaths(<String>['/m/a.mp3']);
    expect(r.added, 0);
    expect(r.duplicates, 1);
    expect(lib.tracks.length, 1);
  });

  test('yalnızca ekleme olduğunda dinleyicileri uyarır', () {
    final LibraryController lib = LibraryController();
    int calls = 0;
    lib.addListener(() => calls++);
    lib.addPaths(<String>['/m/x.txt']);
    expect(calls, 0);
    lib.addPaths(<String>['/m/x.mp3']);
    expect(calls, 1);
  });
}
