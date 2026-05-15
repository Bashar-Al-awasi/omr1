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

  static String m0(examTitle) =>
      "Are you sure you want to delete ALL results for ${examTitle}?";

  static String m1(studentName) =>
      "Are you sure you want to delete this result for ${studentName}?";

  static String m2(error) => "Import failed: ${error}";

  static String m3(error) => "PDF save error: ${error}";

  static String m4(examTitle) => "Result: ${examTitle}";

  static String m5(examTitle) => "Results: ${examTitle}";

  static String m6(error) => "Error during scanning: ${error}";

  static String m7(count) => "${count} sheets";

  static String m8(count) => "${count} students";

  static String m9(count) => "${count} students loaded";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
        "aboutApp": MessageLookupByLibrary.simpleMessage("About Smart OMR"),
        "accountSettings":
            MessageLookupByLibrary.simpleMessage("Account Settings"),
        "alignOmrInstruction": MessageLookupByLibrary.simpleMessage(
            "Align the OMR sheet within the blue box and tap the scan button, or upload a photo from your gallery."),
        "allResultsDeleted":
            MessageLookupByLibrary.simpleMessage("All results deleted"),
        "analysisReport":
            MessageLookupByLibrary.simpleMessage("Analysis Report"),
        "androidSaveHint": MessageLookupByLibrary.simpleMessage(
            "On Android, you will be prompted to choose a location and filename."),
        "answerKey": MessageLookupByLibrary.simpleMessage("Answer Key"),
        "answers": MessageLookupByLibrary.simpleMessage("Answers"),
        "appTitle": MessageLookupByLibrary.simpleMessage("OMR App"),
        "autoEntry": MessageLookupByLibrary.simpleMessage("Auto Entry"),
        "avgScore": MessageLookupByLibrary.simpleMessage("Avg Score"),
        "back": MessageLookupByLibrary.simpleMessage("Back"),
        "blank": MessageLookupByLibrary.simpleMessage("Blank"),
        "cameraReady": MessageLookupByLibrary.simpleMessage("Camera ready..."),
        "cancel": MessageLookupByLibrary.simpleMessage("Cancel"),
        "chooseFile": MessageLookupByLibrary.simpleMessage("Choose File"),
        "chooseSaveLocation": MessageLookupByLibrary.simpleMessage(
            "Choose where to save the file"),
        "clearAllResults":
            MessageLookupByLibrary.simpleMessage("Clear All Results"),
        "clearResultsConfirmation": m0,
        "close": MessageLookupByLibrary.simpleMessage("Close"),
        "coreActions": MessageLookupByLibrary.simpleMessage("Core Actions"),
        "correct": MessageLookupByLibrary.simpleMessage("Correct"),
        "createAccount": MessageLookupByLibrary.simpleMessage("Create Account"),
        "createExam": MessageLookupByLibrary.simpleMessage("Create Exam"),
        "date": MessageLookupByLibrary.simpleMessage("Date"),
        "delete": MessageLookupByLibrary.simpleMessage("Delete"),
        "deleteResult": MessageLookupByLibrary.simpleMessage("Delete Result"),
        "deleteResultConfirmation": m1,
        "doneRemovePaper":
            MessageLookupByLibrary.simpleMessage("Done! Remove paper for next"),
        "dontHaveAccount":
            MessageLookupByLibrary.simpleMessage("Don\'t have an account? "),
        "editExam": MessageLookupByLibrary.simpleMessage("Edit Exam"),
        "emailLabel": MessageLookupByLibrary.simpleMessage("Email"),
        "english": MessageLookupByLibrary.simpleMessage("English"),
        "enterValidUserName":
            MessageLookupByLibrary.simpleMessage("Enter a valid user name"),
        "examAnalysis": MessageLookupByLibrary.simpleMessage("Exam Analysis"),
        "examCreated": MessageLookupByLibrary.simpleMessage("Exam created!"),
        "examDetails": MessageLookupByLibrary.simpleMessage("Exam Details"),
        "examLabel": MessageLookupByLibrary.simpleMessage("Exam"),
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
        "helpCenter": MessageLookupByLibrary.simpleMessage("Help Center"),
        "history": MessageLookupByLibrary.simpleMessage("History"),
        "holdStillConfirming":
            MessageLookupByLibrary.simpleMessage("Hold still — confirming..."),
        "homeScreenTitle": MessageLookupByLibrary.simpleMessage("Welcome"),
        "id": MessageLookupByLibrary.simpleMessage("ID"),
        "importComplete":
            MessageLookupByLibrary.simpleMessage("Import complete"),
        "importDetailsSubtitle": MessageLookupByLibrary.simpleMessage(
            "Provide details for the student list"),
        "importFailed": m2,
        "importLabel": MessageLookupByLibrary.simpleMessage("Import"),
        "incorrect": MessageLookupByLibrary.simpleMessage("Incorrect"),
        "initializing": MessageLookupByLibrary.simpleMessage("Initializing..."),
        "languageLabel": MessageLookupByLibrary.simpleMessage("Language"),
        "liveScan": MessageLookupByLibrary.simpleMessage("Live Scan"),
        "liveScanTitle": MessageLookupByLibrary.simpleMessage("Live OMR Scan"),
        "loginButton": MessageLookupByLibrary.simpleMessage("Login"),
        "loginWithGoogle":
            MessageLookupByLibrary.simpleMessage("Login with Google"),
        "logout": MessageLookupByLibrary.simpleMessage("Logout"),
        "manualEntry": MessageLookupByLibrary.simpleMessage("Manual Entry"),
        "mark": MessageLookupByLibrary.simpleMessage("Mark"),
        "math": MessageLookupByLibrary.simpleMessage("Math"),
        "multi": MessageLookupByLibrary.simpleMessage("Multi"),
        "navAccount": MessageLookupByLibrary.simpleMessage("Account"),
        "navExams": MessageLookupByLibrary.simpleMessage("Exams"),
        "navHome": MessageLookupByLibrary.simpleMessage("Home"),
        "navResults": MessageLookupByLibrary.simpleMessage("Results"),
        "newListInfo": MessageLookupByLibrary.simpleMessage("New List Info"),
        "next": MessageLookupByLibrary.simpleMessage("Next"),
        "noScansYet":
            MessageLookupByLibrary.simpleMessage("No recent scans yet"),
        "noStudentsImported":
            MessageLookupByLibrary.simpleMessage("No students imported"),
        "notifications": MessageLookupByLibrary.simpleMessage("Notifications"),
        "numChoices": MessageLookupByLibrary.simpleMessage("Number of Choices"),
        "numQuestions":
            MessageLookupByLibrary.simpleMessage("Number of Questions"),
        "obtainedMarks": MessageLookupByLibrary.simpleMessage("Obtained Marks"),
        "ok": MessageLookupByLibrary.simpleMessage("OK"),
        "orLabel": MessageLookupByLibrary.simpleMessage("or"),
        "passwordLabel": MessageLookupByLibrary.simpleMessage("Password"),
        "pdfSaveError": m3,
        "pdfSaved": MessageLookupByLibrary.simpleMessage("PDF saved!"),
        "pdfSavedTo": MessageLookupByLibrary.simpleMessage("PDF saved to"),
        "pending": MessageLookupByLibrary.simpleMessage("Pending"),
        "placePaperInstruction":
            MessageLookupByLibrary.simpleMessage("Place paper under camera"),
        "practiceMode": MessageLookupByLibrary.simpleMessage("Exams created"),
        "processing": MessageLookupByLibrary.simpleMessage("Processing..."),
        "question": MessageLookupByLibrary.simpleMessage("Q"),
        "recentScans": MessageLookupByLibrary.simpleMessage("Recent Scans"),
        "removePaper": MessageLookupByLibrary.simpleMessage("remove paper"),
        "result": MessageLookupByLibrary.simpleMessage("Result"),
        "resultDeleted": MessageLookupByLibrary.simpleMessage("Result deleted"),
        "resultFor": m4,
        "resultSaved":
            MessageLookupByLibrary.simpleMessage("Result saved to database!"),
        "results": MessageLookupByLibrary.simpleMessage("Results"),
        "resultsButton": MessageLookupByLibrary.simpleMessage("View Results"),
        "resultsFor": m5,
        "resultsOverview":
            MessageLookupByLibrary.simpleMessage("Results Overview"),
        "save": MessageLookupByLibrary.simpleMessage("Save"),
        "saving": MessageLookupByLibrary.simpleMessage("Saving..."),
        "scan": MessageLookupByLibrary.simpleMessage("Scan"),
        "scanButton": MessageLookupByLibrary.simpleMessage("Scan Answer Sheet"),
        "scanError": m6,
        "scanOmrSheet": MessageLookupByLibrary.simpleMessage("Scan OMR Sheet"),
        "scanning": MessageLookupByLibrary.simpleMessage("Scanning..."),
        "science": MessageLookupByLibrary.simpleMessage("Science"),
        "score": MessageLookupByLibrary.simpleMessage("Score"),
        "scoreLabel": MessageLookupByLibrary.simpleMessage("Score"),
        "search": MessageLookupByLibrary.simpleMessage("Search by name"),
        "selectExam":
            MessageLookupByLibrary.simpleMessage("Please select an exam"),
        "selectExamFirst":
            MessageLookupByLibrary.simpleMessage("Please select an exam first"),
        "selectLanguage":
            MessageLookupByLibrary.simpleMessage("Select Language"),
        "sheets": MessageLookupByLibrary.simpleMessage("Sheets"),
        "sheetsCountLabel": m7,
        "smartOmr": MessageLookupByLibrary.simpleMessage("Smart OMR"),
        "studentId": MessageLookupByLibrary.simpleMessage("Student ID"),
        "studentIdDigits":
            MessageLookupByLibrary.simpleMessage("Student ID Digits"),
        "studentName": MessageLookupByLibrary.simpleMessage("Student Name"),
        "studentNotFound": MessageLookupByLibrary.simpleMessage(
            "Student not found in the uploaded list."),
        "students": MessageLookupByLibrary.simpleMessage("Students"),
        "studentsCount": m8,
        "studentsLoaded": m9,
        "subject": MessageLookupByLibrary.simpleMessage("Subject"),
        "support": MessageLookupByLibrary.simpleMessage("Support"),
        "tapToFocus": MessageLookupByLibrary.simpleMessage(
            "Tap screen to focus  •  Flash icon for light"),
        "teacher": MessageLookupByLibrary.simpleMessage("Teacher"),
        "title": MessageLookupByLibrary.simpleMessage("Title"),
        "totalExams": MessageLookupByLibrary.simpleMessage("Total Exams"),
        "totalMarks": MessageLookupByLibrary.simpleMessage("Total Marks"),
        "unknownExam": MessageLookupByLibrary.simpleMessage("Unknown Exam"),
        "unknownStudent":
            MessageLookupByLibrary.simpleMessage("Unknown Student"),
        "updateSuccess":
            MessageLookupByLibrary.simpleMessage("Exam updated successfully"),
        "uploadImage": MessageLookupByLibrary.simpleMessage("Upload Image"),
        "uploadImageFirst": MessageLookupByLibrary.simpleMessage(
            "Please upload or capture an image first."),
        "uploadStudentList":
            MessageLookupByLibrary.simpleMessage("Upload Student List"),
        "uploadStudentListRequired": MessageLookupByLibrary.simpleMessage(
            "Please upload the student list before scanning."),
        "userName": MessageLookupByLibrary.simpleMessage("User Name"),
        "view": MessageLookupByLibrary.simpleMessage("View"),
        "viewAll": MessageLookupByLibrary.simpleMessage("View All"),
        "yourAnswer": MessageLookupByLibrary.simpleMessage("Your Answer")
      };
}
