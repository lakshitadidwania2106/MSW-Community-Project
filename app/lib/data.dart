import 'package:flutter/material.dart';

import 'theme.dart';

/// All mock data for the UI. Swap these for API calls when the backend exists.

enum Role { student, company, investor, college, admin }

class RoleInfo {
  const RoleInfo(this.role, this.name, this.emoji, this.color, this.tagline, this.headline, this.emailLabel, this.cta, this.features);
  final Role role;
  final String name, emoji, tagline, headline, emailLabel, cta;
  final Color color;
  final List<String> features;
  IconData get icon => switch (role) {
    Role.student => Icons.school_rounded,
    Role.company => Icons.business_center_rounded,
    Role.investor => Icons.trending_up_rounded,
    Role.college => Icons.account_balance_rounded,
    Role.admin => Icons.shield_moon_rounded,
  };
}

final roles = [
  const RoleInfo(Role.student, 'Student', '🎓', Color(0xFF6C5CE7), 'Learn, build, get hired', 'READY TO\nBUILD?', 'College email', 'Enter the community', [
    'Reels & the 30-day course',
    'Hackathons, jobs & internships',
    'Digital ID, ideas & credits',
  ]),
  const RoleInfo(Role.company, 'Company', '💼', Color(0xFFE8613F), 'Post jobs, tasks & hire', 'FIND YOUR\nNEXT HIRE.', 'Work email', 'Open hiring dashboard', [
    'Post jobs & internships',
    'Allocate paid tasks',
    'Hire from verified IDs',
  ]),
  const RoleInfo(Role.investor, 'Investor', '📈', Color(0xFF5B4FCF), 'Back student ideas early', 'BACK IT\nEARLY.', 'Email', 'View deal flow', [
    'Discover student startups',
    'Back & track your portfolio',
    'Pitch days & founders',
  ]),
  const RoleInfo(Role.college, 'College', '🏛', Color(0xFF0A66C2), 'Host hackathons & events', 'HOST THE\nNEXT HACK.', 'Institution email', 'Open campus dashboard', [
    'Host hackathons & events',
    'Judge & certify teams',
    'Verify students & placements',
  ]),
  const RoleInfo(Role.admin, 'Admin', '🛡', Color(0xFF2F8F7A), 'Tasks, quizzes, full control', 'MISSION\nCONTROL.', 'Admin email', 'Unlock control panel', [
    'Allocate tasks & quizzes',
    'Approve contributions',
    'Full platform control',
  ]),
];

class Post {
  Post({
    required this.name,
    required this.initials,
    required this.meta,
    required this.body,
    required this.src,
    required this.title,
    required this.domain,
    required this.grad,
    required this.likes,
    this.comments = 12,
  });
  final String name, initials, meta, body, src, title, domain;
  final List<Color> grad;
  int likes, comments;
  bool liked = false;
}

Color srcColor(String src) => switch (src) {
  'LinkedIn' => const Color(0xFF0A66C2),
  'Reddit' => const Color(0xFFFF4500),
  'X' => Colors.black,
  _ => C.tealD,
};

final posts = <Post>[
  Post(
    name: 'Aanya Sharma',
    initials: 'AS',
    meta: 'IIT Delhi · 2m',
    body: 'Just shipped my first open-source PR 🚀 Thanks MSW Labs Day 21 for the Git deep-dive.',
    src: 'X',
    title: 'Building in public, week 1',
    domain: 'x.com',
    grad: const [C.lime, C.teal],
    likes: 128,
    comments: 24,
  ),
  Post(
    name: 'Rohan Kapoor',
    initials: 'RK',
    meta: 'NIT Trichy · 1h',
    body: 'Excited to start my internship at Lumen Labs this summer — found it right here on MSW Careers!',
    src: 'LinkedIn',
    title: 'Rohan joined Lumen Labs',
    domain: 'linkedin.com',
    grad: const [C.sky, Color(0xFF0A66C2)],
    likes: 342,
    comments: 51,
  ),
  Post(
    name: 'Meera Joshi',
    initials: 'MJ',
    meta: 'IIT KGP · 3h',
    body: 'This thread on cracking system design rounds is gold 👇',
    src: 'Reddit',
    title: 'How I prepped for SDE interviews',
    domain: 'reddit.com',
    grad: const [C.peach, Color(0xFFFF4500)],
    likes: 96,
    comments: 18,
  ),
];

