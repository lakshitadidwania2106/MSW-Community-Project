import 'package:flutter/material.dart';

import 'theme.dart';

/// Shared in-memory store for the UI prototype.
/// Whatever a company / college / student creates is added to these lists,
/// so it shows up everywhere else in the app (e.g. a company's posted job
/// appears with the same details on the student's Explore tab).
/// Swap these for API calls when the backend exists.

const mswLabsUrl = 'https://intern.mystartupwave.com/';

/* ───────────────────────────── roles ───────────────────────────── */

enum Role { student, company, investor, college, admin }

class RoleInfo {
  const RoleInfo(this.role, this.name, this.icon, this.color, this.tagline, this.title, this.italic, this.emailLabel, this.cta, this.features);
  final Role role;
  final String name, tagline, title, italic, emailLabel, cta;
  final IconData icon;
  final Color color;
  final List<String> features;
}

final roles = [
  const RoleInfo(Role.student, 'Student', Icons.school_outlined, Color(0xFF2F8F7A), 'Learn, build, get hired', 'Welcome ', 'back.', 'College email', 'Enter the community', [
    'Reels & the 30-day course',
    'Hackathons, jobs & internships',
    'Digital ID, ideas & credits',
  ]),
  const RoleInfo(Role.company, 'Company', Icons.business_center_outlined, Color(0xFFE8613F), 'Post jobs, tasks & hire', 'Hire by what ', 'they’ve built.', 'Work email', 'Open hiring dashboard', [
    'Post jobs & internships',
    'Allocate paid tasks',
    'Hire from verified IDs',
  ]),
  const RoleInfo(Role.investor, 'Investor', Icons.trending_up_rounded, Color(0xFF5B4FCF), 'Back student ideas early', 'Find founders ', 'early.', 'Email', 'View deal flow', [
    'Discover student startups',
    'Back ideas for equity',
    'Track your portfolio',
  ]),
  const RoleInfo(
    Role.college,
    'College',
    Icons.account_balance_outlined,
    Color(0xFF0A66C2),
    'Host hackathons & events',
    'Host it. ',
    'We’ll handle it.',
    'Institution email',
    'Open campus dashboard',
    ['Host hackathons & events', 'Judge & certify teams', 'Verify students'],
  ),
  const RoleInfo(Role.admin, 'Admin', Icons.admin_panel_settings_outlined, Color(0xFF2F8F7A), 'Stats, quizzes, full control', 'Admin ', 'access.', 'Admin email', 'Unlock control panel', [
    'Platform-wide stats',
    'Override any post, comment or account',
    'Quizzes & badges',
  ]),
];

/* ───────────────────────────── people & posts ───────────────────────────── */

class Person {
  String get id => name.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), '-');
  Person(this.name, this.college, this.course, this.headline, this.bio, this.skills, this.grad, {this.level = 12, this.iq = 120, this.gh = 80, this.followers = 340, this.hackathons = 4});
  final String name, college, course, headline, bio;
  final List<String> skills;
  final List<Color> grad;
  final int level, iq, gh, followers, hackathons;
  bool followed = false;
  String get initials => name.split(' ').map((w) => w[0]).take(2).join();
}

final me = Person(
  'Aanya Sharma',
  'IIT Delhi',
  'B.Tech CSE · 3rd year',
  'Full-stack developer · 3× hackathon finalist',
  'Building in public. Loves React, ML and good typography.',
  ['React', 'Python', 'Figma', 'ML'],
  const [Color(0xFFFF9A76), Color(0xFFC86DD7)],
  level: 14,
  iq: 128,
  gh: 87,
  followers: 1284,
  hackathons: 9,
);

final people = <String, Person>{
  'Rohan Kapoor': Person(
    'Rohan Kapoor',
    'NIT Trichy',
    'B.Tech ECE · 3rd year',
    'Flutter developer · Intern @ Lumen Labs',
    'Mobile apps, IoT and badminton. Shipping one side project a month.',
    ['Flutter', 'Firebase', 'Dart'],
    const [C.tealD, C.sky],
    level: 11,
    iq: 121,
    gh: 79,
    followers: 920,
    hackathons: 5,
  ),
  'Meera Joshi': Person(
    'Meera Joshi',
    'IIT Kharagpur',
    'B.Tech AgE · 4th year',
    'Founder, Krishi · AgriTech',
    'Building ₹200 soil sensors for small farmers. Backed on MSW.',
    ['IoT', 'Python', 'ML'],
    const [C.peach, Color(0xFFC86DD7)],
    level: 17,
    iq: 133,
    gh: 91,
    followers: 2410,
    hackathons: 11,
  ),
  'Kabir Nair': Person(
    'Kabir Nair',
    'AIIMS Delhi',
    'MBBS · 3rd year',
    'Building Pulse · HealthTech',
    'Doctor-in-training writing code for rural clinics.',
    ['Python', 'NLP'],
    const [Color(0xFF6C5CE7), Color(0xFF00D2D3)],
    level: 13,
    iq: 126,
    gh: 72,
    followers: 760,
    hackathons: 3,
  ),
  'Sana Khan': Person(
    'Sana Khan',
    'BITS Pilani',
    'B.E. CS · 4th year',
    'MSW Labs mentor · TypeScript',
    'Teaching Day 15–20 of the full-stack challenge.',
    ['TypeScript', 'GraphQL', 'Node'],
    const [C.sky, Color(0xFF6C5CE7)],
    level: 15,
    iq: 125,
    gh: 89,
    followers: 3100,
    hackathons: 7,
  ),
};

