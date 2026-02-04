// GENERATED CODE - DO NOT MODIFY BY HAND
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'intl/messages_all.dart';

// **************************************************************************
// Generator: Flutter Intl IDE plugin
// Made by Localizely
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, lines_longer_than_80_chars
// ignore_for_file: join_return_with_assignment, prefer_final_in_for_each
// ignore_for_file: avoid_redundant_argument_values, avoid_escaping_inner_quotes

class S {
  S();

  static S? _current;

  static S get current {
    assert(_current != null,
        'No instance of S was loaded. Try to initialize the S delegate before accessing S.current.');
    return _current!;
  }

  static const AppLocalizationDelegate delegate = AppLocalizationDelegate();

  static Future<S> load(Locale locale) {
    final name = (locale.countryCode?.isEmpty ?? false)
        ? locale.languageCode
        : locale.toString();
    final localeName = Intl.canonicalizedLocale(name);
    return initializeMessages(localeName).then((_) {
      Intl.defaultLocale = localeName;
      final instance = S();
      S._current = instance;

      return instance;
    });
  }

  static S of(BuildContext context) {
    final instance = S.maybeOf(context);
    assert(instance != null,
        'No instance of S present in the widget tree. Did you add S.delegate in localizationsDelegates?');
    return instance!;
  }

  static S? maybeOf(BuildContext context) {
    return Localizations.of<S>(context, S);
  }

  /// `OMR App`
  String get appTitle {
    return Intl.message(
      'OMR App',
      name: 'appTitle',
      desc: '',
      args: [],
    );
  }

  /// `Home`
  String get homeScreenTitle {
    return Intl.message(
      'Home',
      name: 'homeScreenTitle',
      desc: '',
      args: [],
    );
  }

  /// `Scan Answer Sheet`
  String get scanButton {
    return Intl.message(
      'Scan Answer Sheet',
      name: 'scanButton',
      desc: '',
      args: [],
    );
  }

  /// `View Results`
  String get resultsButton {
    return Intl.message(
      'View Results',
      name: 'resultsButton',
      desc: '',
      args: [],
    );
  }

  /// `Password`
  String get passwordLabel {
    return Intl.message(
      'Password',
      name: 'passwordLabel',
      desc: '',
      args: [],
    );
  }

  /// `or`
  String get orLabel {
    return Intl.message(
      'or',
      name: 'orLabel',
      desc: '',
      args: [],
    );
  }

  /// `Email`
  String get emailLabel {
    return Intl.message(
      'Email',
      name: 'emailLabel',
      desc: '',
      args: [],
    );
  }

  /// `Login`
  String get loginButton {
    return Intl.message(
      'Login',
      name: 'loginButton',
      desc: '',
      args: [],
    );
  }

  /// `Login with Google`
  String get loginWithGoogle {
    return Intl.message(
      'Login with Google',
      name: 'loginWithGoogle',
      desc: '',
      args: [],
    );
  }

  /// `Language`
  String get languageLabel {
    return Intl.message(
      'Language',
      name: 'languageLabel',
      desc: '',
      args: [],
    );
  }

  /// `Create Exam`
  String get createExam {
    return Intl.message(
      'Create Exam',
      name: 'createExam',
      desc: '',
      args: [],
    );
  }

  /// `Exam Title`
  String get examTitle {
    return Intl.message(
      'Exam Title',
      name: 'examTitle',
      desc: '',
      args: [],
    );
  }

  /// `Subject`
  String get subject {
    return Intl.message(
      'Subject',
      name: 'subject',
      desc: '',
      args: [],
    );
  }

  /// `Number of Questions`
  String get numQuestions {
    return Intl.message(
      'Number of Questions',
      name: 'numQuestions',
      desc: '',
      args: [],
    );
  }

  /// `Number of Choices`
  String get numChoices {
    return Intl.message(
      'Number of Choices',
      name: 'numChoices',
      desc: '',
      args: [],
    );
  }

