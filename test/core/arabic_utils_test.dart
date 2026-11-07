import 'package:flutter_test/flutter_test.dart';
import 'package:quran_app/core/utils/arabic_utils.dart';

void main() {
  test('mengubah angka latin menjadi angka Arab', () {
    expect(toArabicNumeral(0), '٠');
    expect(toArabicNumeral(1), '١');
    expect(toArabicNumeral(114), '١١٤');
  });
}
