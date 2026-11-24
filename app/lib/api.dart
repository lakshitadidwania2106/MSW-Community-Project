import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'data.dart';

/// Talks to the MSW Community backend (FastAPI + SQLite, see msw_community_backend/).
///
/// The app always works offline with the built-in sample data. When the
/// backend is reachable, [Api.bootstrap] replaces that data with what is in
/// the database, and every action (post, comment, like, register, apply,
/// publish, back an idea, admin delete…) is written back to SQLite.
///
/// Point the app at another server with:
///   flutter run --dart-define=API_URL=https://api.example.com
class Api {
  static const base = String.fromEnvironment('API_URL', defaultValue: 'http://localhost:8000');
  static bool online = false;
  static String userId = 'aanya-sharma';

  static Map<String, String> get _h => {'Content-Type': 'application/json', 'X-User': userId};

  static Future<dynamic> _get(String path) async {
    final r = await http.get(Uri.parse('$base$path'), headers: _h).timeout(const Duration(seconds: 4));
    if (r.statusCode >= 400) throw Exception('${r.statusCode} ${r.body}');
    return jsonDecode(utf8.decode(r.bodyBytes));
  }

  static Future<dynamic> _send(String method, String path, [Object? body]) async {
    if (!online) return null;
    try {
      final uri = Uri.parse('$base$path');
      final b = body == null ? null : jsonEncode(body);
      final Future<http.Response> f = switch (method) {
        'POST' => http.post(uri, headers: _h, body: b),
        'PATCH' => http.patch(uri, headers: _h, body: b),
        'DELETE' => http.delete(uri, headers: _h),
        _ => throw ArgumentError(method),
      };
      final r = await f.timeout(const Duration(seconds: 6));
      if (r.statusCode >= 400) {
        debugPrint('API $method $path → ${r.statusCode} ${r.body}');
        return null;
      }
      return r.body.isEmpty ? null : jsonDecode(utf8.decode(r.bodyBytes));
    } catch (e) {
      debugPrint('API $method $path failed: $e');
      return null;
    }
  }

  /// Signs in as the demo account for a role.
  static Future<void> login(Role role) async {
    userId = switch (role) {
      Role.student => 'aanya-sharma',
      Role.company => 'lumen-labs',
      Role.investor => 'nikhil-varma',
      Role.college => 'iit-bombay-e-cell',
      Role.admin => 'msw-admin',
    };
    await _send('POST', '/auth/login', {'user_id': userId, 'role': role.name});
  }

  /// Loads everything from the backend. Keeps the sample data if it is offline.
  static Future<void> bootstrap() async {
    try {
      final d = await _get('/bootstrap') as Map<String, dynamic>;
      for (final u in d['users'] as List) {
        final p = personFrom(u);
        if (p != me && u['role'] == 'student') people[p.name] = p;
      }
      _replace(posts, [for (final j in d['posts'] as List) postFrom(j)]);
      _replace(events, [for (final j in d['events'] as List) eventFrom(j)]);
      _replace(opportunities, [for (final j in d['opportunities'] as List) oppFrom(j)]);
      _replace(ctasks, [for (final j in d['tasks'] as List) taskFrom(j)]);
      _replace(ideas, [for (final j in d['ideas'] as List) ideaFrom(j)]);
      _replace(announcements, [for (final j in d['announcements'] as List) annFrom(j)]);
      online = true;
      debugPrint('MSW API online: $base');
    } catch (e) {
      online = false;
      debugPrint('MSW API offline ($e) — using built-in sample data');
    }
  }

  static void _replace<T>(List<T> target, List<T> fresh) {
    if (fresh.isEmpty) return;
    target
      ..clear()
      ..addAll(fresh);
  }

  /* ───────── writes ───────── */
  static Future<void> createPost(Post p) async {
    final r = await _send('POST', '/posts', postJson(p));
    if (r != null) p.id = r['id'];
  }

  static void like(Post p) => _send('POST', '/posts/${p.id}/like', {'liked': p.liked});
  static void save(Post p) => _send('POST', '/posts/${p.id}/save', {'saved': p.saved});
  static Future<void> comment(Post p, Comment c) async {
    final r = await _send('POST', '/posts/${p.id}/comments', {'text': c.text});
    if (r != null) c.id = r['id'];
  }

  static void deletePost(Post p) => _send('DELETE', '/posts/${p.id}');
  static void deleteComment(Comment c) => _send('DELETE', '/comments/${c.id}');

  static Future<void> createEvent(EventItem e) async {
    final r = await _send('POST', '/events', eventJson(e));
    if (r != null) e.id = r['id'];
  }

  static void register(EventItem e, {String team = '', String track = ''}) => _send('POST', '/events/${e.id}/register', {'team': team, 'track': track});
  static void deleteEvent(EventItem e) => _send('DELETE', '/events/${e.id}');