  /// `Student ID Digits`
  String get studentIdDigits {
    return Intl.message(
      'Student ID Digits',
      name: 'studentIdDigits',
      desc: '',
      args: [],
    );
  }

  /// `Next`
  String get next {
    return Intl.message(
      'Next',
      name: 'next',
      desc: '',
      args: [],
    );
  }

  /// `Back`
  String get back {
    return Intl.message(
      'Back',
      name: 'back',
      desc: '',
      args: [],
    );
  }

  /// `Save`
  String get save {
    return Intl.message(
      'Save',
      name: 'save',
      desc: '',
      args: [],
    );
  }

  /// `Answer Key`
  String get answerKey {
    return Intl.message(
      'Answer Key',
      name: 'answerKey',
      desc: '',
      args: [],
    );
  }

  /// `Mark`
  String get mark {
    return Intl.message(
      'Mark',
      name: 'mark',
      desc: '',
      args: [],
    );
  }

  /// `Manual Entry`
  String get manualEntry {
    return Intl.message(
      'Manual Entry',
      name: 'manualEntry',
      desc: '',
      args: [],
    );
  }

  /// `Auto Entry`
  String get autoEntry {
    return Intl.message(
      'Auto Entry',
      name: 'autoEntry',
      desc: '',
      args: [],
    );
  }

  /// `Results: {examTitle}`
  String resultsFor(Object examTitle) {
    return Intl.message(
      'Results: $examTitle',
      name: 'resultsFor',
      desc: '',
      args: [examTitle],
    );
  }

  /// `Export as Excel`
  String get exportExcel {
    return Intl.message(
      'Export as Excel',
      name: 'exportExcel',
      desc: '',
      args: [],
    );
  }

  /// `Students`
  String get students {
    return Intl.message(
      'Students',
      name: 'students',
      desc: '',
      args: [],
    );
  }

  /// `ID`
  String get id {
    return Intl.message(
      'ID',
      name: 'id',
      desc: '',
      args: [],
    );
  }

  /// `Score`
  String get score {
    return Intl.message(
      'Score',
      name: 'score',
      desc: '',
      args: [],
    );
  }

  /// `Smart OMR`
  String get smartOmr {
    return Intl.message(
      'Smart OMR',
      name: 'smartOmr',
      desc: '',
      args: [],
    );
  }

  /// `Teacher`
  String get teacher {
    return Intl.message(
      'Teacher',
      name: 'teacher',
      desc: '',
      args: [],
    );
  }

  /// `Notifications`
  String get notifications {
    return Intl.message(
      'Notifications',
      name: 'notifications',
      desc: '',
      args: [],
    );
  }

  /// `Scan OMR Sheet`
  String get scanOmrSheet {
    return Intl.message(
      'Scan OMR Sheet',
      name: 'scanOmrSheet',
      desc: '',
      args: [],
    );
  }

  /// `Results Overview`
  String get resultsOverview {
    return Intl.message(
      'Results Overview',
      name: 'resultsOverview',
      desc: '',
      args: [],
    );
  }

  /// `Total Exams`
  String get totalExams {
    return Intl.message(
      'Total Exams',
      name: 'totalExams',
      desc: '',
      args: [],
    );
  }

  /// `Sheets`
  String get sheets {
    return Intl.message(
      'Sheets',
      name: 'sheets',
      desc: '',
      args: [],
    );
  }

  /// `Avg Score`
  String get avgScore {
    return Intl.message(
      'Avg Score',
      name: 'avgScore',
      desc: '',
      args: [],
    );
  }

  /// `Recent Scans`
  String get recentScans {
    return Intl.message(
      'Recent Scans',
      name: 'recentScans',
      desc: '',
      args: [],
    );
  }

  /// `Result: {examTitle}`
  String resultFor(Object examTitle) {
    return Intl.message(
      'Result: $examTitle',
      name: 'resultFor',
      desc: '',
      args: [examTitle],
    );
  }

