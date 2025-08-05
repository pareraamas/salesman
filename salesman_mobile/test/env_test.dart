import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:salesman_mobile/app/core/api_url.dart';

void main() {
  setUpAll(() async {
    // Load the .env file before running the tests
    await dotenv.load(fileName: ".env");
  });

  test('BASE_URL is loaded from .env', () {
    // Check if BASE_URL is loaded correctly
    expect(dotenv.env['BASE_URL'], isNotNull);
    expect(dotenv.env['BASE_URL'], isNotEmpty);
  });

  test('ApiUrl.baseUrl returns correct value', () {
    // Check if ApiUrl.baseUrl returns the correct value
    expect(ApiUrl.baseUrl, dotenv.env['BASE_URL']);
  });

  test('getFullUrl combines baseUrl and endpoint correctly', () {
    // Test the getFullUrl method
    const endpoint = '/test/endpoint';
    final fullUrl = ApiUrl.getFullUrl(endpoint);
    expect(fullUrl, '${ApiUrl.baseUrl}$endpoint');
  });
}
