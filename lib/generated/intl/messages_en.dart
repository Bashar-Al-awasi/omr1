// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a en locale. All the
// messages from the main program should be duplicated here with the same
// function name.

// Ignore issues from commonly used lints in this file.
// ignore_for_file:unnecessary_brace_in_string_interps, unnecessary_new
// ignore_for_file:prefer_single_quotes,comment_references, directives_ordering
// ignore_for_file:annotate_overrides,prefer_generic_function_type_aliases
// ignore_for_file:unused_import, file_names, avoid_escaping_inner_quotes
// ignore_for_file:unnecessary_string_interpolations, unnecessary_string_escapes

import 'package:intl/intl.dart';
import 'package:intl/message_lookup_by_library.dart';

final messages = new MessageLookup();

typedef String MessageIfAbsent(String messageStr, List<dynamic> args);

class MessageLookup extends MessageLookupByLibrary {
  String get localeName => 'en';

  static String m0(examTitle) => "Result: ${examTitle}";

  static String m1(examTitle) => "Results: ${examTitle}";

  static String m2(count) => "${count} students loaded";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
        "alignOmrInstruction": MessageLookupByLibrary.simpleMessage(
            "Align the OMR sheet within the blue box and tap the scan button, or upload a photo from your gallery."),
        "androidSaveHint": MessageLookupByLibrary.simpleMessage(
            "On Android, you will be prompted to choose a location and filename."),
        "answerKey": MessageLookupByLibrary.simpleMessage("Answer Key"),
        "answers": MessageLookupByLibrary.simpleMessage("Answers"),
        "appTitle": MessageLookupByLibrary.simpleMessage("OMR App"),
        "autoEntry": MessageLookupByLibrary.simpleMessage("Auto Entry"),
        "avgScore": MessageLookupByLibrary.simpleMessage("Avg Score"),
        "back": MessageLookupByLibrary.simpleMessage("Back"),
        "cancel": MessageLookupByLibrary.simpleMessage("Cancel"),
        "chooseFile": MessageLookupByLibrary.simpleMessage("Choose File"),
        "chooseSaveLocation": MessageLookupByLibrary.simpleMessage(
            "Choose where to save the file"),
        "close": MessageLookupByLibrary.simpleMessage("Close"),
        "correct": MessageLookupByLibrary.simpleMessage("Correct"),
        "createAccount": MessageLookupByLibrary.simpleMessage("Create Account"),
        "createExam": MessageLookupByLibrary.simpleMessage("Create Exam"),
        "date": MessageLookupByLibrary.simpleMessage("Date"),
        "dontHaveAccount":
            MessageLookupByLibrary.simpleMessage("Don\'t have an account? "),
        "emailLabel": MessageLookupByLibrary.simpleMessage("Email"),
        "enterValidUserName":
            MessageLookupByLibrary.simpleMessage("Enter a valid user name"),
        "examCreated": MessageLookupByLibrary.simpleMessage("Exam created!"),
        "examSaved":
            MessageLookupByLibrary.simpleMessage("Exam saved successfully."),
        "examTitle": MessageLookupByLibrary.simpleMessage("Exam Title"),
        "excelExported": MessageLookupByLibrary.simpleMessage("Excel Exported"),
        "excelFileSaved":
            MessageLookupByLibrary.simpleMessage("Excel file saved"),
        "exportAsExcel":
            MessageLookupByLibrary.simpleMessage("Export as Excel"),
        "exportExcel": MessageLookupByLibrary.simpleMessage("Export as Excel"),
        "exportPdf": MessageLookupByLibrary.simpleMessage("Export as PDF"),
        "fileName": MessageLookupByLibrary.simpleMessage("File name"),
        "graded": MessageLookupByLibrary.simpleMessage("Graded"),
        "homeScreenTitle": MessageLookupByLibrary.simpleMessage("Home"),
        "id": MessageLookupByLibrary.simpleMessage("ID"),
        "incorrect": MessageLookupByLibrary.simpleMessage("Incorrect"),
        "languageLabel": MessageLookupByLibrary.simpleMessage("Language"),
        "loginButton": MessageLookupByLibrary.simpleMessage("Login"),
        "loginWithGoogle":
            MessageLookupByLibrary.simpleMessage("Login with Google"),
        "manualEntry": MessageLookupByLibrary.simpleMessage("Manual Entry"),
        "mark": MessageLookupByLibrary.simpleMessage("Mark"),
        "next": MessageLookupByLibrary.simpleMessage("Next"),
        "notifications": MessageLookupByLibrary.simpleMessage("Notifications"),
        "numChoices": MessageLookupByLibrary.simpleMessage("Number of Choices"),
        "numQuestions":
            MessageLookupByLibrary.simpleMessage("Number of Questions"),
        "ok": MessageLookupByLibrary.simpleMessage("OK"),
        "orLabel": MessageLookupByLibrary.simpleMessage("or"),
        "passwordLabel": MessageLookupByLibrary.simpleMessage("Password"),
        "pdfSaved": MessageLookupByLibrary.simpleMessage("PDF saved!"),
        "pdfSavedTo": MessageLookupByLibrary.simpleMessage("PDF saved to"),
        "pending": MessageLookupByLibrary.simpleMessage("Pending"),
        "practiceMode": MessageLookupByLibrary.simpleMessage("Exams created"),
        "question": MessageLookupByLibrary.simpleMessage("Q"),
        "recentScans": MessageLookupByLibrary.simpleMessage("Recent Scans"),
        "result": MessageLookupByLibrary.simpleMessage("Result"),
        "resultFor": m0,
        "results": MessageLookupByLibrary.simpleMessage("Results"),
        "resultsButton": MessageLookupByLibrary.simpleMessage("View Results"),
        "resultsFor": m1,
        "resultsOverview":
            MessageLookupByLibrary.simpleMessage("Results Overview"),
        "save": MessageLookupByLibrary.simpleMessage("Save"),
        "scan": MessageLookupByLibrary.simpleMessage("Scan"),
        "scanButton": MessageLookupByLibrary.simpleMessage("Scan Answer Sheet"),
        "scanOmrSheet": MessageLookupByLibrary.simpleMessage("Scan OMR Sheet"),
        "score": MessageLookupByLibrary.simpleMessage("Score"),
        "search": MessageLookupByLibrary.simpleMessage("Search by name"),
        "sheets": MessageLookupByLibrary.simpleMessage("Sheets"),
        "smartOmr": MessageLookupByLibrary.simpleMessage("Smart OMR"),
        "studentId": MessageLookupByLibrary.simpleMessage("Student ID"),
        "studentIdDigits":
            MessageLookupByLibrary.simpleMessage("Student ID Digits"),
        "studentName": MessageLookupByLibrary.simpleMessage("Student Name"),
        "studentNotFound": MessageLookupByLibrary.simpleMessage(
            "Student not found in the uploaded list."),
        "students": MessageLookupByLibrary.simpleMessage("Students"),
        "studentsLoaded": m2,
        "subject": MessageLookupByLibrary.simpleMessage("Subject"),
        "teacher": MessageLookupByLibrary.simpleMessage("Teacher"),
        "totalExams": MessageLookupByLibrary.simpleMessage("Total Exams"),
        "uploadImage": MessageLookupByLibrary.simpleMessage("Upload Image"),
        "uploadStudentList":
            MessageLookupByLibrary.simpleMessage("Upload Student List"),
        "uploadStudentListRequired": MessageLookupByLibrary.simpleMessage(
            "Please upload the student list before scanning."),
        "userName": MessageLookupByLibrary.simpleMessage("User Name"),
        "view": MessageLookupByLibrary.simpleMessage("View"),
        "yourAnswer": MessageLookupByLibrary.simpleMessage("Your Answer")
      };
}
