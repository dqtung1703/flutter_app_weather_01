import 'package:http/http.dart' as http;

class AppHttpClient {
  static final http.Client instance = http.Client();
  // Bạn có thể mở rộng interceptor hoặc log ở đây nếu dùng package khác
}
