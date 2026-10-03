import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yourwish_kentei/yourwish_kentei.dart';

/// G検定の試験定義・問題データ・用語データを assets から読み込む。
class ExamData {
  const ExamData({
    required this.exam,
    required this.questions,
    required this.terms,
  });

  final ExamConfig exam;
  final List<Question> questions;
  final List<Term> terms;

  List<Question> get activeQuestions =>
      questions.where((q) => !q.disabled).toList();

  Term? termById(String termId) {
    for (final t in terms) {
      if (t.termId == termId) return t;
    }
    return null;
  }
}

Future<ExamData> loadExamData() async {
  final examText = await rootBundle.loadString('assets/exam/g_kentei.json');
  final exam = ExamConfig.fromJson(jsonDecode(examText) as Map<String, dynamic>);

  final jsonl = await rootBundle.loadString('assets/questions/g_kentei.jsonl');
  final parsed = parseQuestionsJsonl(jsonl);

  final termsJsonl = await rootBundle.loadString('assets/terms/g_kentei.jsonl');
  final parsedTerms = parseTermsJsonl(termsJsonl);

  final issues = [
    ...parsed.issues,
    ...validateQuestions(parsed.questions, exam: exam),
    ...parsedTerms.issues,
    ...validateTerms(parsedTerms.terms, exam: exam, questions: parsed.questions),
  ];
  if (issues.isNotEmpty) {
    throw StateError('問題・用語データに不備があります: ${issues.first}');
  }
  return ExamData(
    exam: exam,
    questions: parsed.questions,
    terms: parsedTerms.terms,
  );
}

final examDataProvider = FutureProvider<ExamData>((ref) => loadExamData());