  /// `Date`
  String get date {
    return Intl.message(
      'Date',
      name: 'date',
      desc: '',
      args: [],
    );
  }

  /// `Exams created`
  String get practiceMode {
    return Intl.message(
      'Exams created',
      name: 'practiceMode',
      desc: '',
      args: [],
    );
  }

  /// `Graded`
  String get graded {
    return Intl.message(
      'Graded',
      name: 'graded',
      desc: '',
      args: [],
    );
  }

  /// `Pending`
  String get pending {
    return Intl.message(
      'Pending',
      name: 'pending',
      desc: '',
      args: [],
    );
  }

  /// `Scan`
  String get scan {
    return Intl.message(
      'Scan',
      name: 'scan',
      desc: '',
      args: [],
    );
  }

  /// `Upload Image`
  String get uploadImage {
    return Intl.message(
      'Upload Image',
      name: 'uploadImage',
      desc: '',
      args: [],
    );
  }

  /// `Align the OMR sheet within the blue box and tap the scan button, or upload a photo from your gallery.`
  String get alignOmrInstruction {
    return Intl.message(
      'Align the OMR sheet within the blue box and tap the scan button, or upload a photo from your gallery.',
      name: 'alignOmrInstruction',
      desc: '',
      args: [],
    );
  }

  /// `Result`
  String get result {
    return Intl.message(
      'Result',
      name: 'result',
      desc: '',
      args: [],
    );
  }

  /// `Student ID`
  String get studentId {
    return Intl.message(
      'Student ID',
      name: 'studentId',
      desc: '',
      args: [],
    );
  }

  /// `Answers`
  String get answers {
    return Intl.message(
      'Answers',
      name: 'answers',
      desc: '',
      args: [],
    );
  }

  /// `Q`
  String get question {
    return Intl.message(
      'Q',
      name: 'question',
      desc: '',
      args: [],
    );
  }

  /// `Your Answer`
  String get yourAnswer {
    return Intl.message(
      'Your Answer',
      name: 'yourAnswer',
      desc: '',
      args: [],
    );
  }

  /// `Correct`
  String get correct {
    return Intl.message(
      'Correct',
      name: 'correct',
      desc: '',
      args: [],
    );
  }

  /// `Incorrect`
  String get incorrect {
    return Intl.message(
      'Incorrect',
      name: 'incorrect',
      desc: '',
      args: [],
    );
  }

  /// `Results`
  String get results {
    return Intl.message(
      'Results',
      name: 'results',
      desc: '',
      args: [],
    );
  }

  /// `Export as Excel`
  String get exportAsExcel {
    return Intl.message(
      'Export as Excel',
      name: 'exportAsExcel',
      desc: '',
      args: [],
    );
  }

  /// `Student Name`
  String get studentName {
    return Intl.message(
      'Student Name',
      name: 'studentName',
      desc: '',
      args: [],
    );
  }

  /// `Excel Exported`
  String get excelExported {
    return Intl.message(
      'Excel Exported',
      name: 'excelExported',
      desc: '',
      args: [],
    );
  }

  /// `Excel file saved`
  String get excelFileSaved {
    return Intl.message(
      'Excel file saved',
      name: 'excelFileSaved',
      desc: '',
      args: [],
    );
  }

  /// `View`
  String get view {
    return Intl.message(
      'View',
      name: 'view',
      desc: '',
      args: [],
    );
  }

  /// `Close`
  String get close {
    return Intl.message(
      'Close',
      name: 'close',
      desc: '',
      args: [],
    );
  }

  /// `Exam created!`
  String get examCreated {
    return Intl.message(
      'Exam created!',
      name: 'examCreated',
      desc: '',
      args: [],
    );
  }

  /// `Exam saved successfully.`
  String get examSaved {
    return Intl.message(
      'Exam saved successfully.',
      name: 'examSaved',
      desc: '',
      args: [],
    );
  }

  /// `OK`
  String get ok {
    return Intl.message(
      'OK',
      name: 'ok',
      desc: '',
      args: [],
    );
  }