class Comment {
  int? id;
  Comment(this.author, this.text, this.time, {this.likes = 0});
  final Person author;
  final String text, time;
  int likes;
}

class Post {
  int? id;
  String url = '';
  Post({
    required this.author,
    required this.time,
    required this.body,
    required this.src,
    required this.title,
    required this.domain,
    required this.grad,
    required this.likes,
    List<Comment>? comments,
    this.shares = 4,
  }) : comments = comments ?? [];
  final Person author;
  final String time, body, src, title, domain;
  final List<Color> grad;
  final List<Comment> comments;
  int likes, shares;
  bool liked = false, saved = false;
}

Color srcColor(String src) => switch (src) {
  'LinkedIn' => const Color(0xFF0A66C2),
  'Reddit' => const Color(0xFFFF4500),
  'X' => Colors.black,
  'Instagram' => const Color(0xFFD6249F),
  'YouTube' => const Color(0xFFFF0000),
  'Threads' => Colors.black,
  'Medium' => const Color(0xFF1A1A1A),
  'GitHub' => const Color(0xFF24292F),
  'MSW' => C.tealD,
  _ => const Color(0xFF6D6B67),
};

/// Detects the platform of a pasted link.
String? detectSource(String url) {
  final t = url.trim().toLowerCase();
  if (!t.startsWith('http') && !t.contains('.')) return null;
  if (t.contains('x.com') || t.contains('twitter.com')) return 'X';
  if (t.contains('instagram.com')) return 'Instagram';
  if (t.contains('linkedin.com')) return 'LinkedIn';
  if (t.contains('reddit.com')) return 'Reddit';
  if (t.contains('youtube.com') || t.contains('youtu.be')) return 'YouTube';
  if (t.contains('threads.net')) return 'Threads';
  if (t.contains('medium.com')) return 'Medium';
  if (t.contains('github.com')) return 'GitHub';
  return 'Link';
}

final posts = <Post>[
  Post(
    author: me,
    time: '2m',
    body: 'Just shipped my first open-source PR. Thanks MSW Labs Day 21 for the Git deep-dive.',
    src: 'X',
    title: 'Building in public, week 1',
    domain: 'x.com',
    grad: const [C.lime, C.teal],
    likes: 128,
    comments: [Comment(people['Rohan Kapoor']!, 'Congrats! Which repo?', '1m', likes: 3), Comment(people['Sana Khan']!, 'Day 21 students are on fire this week.', '30s', likes: 5)],
  ),
  Post(
    author: people['Rohan Kapoor']!,
    time: '1h',
    body: 'Excited to start my internship at Lumen Labs this summer — found it right here on MSW Careers.',
    src: 'LinkedIn',
    title: 'Rohan joined Lumen Labs',
    domain: 'linkedin.com',
    grad: const [C.sky, Color(0xFF0A66C2)],
    likes: 342,
    comments: [Comment(people['Meera Joshi']!, 'Huge! All the best Rohan.', '40m', likes: 8)],
  ),
  Post(
    author: people['Meera Joshi']!,
    time: '3h',
    body: 'This thread on cracking system design rounds is gold.',
    src: 'Reddit',
    title: 'How I prepped for SDE interviews',
    domain: 'reddit.com',
    grad: const [C.peach, Color(0xFFFF4500)],
    likes: 96,
  ),
  Post(
    author: people['Kabir Nair']!,
    time: '5h',
    body: 'We just crossed 1,000 clinic triages on Pulse. Building in public.',
    src: 'X',
    title: 'Pulse — week 12 update',
    domain: 'x.com',
    grad: const [Color(0xFF6C5CE7), Color(0xFF00D2D3)],
    likes: 211,
  ),
];

/* ───────────────────────────── jobs & internships ───────────────────────────── */

class Opportunity {
  int? id;
  Opportunity({
    required this.title,
    required this.company,
    required this.color,
    required this.internship,
    required this.workMode,
    required this.location,
    required this.pay,
    required this.duration,
    required this.startDate,
    required this.applyBy,
    required this.openings,
    required this.experience,
    required this.skills,
    required this.eligibility,
    required this.about,
    required this.responsibilities,
    required this.perks,
    required this.rounds,
    this.aboutCompany = '',
    this.applicants = 0,
    this.views = 0,
    this.live = true,
  });
  String title, company, workMode, location, pay, duration, startDate, applyBy, experience, about, aboutCompany;
  final Color color;
  bool internship, live;
  int openings, applicants, views;
  List<String> skills, eligibility, responsibilities, perks, rounds;
  bool applied = false, saved = false;
}