  static Future<void> createAnnouncement(Announcement a) async {
    final r = await _send('POST', '/announcements', annJson(a));
    if (r != null) a.id = r['id'];
  }

  static void deleteAnnouncement(Announcement a) => _send('DELETE', '/announcements/${a.id}');

  static Future<void> createOpportunity(Opportunity o) async {
    final r = await _send('POST', '/opportunities', oppJson(o));
    if (r != null) o.id = r['id'];
  }

  static void setLive(Opportunity o) => _send('PATCH', '/opportunities/${o.id}', {'live': o.live});
  static void apply(Opportunity o, {String link = '', String note = ''}) => _send('POST', '/opportunities/${o.id}/apply', {'link': link, 'note': note});
  static void deleteOpportunity(Opportunity o) => _send('DELETE', '/opportunities/${o.id}');

  static Future<void> createTask(CTask t) async {
    final r = await _send('POST', '/tasks', taskJson(t));
    if (r != null) t.id = r['id'];
  }

  static Future<void> submit(CTask t, Submission s) async {
    final r = await _send('POST', '/tasks/${t.id}/submissions', {'repo': s.repo, 'demo': s.demo, 'notes': s.notes, 'shots': s.shots});
    if (r != null) s.id = r['id'];
  }

  static void review(Submission s) => _send('PATCH', '/submissions/${s.id}', {'status': s.status});
  static void deleteTask(CTask t) => _send('DELETE', '/tasks/${t.id}');

  static void decide(Idea i) => _send('POST', '/ideas/${i.id}/decision', {'decision': i.decision, 'amount': i.myCheque});

  static void deleteUser(String id) => _send('DELETE', '/users/$id');
  static void patchUser(String id, Map<String, dynamic> body) => _send('PATCH', '/users/$id', body);
}

/* ───────────────────────── JSON mapping ───────────────────────── */

const iconKeys = <String, IconData>{
  'grass': Icons.grass_rounded,
  'book': Icons.menu_book_rounded,
  'heart': Icons.monitor_heart_outlined,
  'wallet': Icons.account_balance_wallet_outlined,
  'bolt': Icons.electric_bolt_rounded,
  'rocket': Icons.rocket_launch_outlined,
  'eco': Icons.eco_outlined,
  'lightbulb': Icons.lightbulb_outline_rounded,
};

String iconKey(IconData i) => iconKeys.entries.firstWhere((e) => e.value == i, orElse: () => const MapEntry('lightbulb', Icons.lightbulb_outline_rounded)).key;

int _c(Color c) => c.toARGB32();
List<int> _cs(List<Color> c) => [for (final x in c) _c(x)];
List<Color> _toCs(dynamic l) => [for (final x in (l as List? ?? [])) Color(x as int)];
List<String> _ss(dynamic l) => [for (final x in (l as List? ?? [])) x.toString()];
List<(String, String)> _pairs(dynamic l) => [for (final x in (l as List? ?? [])) (x[0].toString(), x[1].toString())];

Map<String, dynamic> personJson(Person p) => {
  'id': p.id, 'name': p.name, 'role': 'student', 'college': p.college, 'course': p.course, 'headline': p.headline, 'bio': p.bio, //
  'skills': p.skills, 'grad': _cs(p.grad), 'level': p.level, 'iq': p.iq, 'gh': p.gh, 'followers': p.followers, 'hackathons': p.hackathons,
};

Person personFrom(Map<String, dynamic> j) {
  if (j['id'] == me.id) return me;
  final existing = people[j['name']];
  if (existing != null) return existing;
  final g = _toCs(j['grad']);
  return Person(
    j['name'] ?? 'Member',
    j['college'] ?? '',
    j['course'] ?? '',
    j['headline'] ?? '',
    j['bio'] ?? '',
    _ss(j['skills']),
    g.length < 2 ? const [Color(0xFF2F8F7A), Color(0xFF9FD3FF)] : g,
    level: j['level'] ?? 1,
    iq: j['iq'] ?? 100,
    gh: j['gh'] ?? 0,
    followers: j['followers'] ?? 0,
    hackathons: j['hackathons'] ?? 0,
  );
}

Map<String, dynamic> postJson(Post p) => {
  'author': personJson(p.author), 'time': p.time, 'body': p.body, 'src': p.src, 'url': p.url, 'title': p.title, 'domain': p.domain, //
  'grad': _cs(p.grad), 'likes': p.likes, 'shares': p.shares,
  'comments': [
    for (final c in p.comments) {'author': personJson(c.author), 'text': c.text, 'time': c.time, 'likes': c.likes},
  ],
};

