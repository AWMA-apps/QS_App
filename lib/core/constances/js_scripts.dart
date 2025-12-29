class JsScripts {
  static const String js_blobHandler="""
      window.atob_blob = function(blobUrl,suggestedName) {
        fetch(blobUrl).then(r => r.blob()).then(blob => {
          var reader = new FileReader();
          reader.onload = function() {
           // window.flutter_inappwebview.callHandler('onBlobConverted', reader.result);
           window.flutter_inappwebview.callHandler('onBlobConverted', {
                'data': reader.result,
                'fileName': suggestedName || (document.title.replace(/[/\\?%*:|"<>]/g, '-') + ".pdf"),
                'mimeType': blob.type
            });
          };
          reader.readAsDataURL(blob);
        });
      };
      
      const originalOpen = window.open;
      window.open = function(url, name, specs) {
    if (url && url.startsWith('blob:')) {
        window.atob_blob(url); 
        return null;
    }
    return originalOpen.apply(this, arguments);
};
    """;
}