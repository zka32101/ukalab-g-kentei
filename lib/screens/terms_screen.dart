import 'package:app_common_kit/app_common_kit.dart';
import 'package:flutter/material.dart';
import 'package:ukalab_core/ukalab_core.dart';

/// 「用語集」画面（決定50）。五十音・分野を問わない一覧と検索。
/// タップで用語カードをボトムシートで開き、関連用語のタップで次の用語に移動する。
class TermsScreen extends StatefulWidget {
  const TermsScreen({super.key, required this.exam, required this.terms});

  final ExamConfig exam;
  final List<Term> terms;

  @override
  State<TermsScreen> createState() => _TermsScreenState();
}

class _TermsScreenState extends State<TermsScreen> {
  final _searchController = TextEditingController();
  String? _subjectFilter;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Term> get _filtered {
    final query = _searchController.text.trim();
    final subject = _subjectFilter;
    return widget.terms.where((t) {
      if (subject != null && t.subjectId != subject) return false;
      if (query.isEmpty) return true;
      return t.term.contains(query) || t.headline.contains(query);
    }).toList()
      ..sort((a, b) => a.term.compareTo(b.term));
  }

  void _openTerm(Term term) {
    showTermCard(
      context,
      term: term.term,
      headline: term.headline,
      definition: term.definition,
      analogy: term.analogy,
      commonMistake: term.commonMistake,
      relatedTerms: [
        for (final id in term.relatedTermIds)
          if (_termById(id) != null)
            RelatedTermRef(termId: id, label: _termById(id)!.term),
      ],
      onRelatedTermTap: (nextId) {
        final next = _termById(nextId);
        if (next == null) return;
        Navigator.of(context).pop();
        _openTerm(next);
      },
    );
  }

  Term? _termById(String termId) {
    for (final t in widget.terms) {
      if (t.termId == termId) return t;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    if (widget.terms.isEmpty) {
      return const EmptyState(message: '用語データがまだありません。');
    }
    final filtered = _filtered;
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: TextField(
            controller: _searchController,
            onChanged: (_) => setState(() {}),
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.search),
              hintText: '用語を検索',
              border: OutlineInputBorder(),
            ),
          ),
        ),
        SizedBox(
          height: 44,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            children: [
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ChoiceChip(
                  label: const Text('すべて'),
                  selected: _subjectFilter == null,
                  onSelected: (_) => setState(() => _subjectFilter = null),
                ),
              ),
              for (final s in widget.exam.subjects)
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(s.name),
                    selected: _subjectFilter == s.subjectId,
                    onSelected: (_) =>
                        setState(() => _subjectFilter = s.subjectId),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: filtered.isEmpty
              ? const EmptyState(message: '当てはまる用語が見つかりませんでした。')
              : ListView.separated(
                  itemCount: filtered.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, i) {
                    final t = filtered[i];
                    return ListTile(
                      title: Text(t.term),
                      subtitle: Text(
                        t.headline,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => _openTerm(t),
                    );
                  },
                ),
        ),
      ],
    );
  }
}