  /// `Upload Student List`
  String get uploadStudentList {
    return Intl.message(
      'Upload Student List',
      name: 'uploadStudentList',
      desc: '',
      args: [],
    );
  }

  /// `{count} students loaded`
  String studentsLoaded(Object count) {
    return Intl.message(
      '$count students loaded',
      name: 'studentsLoaded',
      desc: '',
      args: [count],
    );
  }

  /// `Please upload the student list before scanning.`
  String get uploadStudentListRequired {
    return Intl.message(
      'Please upload the student list before scanning.',
      name: 'uploadStudentListRequired',
      desc: '',
      args: [],
    );
  }

  /// `Student not found in the uploaded list.`
  String get studentNotFound {
    return Intl.message(
      'Student not found in the uploaded list.',
      name: 'studentNotFound',
      desc: '',
      args: [],
    );
  }

  /// `Choose File`
  String get chooseFile {
    return Intl.message(
      'Choose File',
      name: 'chooseFile',
      desc: '',
      args: [],
    );
  }

  /// `Create Account`
  String get createAccount {
    return Intl.message(
      'Create Account',
      name: 'createAccount',
      desc: '',
      args: [],
    );
  }

  /// `User Name`
  String get userName {
    return Intl.message(
      'User Name',
      name: 'userName',
      desc: '',
      args: [],
    );
  }

  /// `Enter a valid user name`
  String get enterValidUserName {
    return Intl.message(
      'Enter a valid user name',
      name: 'enterValidUserName',
      desc: '',
      args: [],
    );
  }

  /// `Don't have an account? `
  String get dontHaveAccount {
    return Intl.message(
      'Don\'t have an account? ',
      name: 'dontHaveAccount',
      desc: '',
      args: [],
    );
  }

  /// `Search by name`
  String get search {
    return Intl.message(
      'Search by name',
      name: 'search',
      desc: '',
      args: [],
    );
  }

  /// `Export as PDF`
  String get exportPdf {
    return Intl.message(
      'Export as PDF',
      name: 'exportPdf',
      desc: '',
      args: [],
    );
  }

  /// `Choose where to save the file`
  String get chooseSaveLocation {
    return Intl.message(
      'Choose where to save the file',
      name: 'chooseSaveLocation',
      desc: '',
      args: [],
    );
  }

  /// `File name`
  String get fileName {
    return Intl.message(
      'File name',
      name: 'fileName',
      desc: '',
      args: [],
    );
  }

  /// `On Android, you will be prompted to choose a location and filename.`
  String get androidSaveHint {
    return Intl.message(
      'On Android, you will be prompted to choose a location and filename.',
      name: 'androidSaveHint',
      desc: '',
      args: [],
    );
  }

  /// `PDF saved!`
  String get pdfSaved {
    return Intl.message(
      'PDF saved!',
      name: 'pdfSaved',
      desc: '',
      args: [],
    );
  }

  /// `PDF saved to`
  String get pdfSavedTo {
    return Intl.message(
      'PDF saved to',
      name: 'pdfSavedTo',
      desc: '',
      args: [],
    );
  }

  /// `Cancel`
  String get cancel {
    return Intl.message(
      'Cancel',
      name: 'cancel',
      desc: '',
      args: [],
    );
  }
}

class AppLocalizationDelegate extends LocalizationsDelegate<S> {
  const AppLocalizationDelegate();

  List<Locale> get supportedLocales {
    return const <Locale>[
      Locale.fromSubtags(languageCode: 'en'),
    ];
  }

  @override
  bool isSupported(Locale locale) => _isSupported(locale);
  @override
  Future<S> load(Locale locale) => S.load(locale);
  @override
  bool shouldReload(AppLocalizationDelegate old) => false;

  bool _isSupported(Locale locale) {
    for (var supportedLocale in supportedLocales) {
      if (supportedLocale.languageCode == locale.languageCode) {
        return true;
      }
    }
    return false;
  }
}