final opportunities = <Opportunity>[
  Opportunity(
    title: 'Frontend Developer Intern',
    company: 'Lumen Labs',
    color: const Color(0xFFFF7A59),
    internship: true,
    workMode: 'Remote',
    location: 'Bengaluru (Remote)',
    pay: '₹40,000 / month',
    duration: '3 months',
    startDate: 'Jan 05, 2027',
    applyBy: 'Dec 15, 2026',
    openings: 3,
    experience: 'Freshers welcome',
    skills: ['React', 'TypeScript', 'Tailwind CSS', 'Git'],
    eligibility: ['B.Tech / B.E. / BCA / MCA', 'Batch 2026, 2027, 2028', 'MSW Level 8 or above'],
    about: 'Join the product team building Lumen’s design-to-code platform used by 40k designers. You’ll ship real features to production from week one.',
    responsibilities: [
      'Build responsive UI components in React + TypeScript',
      'Turn Figma designs into pixel-perfect pages',
      'Write tests and review pull requests',
      'Improve Core Web Vitals across the app',
    ],
    perks: ['Certificate', 'Pre-placement offer', 'Flexible hours', 'Letter of recommendation'],
    rounds: ['Profile screening (MSW ID)', 'Take-home task (48 hours)', 'Technical interview', 'Culture-fit chat'],
    aboutCompany: 'Lumen Labs is a Series A design-tooling startup with 60 people across Bengaluru and Berlin.',
    applicants: 128,
    views: 2140,
  ),
  Opportunity(
    title: 'ML Research Intern',
    company: 'Kite AI',
    color: const Color(0xFF3B82F6),
    internship: true,
    workMode: 'On-site',
    location: 'Bengaluru',
    pay: '₹55,000 / month',
    duration: '6 months',
    startDate: 'Feb 01, 2027',
    applyBy: 'Dec 22, 2026',
    openings: 2,
    experience: 'Research projects preferred',
    skills: ['Python', 'PyTorch', 'NLP', 'Statistics'],
    eligibility: ['B.Tech / M.Tech / Dual degree', 'Batch 2026, 2027', 'Strong maths background'],
    about: 'Work with Kite’s research team on small language models for Indian languages.',
    responsibilities: ['Run training experiments and ablations', 'Curate and clean multilingual datasets', 'Write internal research notes'],
    perks: ['Certificate', 'Pre-placement offer', 'GPU credits', 'Free meals'],
    rounds: ['Profile screening', 'ML assignment', 'Two technical interviews'],
    aboutCompany: 'Kite AI builds language models for Bharat. Backed by top Indian VCs.',
    applicants: 86,
    views: 1620,
  ),
  Opportunity(
    title: 'Product Designer',
    company: 'Parallax',
    color: const Color(0xFF111111),
    internship: false,
    workMode: 'Hybrid',
    location: 'Mumbai',
    pay: '₹10 – 14 LPA',
    duration: 'Full-time',
    startDate: 'Immediate',
    applyBy: 'Dec 30, 2026',
    openings: 1,
    experience: '0 – 2 years',
    skills: ['Figma', 'Design systems', 'Prototyping', 'User research'],
    eligibility: ['Any degree', 'Portfolio required'],
    about: 'Own end-to-end design for Parallax’s creator analytics app.',
    responsibilities: ['Design flows from research to hi-fi', 'Maintain the design system', 'Run usability tests every sprint'],
    perks: ['Health insurance', 'Learning budget', 'Flexible hours'],
    rounds: ['Portfolio review', 'Design challenge', 'Founder interview'],
    aboutCompany: 'Parallax helps 20k creators understand their audience.',
    applicants: 42,
    views: 980,
  ),
  Opportunity(
    title: 'SDE I — Backend',
    company: 'Kite AI',
    color: const Color(0xFF3B82F6),
    internship: false,
    workMode: 'On-site',
    location: 'Bengaluru',
    pay: '₹16 – 20 LPA',
    duration: 'Full-time',
    startDate: 'Jul 2027',
    applyBy: 'Jan 10, 2027',
    openings: 4,
    experience: 'Freshers (2027 batch)',
    skills: ['Go', 'PostgreSQL', 'Kubernetes', 'System design'],
    eligibility: ['B.Tech / B.E. CS / IT / ECE', 'Batch 2027', 'CGPA 7.0+'],
    about: 'Build the inference platform that serves Kite’s models to millions of users.',
    responsibilities: ['Design and build APIs in Go', 'Own services end-to-end in production', 'Participate in on-call rotations'],
    perks: ['Joining bonus', 'Health insurance', 'ESOPs'],
    rounds: ['Online assessment', 'Two technical rounds', 'Hiring manager round'],
    applicants: 312,
    views: 4100,
  ),
];

/* ───────────────────────────── hackathons & events ───────────────────────────── */

class EventItem {
  int? id;
  EventItem({
    required this.title,
    required this.tagline,
    required this.type,
    required this.organiser,
    required this.mode,
    required this.venue,
    required this.dates,
    required this.regDeadline,
    required this.base,
    required this.blobs,
    required this.secondsLeft,
    required this.about,
    this.prizePool = '',
    this.prizes = const [],
    this.teamSize = 'Individual',
    this.eligibility = const [],
    this.tracks = const [],
    this.timeline = const [],
    this.perks = const [],
    this.seats = 300,
    this.registered = 0,
    this.mine = false,
  });
  String title, tagline, type, organiser, mode, venue, dates, regDeadline, about, prizePool, teamSize;
  final Color base;
  final List<Color> blobs;
  final int secondsLeft;
  List<(String, String)> prizes, timeline;
  List<String> eligibility, tracks, perks;
  int seats, registered;
  bool going = false, mine;
  bool get isHackathon => type == 'Hackathon';
}

