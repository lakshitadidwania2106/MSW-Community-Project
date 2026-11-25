import { PHOTOS } from './photos';

export type Article = { slug: string; cat: string; mins: number; title: string; dek: string; img: string; body: string[] };

export const ARTICLES: Article[] = [
  { slug: 'three-hackathons', cat: 'Hackathons', mins: 7, title: 'How I won 3 hackathons in my 2nd year', dek: 'Pick a narrow problem, demo early, and sleep. A finalist breaks down the playbook.', img: PHOTOS[0],
    body: ['The first hackathon I entered, our team built six features and demoed none of them. The second time we built one feature and demoed it four times to anyone who would watch.', 'Judges have twelve minutes per team. They remember a working demo and a clear sentence about who it is for. Everything else is noise.', 'Pick a problem you can explain to your grandmother. Build the smallest thing that proves it works. Then rehearse the demo until it is boring.'] },
  { slug: 'cold-email', cat: 'Careers', mins: 6, title: 'The internship cold email that got 9 replies', dek: 'Five sentences, one link, zero attachments. Here is the exact template.', img: PHOTOS[3],
    body: ['Recruiters read emails on their phone between meetings. If your email needs scrolling, it is already too long.', 'Line one says who you are. Line two says what you built. Line three links to it. Line four asks for fifteen minutes. Line five thanks them.', 'Your MSW digital ID does the rest: verified badges, hackathons and merged pull requests in one link.'] },
  { slug: 'what-judges-want', cat: 'Hackathons', mins: 8, title: 'What judges actually look for in 48 hours', dek: 'We asked 20 judges from MSW-powered hackathons what made them score a team highly.', img: PHOTOS[6],
    body: ['Almost every judge said the same thing: a team that understood its user.', 'Technical depth matters, but only after the judge believes the problem is real. Start with a person, a pain and a number.', 'The best demos showed one flow end to end, on real data, with no slides in between.'] },
  { slug: 'dorm-to-preseed', cat: 'Founders', mins: 5, title: 'From dorm-room idea to ₹10L pre-seed', dek: 'How a student team used MSW to meet its first investor and close a round.', img: PHOTOS[9],
    body: ['Krishi started as a class project: a ₹200 soil sensor. Six months later it had 1,800 farmers and a pre-seed round.', 'The founders pitched on MSW, where investors could see their verified IDs, their build history and real traction in one place.', 'Their advice: post your progress every week. Investors notice consistency before they notice slides.'] },
  { slug: 'reels-vs-lectures', cat: 'Learning', mins: 4, title: 'Why 60-second reels beat 3-hour lectures', dek: 'The science behind MSW Labs’ 30-day full-stack challenge.', img: PHOTOS[12],
    body: ['Attention is a budget. Short lessons with a task at the end spend it well.', 'Every MSW Labs day is a reel, a challenge and a checkpoint. Thirty of them add up to a deployed full-stack project.', 'Students who finish get a certificate, a badge on their ID and a portfolio piece recruiters can click.'] },
  { slug: 'github-resume', cat: 'Careers', mins: 6, title: 'Your GitHub is your new résumé — here’s how to fix it', dek: 'Pinned repos, readable READMEs and one great project beat fifty forks.', img: PHOTOS[15],
    body: ['Recruiters open your GitHub for about thirty seconds. Make those seconds count.', 'Pin your three best repositories. Give each a README with a screenshot, a live link and one paragraph on what you learned.', 'The MSW GitHub analyser scores your profile and tells you exactly what to fix first.'] },
];
