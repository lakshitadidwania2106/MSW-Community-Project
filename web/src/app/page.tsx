import Effects from '@/components/Effects';
import SmoothScroll from '@/components/SmoothScroll';
import Features from '@/components/landing/Features';
import Hero, { Marquee } from '@/components/landing/Hero';
import Nav from '@/components/landing/Nav';
import Preloader from '@/components/landing/Preloader';
import { BlogTeaser, Cta, Ecosystem, Footer, Hackathons, IdShowcase, Investors, Portals, Pricing, Social } from '@/components/landing/Sections';
import Touch, { Manifesto } from '@/components/landing/Touch';

export default function Home() {
  return (
    <>
      <Preloader />
      <Nav />
      <main>
        <Hero />
        <Marquee />
        <Touch />
        <Manifesto />
        <Features />
        <Ecosystem />
        <Hackathons />
        <IdShowcase />
        <Portals />
        <Investors />
        <BlogTeaser />
        <Pricing />
        <Cta />
        <Social />
      </main>
      <Footer />
      <Effects />
      <SmoothScroll />
    </>
  );
}
