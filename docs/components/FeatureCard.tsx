// components/FeatureCard.tsx
// Feature showcase card with icon

interface FeatureCardProps {
  icon: string;
  title: string;
  description: string;
  link?: string;
}

export default function FeatureCard({ 
  icon, 
  title, 
  description, 
  link 
}: FeatureCardProps) {
  const content = (
    <div className="feature-card">
      <span className="feature-icon">{icon}</span>
      <h3 className="feature-title">{title}</h3>
      <p className="feature-desc">{description}</p>
    </div>
  );

  if (link) {
    return <a href={link} className="feature-card-link">{content}</a>;
  }
  return content;
}