final events = <EventItem>[
  EventItem(
    title: 'HackNova ’26',
    tagline: '48 hours. AI for Bharat.',
    type: 'Hackathon',
    organiser: 'MSW Community × IIT Delhi',
    mode: 'Online',
    venue: 'Online · Discord + MSW',
    dates: 'Mar 14 – 16, 2027',
    regDeadline: 'Mar 10, 2027',
    base: const Color(0xFF1B1464),
    blobs: const [Color(0xFF6C5CE7), Color(0xFF00D2D3), C.lime],
    secondsLeft: 1052537,
    about: 'Build AI products that work for the next billion users — in Indian languages, on low-end phones, on patchy networks. Mentors from Kite AI and Lumen Labs.',
    prizePool: '₹5,00,000',
    prizes: [('Winner', '₹2,50,000 + incubation'), ('1st runner-up', '₹1,50,000'), ('2nd runner-up', '₹75,000'), ('Best student team', '₹25,000')],
    teamSize: '1 – 4 members',
    eligibility: ['Open to all college students in India', 'Inter-college teams allowed'],
    tracks: ['Language AI', 'AgriTech', 'HealthTech', 'Open innovation'],
    timeline: [('Registrations close', 'Mar 10'), ('Hacking starts', 'Mar 14 · 6 PM'), ('Mentor check-in', 'Mar 15 · 2 PM'), ('Submissions close', 'Mar 16 · 6 PM'), ('Results', 'Mar 20')],
    perks: ['Certificates for all', 'Swag for finalists', 'Internship interviews'],
    seats: 2000,
    registered: 1440,
  ),
  EventItem(
    title: 'Design Sprint',
    tagline: 'UI/UX, 12 hours, one brief.',
    type: 'Hackathon',
    organiser: 'IIT Bombay E-Cell',
    mode: 'In person',
    venue: 'VMCC, IIT Bombay, Mumbai',
    dates: 'Apr 02, 2027',
    regDeadline: 'Mar 28, 2027',
    base: const Color(0xFFFF7A59),
    blobs: const [Color(0xFFFFD166), Color(0xFFEF476F), Colors.white],
    secondsLeft: 2718480,
    about: 'A one-day design hackathon. You get the brief at 9 AM and present a clickable prototype by 9 PM.',
    prizePool: '₹1,50,000',
    prizes: [('Winner', '₹75,000'), ('Runner-up', '₹50,000'), ('People’s choice', '₹25,000')],
    teamSize: 'Solo',
    eligibility: ['Undergraduate & postgraduate students', 'Portfolio link required'],
    tracks: ['Mobile', 'Accessibility'],
    timeline: [('Registrations close', 'Mar 28'), ('Brief released', 'Apr 02 · 9 AM'), ('Final pitches', 'Apr 02 · 7 PM')],
    perks: ['Figma Pro for a year', 'Certificates'],
    seats: 200,
    registered: 188,
  ),
  EventItem(
    title: 'React Hooks Workshop',
    tagline: 'Hands-on, 2 hours, live coding.',
    type: 'Workshop',
    organiser: 'MSW Labs',
    mode: 'Online',
    venue: 'Google Meet',
    dates: 'Dec 06, 2026 · 6 PM',
    regDeadline: 'Dec 06, 2026',
    base: const Color(0xFF0F3D2E),
    blobs: const [C.tealD, C.lime, C.sky],
    secondsLeft: 1052537 ~/ 4,
    about: 'Learn useState, useEffect and custom hooks by building a tiny habit tracker together. Recording shared after.',
    teamSize: 'Individual',
    eligibility: ['Anyone who finished MSW Labs Day 10'],
    timeline: [('Live session', 'Dec 06 · 6 – 8 PM')],
    perks: ['Certificate of participation'],
    seats: 500,
    registered: 312,
  ),
  EventItem(
    title: 'Founders Fireside',
    tagline: 'From dorm room to pre-seed.',
    type: 'Meetup',
    organiser: 'IIT Bombay E-Cell',
    mode: 'In person',
    venue: 'LH 101, IIT Bombay',
    dates: 'Dec 12, 2026 · 7 PM',
    regDeadline: 'Dec 11, 2026',
    base: const Color(0xFF0A66C2),
    blobs: const [C.sky, Color(0xFF00D2D3), Colors.white],
    secondsLeft: 1572000,
    about: 'Three student founders backed on MSW talk about their first ₹10L, their first hire and their first mistakes.',
    eligibility: ['Open to all'],
    timeline: [('Doors open', '6:30 PM'), ('Fireside chat', '7 – 8 PM'), ('Networking', '8 – 9 PM')],
    seats: 150,
    registered: 96,
  ),
];

/* ───────────────────────────── company tasks ───────────────────────────── */

