// Example TSX component for Velt
// This component can be used in .vdx files like: <HeroTsx title="Hello" />

interface HeroProps {
  title: string;
  subtitle?: string;
  btnText?: string;
  btnLink?: string;
}

export default function Hero({ title, subtitle, btnText, btnLink }: HeroProps) {
  return (
    <section className="hero">
      <h1 className="hero-title">{title}</h1>
      {subtitle && <p className="hero-subtitle">{subtitle}</p>}
      {btnText && btnLink && (
        <div className="hero-actions">
          <a href={btnLink} className="btn btn-primary">{btnText}</a>
        </div>
      )}
    </section>
  );
}
