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

  /// `Welcome`
  String get homeScreenTitle {
    return Intl.message(
      'Welcome',
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

  /// `No recent scans yet`
  String get noScansYet {
    return Intl.message(
      'No recent scans yet',
      name: 'noScansYet',
      desc: '',
      args: [],
    );
  }

  /// `Core Actions`
  String get coreActions {
    return Intl.message(
      'Core Actions',
      name: 'coreActions',
      desc: '',
      args: [],
    );
  }

  /// `View All`
  String get viewAll {
    return Intl.message(
      'View All',
      name: 'viewAll',
      desc: '',
      args: [],
    );
  }

  /// `New List Info`
  String get newListInfo {
    return Intl.message(
      'New List Info',
      name: 'newListInfo',
      desc: '',
      args: [],
    );
  }

  /// `Title`
  String get title {
    return Intl.message(
      'Title',
      name: 'title',
      desc: '',
      args: [],
    );
  }

  /// `Import`
  String get importLabel {
    return Intl.message(
      'Import',
      name: 'importLabel',
      desc: '',
      args: [],
    );
  }

  /// `Import complete`
  String get importComplete {
    return Intl.message(
      'Import complete',
      name: 'importComplete',
      desc: '',
      args: [],
    );
  }

  /// `Import failed: {error}`
  String importFailed(Object error) {
    return Intl.message(
      'Import failed: $error',
      name: 'importFailed',
      desc: '',
      args: [error],
    );
  }

  /// `No students imported`
  String get noStudentsImported {
    return Intl.message(
      'No students imported',
      name: 'noStudentsImported',
      desc: '',
      args: [],
    );
  }

  /// `{count} students`
  String studentsCount(Object count) {
    return Intl.message(
      '$count students',
      name: 'studentsCount',
      desc: '',
      args: [count],
    );
  }

  /// `Provide details for the student list`
  String get importDetailsSubtitle {
    return Intl.message(
      'Provide details for the student list',
      name: 'importDetailsSubtitle',
      desc: '',
      args: [],
    );
  }

  /// `Home`
  String get navHome {
    return Intl.message(
      'Home',
      name: 'navHome',
      desc: '',
      args: [],
    );
  }

  /// `Exams`
  String get navExams {
    return Intl.message(
      'Exams',
      name: 'navExams',
      desc: '',
      args: [],
    );
  }

  /// `Results`
  String get navResults {
    return Intl.message(
      'Results',
      name: 'navResults',
      desc: '',
      args: [],
    );
  }

  /// `Account`
  String get navAccount {
    return Intl.message(
      'Account',
      name: 'navAccount',
      desc: '',
      args: [],
    );
  }

  /// `Logout`
  String get logout {
    return Intl.message(
      'Logout',
      name: 'logout',
      desc: '',
      args: [],
    );
  }

  /// `Unknown Exam`
  String get unknownExam {
    return Intl.message(
      'Unknown Exam',
      name: 'unknownExam',
      desc: '',
      args: [],
    );
  }

  /// `{count} sheets`
  String sheetsCountLabel(Object count) {
    return Intl.message(
      '$count sheets',
      name: 'sheetsCountLabel',
      desc: '',
      args: [count],
    );
  }

  /// `Account Settings`
  String get accountSettings {
    return Intl.message(
      'Account Settings',
      name: 'accountSettings',
      desc: '',
      args: [],
    );
  }

  /// `Select Language`
  String get selectLanguage {
    return Intl.message(
      'Select Language',
      name: 'selectLanguage',
      desc: '',
      args: [],
    );
  }

  /// `Help Center`
  String get helpCenter {
    return Intl.message(
      'Help Center',
      name: 'helpCenter',
      desc: '',
      args: [],
    );
  }

  /// `About Smart OMR`
  String get aboutApp {
    return Intl.message(
      'About Smart OMR',
      name: 'aboutApp',
      desc: '',
      args: [],
    );
  }

  /// `Support`
  String get support {
    return Intl.message(
      'Support',
      name: 'support',
      desc: '',
      args: [],
    );
  }

  /// `Unknown Student`
  String get unknownStudent {
    return Intl.message(
      'Unknown Student',
      name: 'unknownStudent',
      desc: '',
      args: [],
    );
  }

  /// `Math`
  String get math {
    return Intl.message(
      'Math',
      name: 'math',
      desc: '',
      args: [],
    );
  }

  /// `Science`
  String get science {
    return Intl.message(
      'Science',
      name: 'science',
      desc: '',
      args: [],
    );
  }

  /// `History`
  String get history {
    return Intl.message(
      'History',
      name: 'history',
      desc: '',
      args: [],
    );
  }

  /// `English`
  String get english {
    return Intl.message(
      'English',
      name: 'english',
      desc: '',
      args: [],
    );
  }

  /// `PDF save error: {error}`
  String pdfSaveError(Object error) {
    return Intl.message(
      'PDF save error: $error',
      name: 'pdfSaveError',
      desc: '',
      args: [error],
    );
  }

  /// `Clear All Results`
  String get clearAllResults {
    return Intl.message(
      'Clear All Results',
      name: 'clearAllResults',
      desc: '',
      args: [],
    );
  }

  /// `Are you sure you want to delete ALL results for {examTitle}?`
  String clearResultsConfirmation(Object examTitle) {
    return Intl.message(
      'Are you sure you want to delete ALL results for $examTitle?',
      name: 'clearResultsConfirmation',
      desc: '',
      args: [examTitle],
    );
  }

  /// `Delete Result`
  String get deleteResult {
    return Intl.message(
      'Delete Result',
      name: 'deleteResult',
      desc: '',
      args: [],
    );
  }

  /// `Are you sure you want to delete this result for {studentName}?`
  String deleteResultConfirmation(Object studentName) {
    return Intl.message(
      'Are you sure you want to delete this result for $studentName?',
      name: 'deleteResultConfirmation',
      desc: '',
      args: [studentName],
    );
  }

  /// `Result deleted`
  String get resultDeleted {
    return Intl.message(
      'Result deleted',
      name: 'resultDeleted',
      desc: '',
      args: [],
    );
  }

  /// `All results deleted`
  String get allResultsDeleted {
    return Intl.message(
      'All results deleted',
      name: 'allResultsDeleted',
      desc: '',
      args: [],
    );
  }

  /// `Please select an exam first`
  String get selectExamFirst {
    return Intl.message(
      'Please select an exam first',
      name: 'selectExamFirst',
      desc: '',
      args: [],
    );
  }

  /// `Please upload or capture an image first.`
  String get uploadImageFirst {
    return Intl.message(
      'Please upload or capture an image first.',
      name: 'uploadImageFirst',
      desc: '',
      args: [],
    );
  }

  /// `Blank`
  String get blank {
    return Intl.message(
      'Blank',
      name: 'blank',
      desc: '',
      args: [],
    );
  }

  /// `Multi`
  String get multi {
    return Intl.message(
      'Multi',
      name: 'multi',
      desc: '',
      args: [],
    );
  }

  /// `Result saved to database!`
  String get resultSaved {
    return Intl.message(
      'Result saved to database!',
      name: 'resultSaved',
      desc: '',
      args: [],
    );
  }

  /// `Error during scanning: {error}`
  String scanError(Object error) {
    return Intl.message(
      'Error during scanning: $error',
      name: 'scanError',
      desc: '',
      args: [error],
    );
  }

  /// `Live Scan`
  String get liveScan {
    return Intl.message(
      'Live Scan',
      name: 'liveScan',
      desc: '',
      args: [],
    );
  }

  /// `Please select an exam`
  String get selectExam {
    return Intl.message(
      'Please select an exam',
      name: 'selectExam',
      desc: '',
      args: [],
    );
  }

  /// `Exam`
  String get examLabel {
    return Intl.message(
      'Exam',
      name: 'examLabel',
      desc: '',
      args: [],
    );
  }

  /// `Score`
  String get scoreLabel {
    return Intl.message(
      'Score',
      name: 'scoreLabel',
      desc: '',
      args: [],
    );
  }

  /// `Live OMR Scan`
  String get liveScanTitle {
    return Intl.message(
      'Live OMR Scan',
      name: 'liveScanTitle',
      desc: '',
      args: [],
    );
  }

  /// `Initializing...`
  String get initializing {
    return Intl.message(
      'Initializing...',
      name: 'initializing',
      desc: '',
      args: [],
    );
  }

  /// `Camera ready...`
  String get cameraReady {
    return Intl.message(
      'Camera ready...',
      name: 'cameraReady',
      desc: '',
      args: [],
    );
  }

  /// `Place paper under camera`
  String get placePaperInstruction {
    return Intl.message(
      'Place paper under camera',
      name: 'placePaperInstruction',
      desc: '',
      args: [],
    );
  }

  /// `Scanning...`
  String get scanning {
    return Intl.message(
      'Scanning...',
      name: 'scanning',
      desc: '',
      args: [],
    );
  }

  /// `Done! Remove paper for next`
  String get doneRemovePaper {
    return Intl.message(
      'Done! Remove paper for next',
      name: 'doneRemovePaper',
      desc: '',
      args: [],
    );
  }

  /// `Hold still — confirming...`
  String get holdStillConfirming {
    return Intl.message(
      'Hold still — confirming...',
      name: 'holdStillConfirming',
      desc: '',
      args: [],
    );
  }

  /// `Processing...`
  String get processing {
    return Intl.message(
      'Processing...',
      name: 'processing',
      desc: '',
      args: [],
    );
  }

  /// `remove paper`
  String get removePaper {
    return Intl.message(
      'remove paper',
      name: 'removePaper',
      desc: '',
      args: [],
    );
  }

  /// `Tap screen to focus  •  Flash icon for light`
  String get tapToFocus {
    return Intl.message(
      'Tap screen to focus  •  Flash icon for light',
      name: 'tapToFocus',
      desc: '',
      args: [],
    );
  }

  /// `Obtained Marks`
  String get obtainedMarks {
    return Intl.message(
      'Obtained Marks',
      name: 'obtainedMarks',
      desc: '',
      args: [],
    );
  }

  /// `Total Marks`
  String get totalMarks {
    return Intl.message(
      'Total Marks',
      name: 'totalMarks',
      desc: '',
      args: [],
    );
  }

  /// `Exam Analysis`
  String get examAnalysis {
    return Intl.message(
      'Exam Analysis',
      name: 'examAnalysis',
      desc: '',
      args: [],
    );
  }

  /// `Analysis Report`
  String get analysisReport {
    return Intl.message(
      'Analysis Report',
      name: 'analysisReport',
      desc: '',
      args: [],
    );
  }

  /// `Edit Exam`
  String get editExam {
    return Intl.message(
      'Edit Exam',
      name: 'editExam',
      desc: '',
      args: [],
    );
  }

  /// `Exam Details`
  String get examDetails {
    return Intl.message(
      'Exam Details',
      name: 'examDetails',
      desc: '',
      args: [],
    );
  }

  /// `Saving...`
  String get saving {
    return Intl.message(
      'Saving...',
      name: 'saving',
      desc: '',
      args: [],
    );
  }

  /// `Exam updated successfully`
  String get updateSuccess {
    return Intl.message(
      'Exam updated successfully',
      name: 'updateSuccess',
      desc: '',
      args: [],
    );
  }

  /// `Delete`
  String get delete {
    return Intl.message(
      'Delete',
      name: 'delete',
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