class Submission {
  int? id;
  Submission(this.student, this.repo, this.demo, this.notes, this.shots, {this.status = 'In review'});
  final Person student;
  final String repo, demo, notes;
  final List<int> shots; // placeholder screenshot ids
  String status; // In review · Approved · Changes requested
}

class CTask {
  int? id;
  CTask({
    required this.title,
    required this.company,
    required this.color,
    required this.reward,
    required this.days,
    required this.level,
    required this.stack,
    required this.repo,
    required this.description,
    required this.deliverables,
    required this.acceptance,
    List<Submission>? submissions,
  }) : submissions = submissions ?? [];
  String title, company, repo, description;
  final Color color;
  int reward, days, level;
  List<String> stack, deliverables, acceptance;
  final List<Submission> submissions;
  String myStatus = 'Open'; // Open · In progress · Submitted · Approved
}

final ctasks = <CTask>[
  CTask(
    title: 'Fix checkout bug on mobile web',
    company: 'Lumen Labs',
    color: const Color(0xFFFF7A59),
    reward: 3000,
    days: 3,
    level: 2,
    stack: ['JavaScript', 'React', 'Debugging'],
    repo: 'github.com/lumen-labs/storefront',
    description: 'On iOS Safari the “Pay now” button jumps under the keyboard and the order is submitted twice. Find the root cause and fix it without breaking desktop.',
    deliverables: ['Pull request against the main branch', 'Short Loom or screenshots showing the fix on iOS', 'Note explaining the root cause'],
    acceptance: ['No double submission on iOS Safari & Chrome', 'All existing tests pass', 'No layout shift on desktop'],
    submissions: [
      Submission(
        people['Sana Khan']!,
        'github.com/sana-k/storefront/pull/42',
        'storefront-fix.vercel.app',
        'Root cause was a duplicate onSubmit on the form and the button. Added a disabled state while the request is in flight.',
        [3, 7, 9],
      ),
    ],
  ),
  CTask(
    title: 'Accessibility audit of dashboard',
    company: 'Lumen Labs',
    color: const Color(0xFFFF7A59),
    reward: 4500,
    days: 5,
    level: 2,
    stack: ['Accessibility', 'Figma', 'WCAG'],
    repo: 'github.com/lumen-labs/dashboard',
    description: 'Audit the analytics dashboard against WCAG 2.2 AA and fix the top 10 issues.',
    deliverables: ['Audit report (Figma or Notion)', 'PR fixing at least 10 issues'],
    acceptance: ['Lighthouse accessibility score ≥ 95', 'Keyboard-only navigation works everywhere'],
    submissions: [
      Submission(people['Rohan Kapoor']!, 'github.com/rohan-k/dashboard/pull/7', 'figma.com/file/a11y-audit', 'Fixed contrast on 14 components, added focus rings and skip links.', [12, 15]),
    ],
  ),
  CTask(
    title: 'Clean 10k rows of survey data',
    company: 'Kite AI',
    color: const Color(0xFF3B82F6),
    reward: 2200,
    days: 5,
    level: 1,
    stack: ['Python', 'Pandas'],
    repo: 'github.com/kite-ai/survey-cleaning',
    description: 'Deduplicate, normalise and label 10k rows of multilingual survey responses.',
    deliverables: ['Cleaned CSV', 'Notebook with the cleaning steps'],
    acceptance: ['No duplicate respondents', 'Language column filled for every row'],
  ),
  CTask(
    title: 'Build a Flutter onboarding flow',
    company: 'Parallax',
    color: const Color(0xFF111111),
    reward: 6000,
    days: 7,
    level: 3,
    stack: ['Flutter', 'Dart', 'UI'],
    repo: 'github.com/parallax-hq/creator-app',
    description: 'Build the 3-screen onboarding from our Figma file with animations and form validation.',
    deliverables: ['PR with the onboarding module', 'Screen recording on Android & iOS'],
    acceptance: ['Matches Figma within 4 px', '60 fps transitions', 'Unit tests for validation'],
  ),
];

/* ───────────────────────────── startup ideas (investors) ───────────────────────────── */

class Founder {
  const Founder(this.name, this.role, this.college);
  final String name, role, college;
}

class Idea {
  int? id;
  String? decision; // 'backed' · 'passed'
  double myCheque = 0;
  Idea({
    required this.name,
    required this.pitch,
    required this.sector,
    required this.stage,
    required this.icon,
    required this.color,
    required this.founders,
    required this.problem,
    required this.solution,
    required this.users,
    required this.growth,
    required this.revenue,
    required this.market,
    required this.model,
    required this.ask,
    required this.equity,
    required this.raised,
    required this.minTicket,
    required this.useOfFunds,
    required this.milestones,
    required this.spark,
  });
  final String name, pitch, sector, stage, problem, solution, revenue, market, model;
  final IconData icon;
  final Color color;
  final List<Founder> founders;
  final int users;
  final double growth, ask, equity, minTicket; // ask in ₹ lakh, equity %, min ticket ₹ lakh
  double raised;
  final List<(String, int)> useOfFunds;
  final List<String> milestones;
  final List<double> spark;
  bool saved = false;
  double get valuation => ask / equity * 100; // post-money, ₹ lakh
}