class Hackathon {
  const Hackathon(this.name, this.tagline, this.date, this.where, this.prize, this.team, this.base, this.blobs, this.secondsLeft, {this.dark = true});
  final String name, tagline, date, where, prize, team;
  final Color base;
  final List<Color> blobs;
  final int secondsLeft;
  final bool dark;
}

final hackathons = [
  Hackathon('HackNova ’26', '48 hours. AI for Bharat.', 'MAR 14–16', 'Online', '₹5,00,000', '1–4 / team', Color(0xFF1B1464), [Color(0xFF6C5CE7), Color(0xFF00D2D3), C.lime], 1052537),
  Hackathon('Design Sprint', 'UI/UX, 12 hours, one brief.', 'APR 02', 'IIT Bombay', '₹1,50,000', 'Solo', Color(0xFFFF7A59), [Color(0xFFFFD166), Color(0xFFEF476F), Colors.white], 2718480),
  Hackathon('Climate Code', 'Hack for a greener grid.', 'APR 20', 'Hybrid', '₹3,00,000', '2–5 / team', Color(0xFF0F3D2E), [C.tealD, C.lime, C.sky], 4243200),
  Hackathon('FinTech Forge', 'Rebuild money for Gen Z.', 'MAY 24', 'BITS Pilani', '₹2,00,000', '2–4 / team', Color(0xFF3A0CA3), [Color(0xFFF72585), Color(0xFF4CC9F0), Color(0xFFFFD60A)], 7238100),
];

class Job {
  const Job(this.role, this.company, this.meta, this.pay, this.logo, this.color, this.tags, {this.intern = true});
  final String role, company, meta, pay, logo;
  final bool intern;
  final Color color;
  final List<String> tags;
}

final jobs = [
  Job('Frontend Intern', 'Lumen Labs', 'Remote · 3 months', '₹40k/mo', 'L', Color(0xFFFF7A59), ['React', 'Tailwind']),
  Job('ML Research Intern', 'Kite AI', 'Bengaluru · 6 months', '₹55k/mo', 'K', Color(0xFF3B82F6), ['Python', 'PyTorch']),
  Job('Product Designer', 'Parallax', 'Full-time · Hybrid', '₹12 LPA', 'P', Color(0xFF111111), ['Figma', 'Systems'], intern: false),
  Job('Flutter Developer', 'Northwind', 'Full-time · Remote', '₹9 LPA', 'N', Color(0xFF6C5CE7), ['Flutter', 'Dart'], intern: false),
  Job('SDE I', 'Kite AI', 'Full-time · Bengaluru', '₹18 LPA', 'K', Color(0xFF3B82F6), ['Python', 'Systems'], intern: false),
  Job('Backend Intern', 'Helio', 'Pune · 4 months', '₹35k/mo', 'H', Color(0xFF2F8F7A), ['FastAPI', 'Postgres']),
];

class TaskItem {
  const TaskItem(this.title, this.company, this.reward, this.days, this.level, this.skills, this.color);
  final String title, company, reward;
  final int days, level;
  final List<String> skills;
  final Color color;
}

final tasks = [
  TaskItem('Fix checkout bug on mobile web', 'Helio', '₹3,000', 3, 2, ['JavaScript', 'Debugging'], Color(0xFF2F8F7A)),
  TaskItem('Clean 10k rows of survey data', 'Kite AI', '₹2,200', 5, 1, ['Python', 'Pandas'], Color(0xFF3B82F6)),
  TaskItem('Landing page copy for launch', 'Northwind', '₹1,500', 2, 1, ['Writing', 'Marketing'], Color(0xFFFF7A59)),
  TaskItem('Build a Flutter onboarding flow', 'Parallax', '₹6,000', 7, 3, ['Flutter', 'UI'], Color(0xFF111111)),
];

class Idea {
  const Idea(this.name, this.pitch, this.by, this.sector, this.stage, this.raised, this.goal);
  final String name, pitch, by, sector, stage;
  final double raised, goal;
}