Post postFrom(Map<String, dynamic> j) =>
    Post(
        author: personFrom(j['author']),
        time: j['time'] ?? 'now',
        body: j['body'] ?? '',
        src: j['src'] ?? 'Link',
        title: j['title'] ?? '',
        domain: j['domain'] ?? '',
        grad: _toCs(j['grad']).length < 2 ? const [Color(0xFFD4F56B), Color(0xFF7FD1BD)] : _toCs(j['grad']),
        likes: j['likes'] ?? 0,
        shares: j['shares'] ?? 0,
        comments: [for (final c in (j['comments'] as List? ?? [])) Comment(personFrom(c['author']), c['text'] ?? '', c['time'] ?? 'now', likes: c['likes'] ?? 0)..id = c['id']],
      )
      ..id = j['id']
      ..url = j['url'] ?? ''
      ..liked = j['liked'] == true
      ..saved = j['saved'] == true;

Map<String, dynamic> eventJson(EventItem e) => {
  'title': e.title, 'tagline': e.tagline, 'type': e.type, 'organiser': e.organiser, 'mode': e.mode, 'venue': e.venue, 'dates': e.dates, //
  'reg_deadline': e.regDeadline, 'base': _c(e.base), 'blobs': _cs(e.blobs), 'seconds_left': e.secondsLeft, 'about': e.about,
  'prize_pool': e.prizePool,
  'prizes': [
    for (final p in e.prizes) [p.$1, p.$2],
  ],
  'team_size': e.teamSize,
  'eligibility': e.eligibility,
  'tracks': e.tracks,
  'timeline': [
    for (final p in e.timeline) [p.$1, p.$2],
  ],
  'perks': e.perks,
  'seats': e.seats,
  'registered': e.registered,
};

EventItem eventFrom(Map<String, dynamic> j) =>
    EventItem(
        title: j['title'] ?? '',
        tagline: j['tagline'] ?? '',
        type: j['type'] ?? 'Event',
        organiser: j['organiser'] ?? '',
        mode: j['mode'] ?? '',
        venue: j['venue'] ?? '',
        dates: j['dates'] ?? '',
        regDeadline: j['reg_deadline'] ?? '',
        base: Color(j['base'] ?? 0xFF121212),
        blobs: _toCs(j['blobs']),
        secondsLeft: j['seconds_left'] ?? 0,
        about: j['about'] ?? '',
        prizePool: j['prize_pool'] ?? '',
        prizes: _pairs(j['prizes']),
        teamSize: j['team_size'] ?? 'Individual',
        eligibility: _ss(j['eligibility']),
        tracks: _ss(j['tracks']),
        timeline: _pairs(j['timeline']),
        perks: _ss(j['perks']),
        seats: j['seats'] ?? 100,
        registered: j['registered'] ?? 0,
      )
      ..id = j['id']
      ..going = j['going'] == true;

Map<String, dynamic> annJson(Announcement a) => {'title': a.title, 'body': a.body, 'organiser': a.organiser, 'time': a.time, 'category': a.category, 'link': a.link, 'pinned': a.pinned};
Announcement annFrom(Map<String, dynamic> j) => Announcement(
  title: j['title'] ?? '',
  body: j['body'] ?? '',
  organiser: j['organiser'] ?? '',
  time: j['time'] ?? '',
  category: j['category'] ?? 'General',
  link: j['link'] ?? '',
  pinned: j['pinned'] == true,
)..id = j['id'];

Map<String, dynamic> oppJson(Opportunity o) => {
  'title': o.title, 'company': o.company, 'color': _c(o.color), 'internship': o.internship, 'work_mode': o.workMode, 'location': o.location, //
  'pay': o.pay, 'duration': o.duration, 'start_date': o.startDate, 'apply_by': o.applyBy, 'openings': o.openings, 'experience': o.experience,
  'skills': o.skills, 'eligibility': o.eligibility, 'about': o.about, 'responsibilities': o.responsibilities, 'perks': o.perks, 'rounds': o.rounds,
  'about_company': o.aboutCompany, 'applicants': o.applicants, 'views': o.views, 'live': o.live,
};

Opportunity oppFrom(Map<String, dynamic> j) =>
    Opportunity(
        title: j['title'] ?? '',
        company: j['company'] ?? '',
        color: Color(j['color'] ?? 0xFF121212),
        internship: j['internship'] == true,
        workMode: j['work_mode'] ?? '',
        location: j['location'] ?? '',
        pay: j['pay'] ?? '',
        duration: j['duration'] ?? '',
        startDate: j['start_date'] ?? '',
        applyBy: j['apply_by'] ?? '',
        openings: j['openings'] ?? 1,
        experience: j['experience'] ?? '',
        skills: _ss(j['skills']),
        eligibility: _ss(j['eligibility']),
        about: j['about'] ?? '',
        responsibilities: _ss(j['responsibilities']),
        perks: _ss(j['perks']),
        rounds: _ss(j['rounds']),
        aboutCompany: j['about_company'] ?? '',
        applicants: j['applicants'] ?? 0,
        views: j['views'] ?? 0,
        live: j['live'] != false,
      )
      ..id = j['id']
      ..applied = j['applied'] == true;