final ideas = <Idea>[
  Idea(
    name: 'Krishi',
    pitch: 'Soil health reports from a ₹200 sensor, delivered over SMS.',
    sector: 'AgriTech',
    stage: 'Seed',
    icon: Icons.grass_rounded,
    color: C.tealD,
    founders: const [Founder('Meera Joshi', 'CEO · hardware', 'IIT Kharagpur'), Founder('Varun Tiwari', 'CTO · firmware', 'IIT Kharagpur')],
    problem: '86% of Indian farmers are smallholders who over-use fertiliser because soil tests cost ₹1,500 and take weeks.',
    solution: 'A ₹200 probe that reads NPK and moisture, plus SMS advice in 9 languages. Works without a smartphone.',
    users: 1840,
    growth: 38,
    revenue: '₹1.2L MRR',
    market: '₹4,800 Cr soil-testing market (India)',
    model: 'Sensor sale ₹200 + ₹49/season advisory subscription',
    ask: 10,
    equity: 8,
    raised: 7.8,
    minTicket: 0.5,
    useOfFunds: [('Manufacturing', 40), ('Field team', 30), ('Product', 20), ('Ops & legal', 10)],
    milestones: ['10,000 farmers by Sep 2027', 'Pilot with Maharashtra agri dept', 'Break-even in 18 months'],
    spark: [2, 3, 5, 6, 9, 12, 15, 21],
  ),
  Idea(
    name: 'Nibble',
    pitch: 'Exam prep in 5-minute bites, built for the commute.',
    sector: 'EdTech',
    stage: 'Pre-seed',
    icon: Icons.menu_book_rounded,
    color: const Color(0xFF6C5CE7),
    founders: const [Founder('Arjun Rao', 'CEO · product', 'DTU'), Founder('Sana Khan', 'CTO', 'BITS Pilani')],
    problem: 'Students preparing for competitive exams lose 2+ hours a day commuting and can’t study on long-form apps.',
    solution: 'Swipeable 5-minute lessons with spaced repetition and offline mode.',
    users: 12400,
    growth: 52,
    revenue: '₹40k MRR',
    market: '₹58,000 Cr test-prep market',
    model: 'Freemium · ₹99/month for full syllabus',
    ask: 5,
    equity: 6,
    raised: 2.3,
    minTicket: 0.25,
    useOfFunds: [('Content', 45), ('Marketing', 30), ('Engineering', 25)],
    milestones: ['50,000 learners', 'Launch Hindi & Tamil', 'B2B with 10 coaching centres'],
    spark: [3, 4, 4, 7, 8, 11, 14, 19],
  ),
  Idea(
    name: 'Pulse',
    pitch: 'AI triage for rural clinics, in the patient’s language.',
    sector: 'HealthTech',
    stage: 'Idea',
    icon: Icons.monitor_heart_outlined,
    color: const Color(0xFFE8613F),
    founders: const [Founder('Kabir Nair', 'CEO · clinician', 'AIIMS Delhi')],
    problem: 'One doctor sees 80+ patients a day in rural PHCs; triage is done by hand on paper.',
    solution: 'A voice-first triage assistant that prioritises patients and pre-fills case sheets.',
    users: 1020,
    growth: 45,
    revenue: 'Pre-revenue',
    market: '25,000 PHCs across India',
    model: 'Per-clinic SaaS · ₹2,000/month',
    ask: 5,
    equity: 10,
    raised: 1.1,
    minTicket: 0.5,
    useOfFunds: [('Clinical pilots', 50), ('Engineering', 35), ('Compliance', 15)],
    milestones: ['Pilot in 20 clinics', 'CDSCO pathway started'],
    spark: [1, 1, 2, 2, 3, 5, 6, 9],
  ),
  Idea(
    name: 'Ledgerly',
    pitch: 'UPI bookkeeping for kirana stores — zero typing.',
    sector: 'FinTech',
    stage: 'Seed',
    icon: Icons.account_balance_wallet_outlined,
    color: const Color(0xFF0A66C2),
    founders: const [Founder('Rhea Pillai', 'CEO', 'IIIT Hyderabad'), Founder('Dev Shah', 'Engineering', 'VIT')],
    problem: 'Kirana owners get 300+ UPI payments a day and still keep a paper ledger.',
    solution: 'Auto-reconciles UPI payments, credit (udhaar) and stock into a daily WhatsApp summary.',
    users: 3300,
    growth: 27,
    revenue: '₹2.6L MRR',
    market: '1.3 Cr kirana stores',
    model: '₹149/month subscription',
    ask: 15,
    equity: 7,
    raised: 6.4,
    minTicket: 1,
    useOfFunds: [('Sales', 40), ('Engineering', 35), ('Support', 25)],
    milestones: ['10,000 paying stores', 'Lending partnership'],
    spark: [4, 5, 7, 8, 8, 10, 13, 16],
  ),
  Idea(
    name: 'Volt',
    pitch: 'Battery swapping stations for e-rickshaws.',
    sector: 'Climate',
    stage: 'Idea',
    icon: Icons.electric_bolt_rounded,
    color: const Color(0xFFC6A400),
    founders: const [Founder('Ishaan Mehta', 'CEO', 'IIT Delhi')],
    problem: 'E-rickshaw drivers lose 4 hours a day charging lead-acid batteries.',
    solution: 'Swap a charged lithium pack in 2 minutes at neighbourhood kiosks.',
    users: 140,
    growth: 60,
    revenue: '₹18k MRR',
    market: '20 lakh e-rickshaws in India',
    model: 'Per-swap fee ₹60',
    ask: 8,
    equity: 12,
    raised: 0.4,
    minTicket: 0.5,
    useOfFunds: [('Batteries', 55), ('Kiosks', 30), ('Team', 15)],
    milestones: ['10 kiosks in East Delhi', '500 daily swaps'],
    spark: [1, 1, 1, 2, 2, 3, 3, 4],
  ),
];

