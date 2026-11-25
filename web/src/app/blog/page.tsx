import BlogList from '@/components/BlogList';
import PageTop from '@/components/PageTop';

export const metadata = { title: 'Blog — MSW Community' };

export default function Blog() {
  return (
    <div className="page">
      <PageTop />
      <section className="blog-wrap">
        <p className="mono label">( Journal )</p>
        <h1>
          Stories, guides <em>& wins.</em>
        </h1>
        <BlogList />
      </section>
    </div>
  );
}
