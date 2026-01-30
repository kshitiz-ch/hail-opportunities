const String quickActions = r'''
query quickActions {
  hydra {
    actions {
      customActions {
        id, 
        name, 
        deeplinkUrl, 
        imageCdnUrl, 
        defaultOrder
      }
      defaultActions {
        id, 
        name, 
        deeplinkUrl, 
        imageCdnUrl, 
        defaultOrder
      }
    }
  }
}
''';