/* ───────────────────────────── learning, badges, blogs, quiz ───────────────────────────── */

/// MSW Labs — 30-Day Full-Stack Challenge, as reels.
final reelTopics = [
  'Hello, Web — how the internet works',
  'HTML in 60 seconds',
  'CSS that doesn’t fight you',
  'Flexbox & Grid, finally clear',
  'JavaScript: the 5 things that matter',
  'The DOM, explained with LEGO',
  'APIs explained with pizza',
  'Git & GitHub for humans',
  'React: why components?',
  'Props vs state',
  'Hooks without the headache',
  'Routing in a Next.js app',
  'Tailwind speed-run',
  'Mini project: your portfolio',
  'Node & Express basics',
  'Designing a clean REST API',
  'SQL you’ll actually use',
  'Auth & JWT, simply',
  'FastAPI in Python',
  'Testing that saves you',
  'Git like a senior engineer',
  'Deploy it to the world',
  'Docker in one reel',
  'System design: URL shortener',
  'Caching, the cheat code',
  'Make it fast: performance',
  'Security basics every dev needs',
  'Build a portfolio that gets calls',
  'Interview prep: the playbook',
  'Ship it. Your capstone.',
];

const reelPalettes = [
  [Color(0xFF0B1530), Color(0xFF3A7BD5), Color(0xFF00D2D3)],
  [Color(0xFF2B0F2E), Color(0xFFE96443), Color(0xFFFFB38A)],
  [Color(0xFF06201B), Color(0xFF2F8F7A), C.lime],
  [Color(0xFF150B2E), Color(0xFF8E54E9), Color(0xFFFF7AD9)],
  [Color(0xFF241D00), Color(0xFFC6A400), Color(0xFFFF7A59)],
];

class BadgeItem {
  const BadgeItem(this.icon, this.name, this.earned);
  final IconData icon;
  final String name;
  final bool earned;
}

const badges = [
  BadgeItem(Icons.local_fire_department_rounded, '12-day streak', true),
  BadgeItem(Icons.emoji_events_rounded, 'Hackathon winner', true),
  BadgeItem(Icons.psychology_rounded, 'IQ 120+', true),
  BadgeItem(Icons.bolt_rounded, 'First task', true),
  BadgeItem(Icons.rocket_launch_rounded, 'Shipped capstone', false),
  BadgeItem(Icons.diamond_rounded, 'Top 1%', false),
];

class Blog {
  const Blog(this.title, this.cat, this.mins, this.colors, {this.author = 'MSW Journal'});
  final String title, cat, author;
  final int mins;
  final List<Color> colors;
}

final blogs = <Blog>[
  const Blog('How I won 3 hackathons in my 2nd year', 'Hackathons', 7, [C.lime, C.tealD], author: 'Aanya Sharma'),
  const Blog('The internship cold email that got 9 replies', 'Careers', 6, [Color(0xFFFFD166), Color(0xFFFF7A59)], author: 'Rohan Kapoor'),
  const Blog('From dorm-room idea to ₹10L pre-seed', 'Founders', 5, [C.lilac, C.sky], author: 'Meera Joshi'),
];

class Question {
  const Question(this.q, this.options, this.answer);
  final String q;
  final List<String> options;
  final int answer;
}

const iqQuestions = [
  Question('What comes next?  2, 6, 12, 20, 30, …', ['40', '42', '44', '36'], 1),
  Question('If all Bloops are Razzies and all Razzies are Lazzies, are all Bloops definitely Lazzies?', ['Yes', 'No', 'Cannot say'], 0),
  Question('Which word is the odd one out?', ['Python', 'Java', 'Cobra', 'Rust'], 2),
  Question('A clock shows 3:15. What is the angle between the hands?', ['0°', '7.5°', '15°', '22.5°'], 1),
  Question('Book is to Reading as Fork is to…', ['Drawing', 'Writing', 'Eating', 'Stirring'], 2),
];

/* ───────────────────────────── college announcements ───────────────────────────── */

class Announcement {
  Announcement({required this.title, required this.body, required this.organiser, required this.time, this.category = 'General', this.link = '', this.pinned = false});
  int? id;
  String title, body, organiser, time, category, link;
  bool pinned;
}

