abstract class WebViewRepositoryIntrf{
  Future<String?> saveFile(List<int> bytes, String fileName);
  Future<bool> requestStoragePermission();
}

abstract class NotificationsRepositoryIntrf{
  void updateTokenInOdoo(String token,String sessionId);
}