const String chartData = r'''
query chartData($wSchemeCode: String, $years: Int, $navType: String) {
  metahouse{
    schemeNavData(wschemecode:$wSchemeCode, years:$years, step: 1, navType: $navType){
      navData
    }
  }
}
''';