final ideas = [
  Idea('Krishi', 'Soil health from a ₹200 sensor', 'Meera J. · IIT Kharagpur', 'AgriTech', 'Seed', 7.8, 10),
  Idea('Nibble', 'Exam prep in 5-minute bites', 'Arjun & Sana · DTU', 'EdTech', 'Pre-seed', 2.3, 5),
  Idea('Pulse', 'AI triage for rural clinics', 'Kabir N. · AIIMS', 'HealthTech', 'Idea', 1.1, 5),
];

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

final reelPalettes = [
  [Color(0xFF0B1530), Color(0xFF3A7BD5), Color(0xFF00D2D3)],
  [Color(0xFF2B0F2E), Color(0xFFE96443), Color(0xFFFFB38A)],
  [Color(0xFF06201B), Color(0xFF2F8F7A), C.lime],
  [Color(0xFF150B2E), Color(0xFF8E54E9), Color(0xFFFF7AD9)],
  [Color(0xFF241D00), Color(0xFFC6A400), Color(0xFFFF7A59)],
];

class BadgeItem {
  const BadgeItem(this.emoji, this.name, this.earned);
  final String emoji, name;
  final bool earned;
}

final badges = [
  BadgeItem('🔥', '12-day streak', true),
  BadgeItem('🏆', 'Hackathon winner', true),
  BadgeItem('🧠', 'IQ 120+', true),
  BadgeItem('⚡', 'First task', true),
  BadgeItem('🚀', 'Shipped capstone', false),
  BadgeItem('💎', 'Top 1%', false),
];

class Blog {
  const Blog(this.title, this.cat, this.mins, this.colors);
  final String title, cat;
  final int mins;
  final List<Color> colors;
}

final blogs = [
  Blog('How I won 3 hackathons in my 2nd year', 'Hackathons', 7, [C.lime, C.tealD]),
  Blog('The internship cold email that got 9 replies', 'Careers', 6, [Color(0xFFFFD166), Color(0xFFFF7A59)]),
  Blog('From dorm-room idea to ₹10L pre-seed', 'Founders', 5, [C.lilac, C.sky]),
];

class Question {
  const Question(this.q, this.options, this.answer);
  final String q;
  final List<String> options;
  final int answer;
}

final iqQuestions = [
  Question('What comes next?  2, 6, 12, 20, 30, …', ['40', '42', '44', '36'], 1),
  Question('If all Bloops are Razzies and all Razzies are Lazzies, are all Bloops definitely Lazzies?', ['Yes', 'No', 'Cannot say'], 0),
  Question('Which word is the odd one out?', ['Python', 'Java', 'Cobra', 'Rust'], 2),
  Question('A clock shows 3:15. What is the angle between the hands?', ['0°', '7.5°', '15°', '22.5°'], 1),
  Question('Book is to Reading as Fork is to…', ['Drawing', 'Writing', 'Eating', 'Stirring'], 2),
];

class EventItem {
  EventItem(this.name, this.type, this.when, this.where, this.host, this.color, {this.mine = false});
  final String name, type, when, where, host;
  final Color color;
  final bool mine;
}

final events = <EventItem>[
  EventItem('React Hooks Workshop', 'Workshop', 'Dec 06 · 6 PM', 'Online', 'MSW Labs', C.tealD),
  EventItem('Founders Fireside', 'Meetup', 'Dec 12 · 7 PM', 'IIT Bombay', 'IIT Bombay E-Cell', const Color(0xFF0A66C2)),
  EventItem('Resume Teardown Live', 'Webinar', 'Dec 15 · 5 PM', 'YouTube Live', 'MSW Careers', const Color(0xFFFF7A59)),
  EventItem('Delhi Builders Meetup', 'Meetup', 'Dec 20 · 4 PM', 'Hauz Khas, Delhi', 'Aanya S. (student)', const Color(0xFF6C5CE7)),
];

final contributions = [('🎬', 'Script a reel for MSW Labs', 300), ('🧩', 'Write 10 quiz questions', 150), ('🤝', 'Mentor a junior for a week', 400), ('🌐', 'Translate a lesson to Hindi', 250)];

final mswLabsUrl = 'https://intern.mystartupwave.com/';
