class ChConfig {
  ///
  /// ### `bool Function(int deleteCount, int deleteSize)`
  ///
  final bool Function(int deleteCount, int deleteSize) willCompact;

  ///
  /// ### if compact ? `will create old database backup file[.bk]`
  ///
  final bool compactWillCreateBackupFile;

  const ChConfig({
    required this.willCompact,
    required this.compactWillCreateBackupFile,
  });

  ///
  /// ### `willCompact` =>  (deleteCount > 100 And deleteSize > 2MB)
  /// ### `compactWillCreateBackupFile` =>  (default=false)
  ///
  factory ChConfig.empty() {
    return ChConfig(
      willCompact: (deleteCount, deleteSize) =>
          deleteCount > 100 && deleteSize > (1024 * 1024) * 2,
      compactWillCreateBackupFile: false,
    );
  }
}
