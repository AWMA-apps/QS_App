abstract class WebViewRepositoryIntrf{
  Future<String?> saveFile(List<int> bytes, String fileName);
  Future<bool> requestStoragePermission();
}