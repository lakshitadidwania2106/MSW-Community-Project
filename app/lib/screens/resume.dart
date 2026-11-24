import 'package:flutter/material.dart';

import '../theme.dart';
import '../widgets/ui.dart';

/// Resume, auto-built from the MSW ID. Edit fields, the paper updates live.
class ResumeScreen extends StatefulWidget {
  const ResumeScreen({super.key});
  @override
  State<ResumeScreen> createState() => _ResumeScreenState();
}

class _ResumeScreenState extends State<ResumeScreen> {
  final _f = {
    'Name': TextEditingController(text: 'Aanya Sharma'),
    'Headline': TextEditingController(text: 'Full-stack developer · 3× hackathon finalist'),
    'Education': TextEditingController(text: 'B.Tech CSE, IIT Delhi — 2023–27 · CGPA 8.9'),
    'Experience': TextEditingController(text: 'Frontend Intern, Lumen Labs — onboarding flow for 40k users\nPaid task, Kite AI — cleaned 10k survey rows'),
    'Projects': TextEditingController(text: 'Winner, Climate Code ’25 — grid-load forecaster\nMSW Labs Full-Stack Challenge — Day 12/30'),
    'Skills': TextEditingController(text: 'React, Next.js, Python, FastAPI, Figma, SQL'),
  };
  bool _edit = false;

  @override
  void dispose() {
    for (final c in _f.values) {
      c.dispose();
    }
    super.dispose();
  }

  int get _ats => (60 + (_f['Experience']!.text.length + _f['Projects']!.text.length + _f['Skills']!.text.length) ~/ 12).clamp(0, 99);

  @override
  Widget build(BuildContext context) {
    final pad = MediaQuery.of(context).padding;
    return Scaffold(
      body: ListView(
        padding: EdgeInsets.fromLTRB(20, pad.top + 8, 20, pad.bottom + 30),
        children: [
          Row(
            children: [
              Pressable(
                onTap: () => Navigator.of(context).pop(),
                child: Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: C.card,
                    shape: BoxShape.circle,
                    border: Border.all(color: C.line),
                  ),
                  child: const Icon(Icons.arrow_back_rounded, size: 18),
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(color: C.lime, borderRadius: BorderRadius.circular(99)),
                child: Text(
                  'ATS $_ats',
                  style: sans(13, color: C.black, weight: FontWeight.w700),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          const Reveal(child: Headline('Your résumé ', 'writes itself.', size: 42)),
          const SizedBox(height: 6),
          Text('Built from your MSW ID — badges, hackathons, tasks and courses.', style: sans(14, color: C.muted)),
          const SizedBox(height: 18),
          Reveal(
            delay: 120,
            child: Transform.rotate(
              angle: _edit ? 0 : -0.012,
              child: Container(
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  color: C.card,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: C.line),
                  boxShadow: const [BoxShadow(color: Color(0x22000000), blurRadius: 30, offset: Offset(0, 16))],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(_f['Name']!.text, style: serif(36)),
                    Text(_f['Headline']!.text, style: sans(13, weight: FontWeight.w600)),
                    Text('aanya@iitd.ac.in · msw.community/aanya', style: sans(11, color: C.muted)),
                    for (final k in const ['Education', 'Experience', 'Projects', 'Skills']) ...[
                      const SizedBox(height: 14),
                      Text(k.toUpperCase(), style: mono(9, color: C.tealD)),
                      Divider(height: 10, color: C.line),
                      for (final l in _f[k]!.text.split('\n').where((x) => x.trim().isNotEmpty))
                        Padding(
                          padding: const EdgeInsets.only(bottom: 3),
                          child: Text(k == 'Skills' ? l : '•  $l', style: sans(12.5, height: 1.4)),
                        ),
                    ],
                    const SizedBox(height: 14),
                    Text('VERIFIED ON MSW COMMUNITY · MSW-2026-0412', style: mono(8)),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: PrimaryButton(_edit ? 'Done editing' : 'Edit details', bg: Colors.white, fg: C.ink, icon: false, onTap: () => setState(() => _edit = !_edit)),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: PrimaryButton('Export PDF', icon: false, onTap: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Resume.pdf saved to your files')))),
              ),
            ],
          ),
          AnimatedSize(
            duration: const Duration(milliseconds: 450),
            curve: Curves.easeOutCubic,
            child: !_edit
                ? const SizedBox(width: double.infinity)
                : Column(
                    children: [
                      const SizedBox(height: 16),
                      for (final e in _f.entries)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: TextField(
                            controller: e.value,
                            maxLines: (e.key == 'Experience' || e.key == 'Projects') ? 3 : 1,
                            onChanged: (_) => setState(() {}),
                            decoration: InputDecoration(
                              labelText: e.key,
                              filled: true,
                              fillColor: C.card,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                                borderSide: BorderSide(color: C.line2),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}
