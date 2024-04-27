

class ReaderConfig {
  static ReaderConfig _instance=Null as ReaderConfig;
  static ReaderConfig get instance {
    // ignore: unnecessary_null_comparison
    if (_instance == null) {
      _instance = ReaderConfig();
    }
    return _instance;
  }

  // double fontSize = Styles.getTheme()['fontsize'];
}