final announcements = <Announcement>[
  Announcement(
    title: 'E-Summit 2027 dates are out',
    body: 'Asia’s largest student-run entrepreneurship summit is back on Jan 18 – 19. Hackathon, startup expo and 40+ speakers.',
    organiser: 'IIT Bombay E-Cell',
    time: '2h',
    category: 'Event',
    pinned: true,
  ),
  Announcement(
    title: 'Design Sprint registrations close Mar 28',
    body: 'Solo designers only. Bring a portfolio link — shortlist is announced on Mar 30.',
    organiser: 'IIT Bombay E-Cell',
    time: '1d',
    category: 'Deadline',
  ),
  Announcement(
    title: 'Mentor office hours every Friday',
    body: 'Book a 20-minute slot with founders from our alumni network. Open to all MSW students.',
    organiser: 'IIT Bombay E-Cell',
    time: '3d',
    category: 'Opportunity',
    link: 'msw.community/iitb/office-hours',
  ),
];

/* ───────────────────────────── stories (what’s happening) ───────────────────────────── */

class StorySlide {
  const StorySlide(this.kicker, this.headline, this.body);
  final String kicker, headline, body;
}

class Story {
  Story(this.topic, this.icon, this.colors, this.slides, {this.trending = false});
  int? id;
  final String topic;
  final IconData icon;
  final List<Color> colors;
  final List<StorySlide> slides;
  final bool trending;
  bool seen = false;
}

final stories = <Story>[
  Story(
    'Agentic AI',
    Icons.smart_toy_outlined,
    const [Color(0xFF6C5CE7), Color(0xFF00D2D3)],
    const [
      StorySlide(
        'EXPLAINER',
        'AI that acts, not just answers.',
        'Agentic AI systems plan multi-step tasks, call tools and APIs, and check their own work — like an intern that can book, code and research.',
      ),
      StorySlide('WHY IT MATTERS', 'Every app is getting an agent.', 'Students who can build with tool-calling, memory and evaluation are among the most hired profiles this season.'),
      StorySlide('TRY THIS WEEK', 'Ship a tiny agent.', 'Build an agent that reads your college notice board and messages you deadlines. MSW Labs Day 19 covers the API basics.'),
    ],
    trending: true,
  ),
  Story(
    'FinTech',
    Icons.account_balance_wallet_outlined,
    const [Color(0xFF0A66C2), Color(0xFF9FD3FF)],
    const [
      StorySlide('TRENDING', 'UPI everywhere.', 'Credit lines on UPI, small-business bookkeeping and cross-border payments are where student fintech founders are building.'),
      StorySlide('ON MSW', 'Ledgerly is raising.', 'A student team from IIIT Hyderabad is building UPI bookkeeping for kirana stores. See it in the investor deal flow.'),
    ],
  ),
  Story(
    'AI',
    Icons.auto_awesome_outlined,
    const [Color(0xFF121212), Color(0xFF7FD1BD)],
    const [
      StorySlide('SKILL OF THE MONTH', 'Small models, big wins.', 'Fine-tuned small language models now run on laptops and phones. Great territory for hackathon projects.'),
      StorySlide('RESOURCE', 'Prompting is a design skill.', 'Write clear instructions, give examples, and test against a fixed set of inputs before you ship.'),
    ],
  ),
  Story(
    'Markets',
    Icons.candlestick_chart_outlined,
    const [Color(0xFF14A44D), Color(0xFFD4F56B)],
    const [
      StorySlide('MONEY 101', 'Start with an index fund.', 'A monthly SIP into a broad index fund beats trying to pick stocks for most first-time investors. Learn before you trade.'),
      StorySlide('JARGON BUSTER', 'P/E, simply.', 'Price-to-earnings tells you how many years of today’s profit you are paying for. Higher is not always worse — growth matters.'),
    ],
  ),
  Story(
    'Startups',
    Icons.rocket_launch_outlined,
    const [Color(0xFFE8613F), Color(0xFFFFB38A)],
    const [
      StorySlide('ON MSW', '₹42 Cr committed.', 'Investors on MSW have committed ₹42 Cr to student startups. AgriTech and EdTech lead this month.'),
      StorySlide('PLAYBOOK', 'Validate before you build.', 'Talk to 20 users, pitch the idea on MSW for a validation score, then build the smallest version that proves it.'),
    ],
  ),
  Story(
    'Climate',
    Icons.eco_outlined,
    const [Color(0xFF0F3D2E), Color(0xFF2F8F7A)],
    const [StorySlide('OPPORTUNITY', 'Climate needs builders.', 'EV charging, battery swapping, grid forecasting and agri-sensors are open problems with real funding.')],
  ),
  Story(
    'Top blog',
    Icons.local_fire_department_outlined,
    const [Color(0xFFC6A400), Color(0xFFFF7A59)],
    const [
      StorySlide('MOST READ ON MSW', 'How I won 3 hackathons in my 2nd year.', 'Aanya Sharma’s playbook: pick a sharp problem, split work in the first hour, and pitch the demo — not the slides.'),
      StorySlide('ALSO TRENDING', 'The cold email that got 9 replies.', 'Rohan Kapoor shares the exact template that landed his Lumen Labs internship.'),
    ],
    trending: true,
  ),
];
