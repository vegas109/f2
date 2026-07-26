import '../../../core/constants/app_constants.dart';

/// The two supported programming tracks and their Piston runtime mapping.
enum ProgrammingLanguage {
  python,
  cpp;

  /// Stable id used in storage, routing and Firestore.
  String get id => this == ProgrammingLanguage.cpp ? 'cpp' : 'python';

  String get displayName =>
      this == ProgrammingLanguage.cpp ? 'C++' : 'Python';

  /// Piston runtime language name.
  String get pistonLanguage => this == ProgrammingLanguage.cpp
      ? AppConstants.cppRuntime
      : AppConstants.pythonRuntime;

  /// Piston runtime version.
  String get pistonVersion => this == ProgrammingLanguage.cpp
      ? AppConstants.cppVersion
      : AppConstants.pythonVersion;

  /// Source file name Piston expects for this language.
  String get fileName =>
      this == ProgrammingLanguage.cpp ? 'main.cpp' : 'main.py';

  /// A sensible starter snippet shown in the sandbox.
  String get starterCode => this == ProgrammingLanguage.cpp
      ? '#include <iostream>\n\nint main() {\n    std::cout << "Hello, CodeHero!" << std::endl;\n    return 0;\n}\n'
      : 'print("Hello, CodeHero!")\n';

  /// highlight.dart grammar key for syntax highlighting.
  String get highlightGrammar =>
      this == ProgrammingLanguage.cpp ? 'cpp' : 'python';

  static ProgrammingLanguage fromId(String id) =>
      id == 'cpp' ? ProgrammingLanguage.cpp : ProgrammingLanguage.python;
}