Map<String, dynamic> taskJson(CTask t) => {
  'title': t.title, 'company': t.company, 'color': _c(t.color), 'reward': t.reward, 'days': t.days, 'level': t.level, 'stack': t.stack, //
  'repo': t.repo, 'description': t.description, 'deliverables': t.deliverables, 'acceptance': t.acceptance,
  'submissions': [
    for (final s in t.submissions) {'student': personJson(s.student), 'repo': s.repo, 'demo': s.demo, 'notes': s.notes, 'shots': s.shots, 'status': s.status},
  ],
};

CTask taskFrom(Map<String, dynamic> j) {
  final t = CTask(
    title: j['title'] ?? '',
    company: j['company'] ?? '',
    color: Color(j['color'] ?? 0xFF121212),
    reward: j['reward'] ?? 0,
    days: j['days'] ?? 1,
    level: j['level'] ?? 1,
    stack: _ss(j['stack']),
    repo: j['repo'] ?? '',
    description: j['description'] ?? '',
    deliverables: _ss(j['deliverables']),
    acceptance: _ss(j['acceptance']),
    submissions: [
      for (final s in (j['submissions'] as List? ?? []))
        Submission(personFrom(s['student']), s['repo'] ?? '', s['demo'] ?? '', s['notes'] ?? '', [for (final x in (s['shots'] as List? ?? [])) x as int], status: s['status'] ?? 'In review')
          ..id = s['id'],
    ],
  )..id = j['id'];
  t.myStatus = j['my_status'] ?? 'Open';
  return t;
}

Map<String, dynamic> ideaJson(Idea i) => {
  'name': i.name, 'pitch': i.pitch, 'sector': i.sector, 'stage': i.stage, 'icon': iconKey(i.icon), 'color': _c(i.color), //
  'founders': [
    for (final f in i.founders) [f.name, f.role, f.college],
  ],
  'problem': i.problem,
  'solution': i.solution,
  'users': i.users,
  'growth': i.growth, 'revenue': i.revenue, 'market': i.market, 'model': i.model, 'ask': i.ask, 'equity': i.equity, 'raised': i.raised,
  'min_ticket': i.minTicket,
  'use_of_funds': [
    for (final u in i.useOfFunds) [u.$1, u.$2],
  ],
  'milestones': i.milestones,
  'spark': i.spark,
};

Idea ideaFrom(Map<String, dynamic> j) =>
    Idea(
        name: j['name'] ?? '',
        pitch: j['pitch'] ?? '',
        sector: j['sector'] ?? '',
        stage: j['stage'] ?? 'Idea',
        icon: iconKeys[j['icon']] ?? Icons.lightbulb_outline_rounded,
        color: Color(j['color'] ?? 0xFF2F8F7A),
        founders: [for (final f in (j['founders'] as List? ?? [])) Founder(f[0], f[1], f[2])],
        problem: j['problem'] ?? '',
        solution: j['solution'] ?? '',
        users: j['users'] ?? 0,
        growth: (j['growth'] ?? 0).toDouble(),
        revenue: j['revenue'] ?? '',
        market: j['market'] ?? '',
        model: j['model'] ?? '',
        ask: (j['ask'] ?? 1).toDouble(),
        equity: (j['equity'] ?? 1).toDouble(),
        raised: (j['raised'] ?? 0).toDouble(),
        minTicket: (j['min_ticket'] ?? 0.5).toDouble(),
        useOfFunds: [for (final u in (j['use_of_funds'] as List? ?? [])) (u[0].toString(), (u[1] as num).toInt())],
        milestones: _ss(j['milestones']),
        spark: [
          for (final x in (j['spark'] as List? ?? [1, 2])) (x as num).toDouble(),
        ],
      )
      ..id = j['id']
      ..decision = j['decision']
      ..myCheque = (j['my_cheque'] ?? 0).toDouble();

/// Everything the backend needs to seed a fresh database (used by tool/export_seed_test.dart).
Map<String, dynamic> seedJson() => {
  'users': [personJson(me), for (final p in people.values) personJson(p)],
  'posts': [for (final p in posts) postJson(p)],
  'events': [for (final e in events) eventJson(e)],
  'opportunities': [for (final o in opportunities) oppJson(o)],
  'tasks': [for (final t in ctasks) taskJson(t)],
  'ideas': [for (final i in ideas) ideaJson(i)],
  'announcements': [for (final a in announcements) annJson(a)],
};
