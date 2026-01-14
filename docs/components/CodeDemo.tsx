// components/CodeDemo.tsx
// TSX component for interactive code demos

interface CodeDemoProps {
  title: string;
  description?: string;
  code: string;
  language?: string;
  output?: string;
}

export default function CodeDemo({ 
  title, 
  description, 
  code, 
  language = "typescript",
  output 
}: CodeDemoProps) {
  return (
    <div className="code-demo">
      <div className="code-demo-header">
        <h3 className="code-demo-title">{title}</h3>
        {description && <p className="code-demo-desc">{description}</p>}
      </div>
      <div className="code-demo-content">
        <pre className="code-demo-code">
          <code className={`language-${language}`}>{code}</code>
        </pre>
        {output && (
          <div className="code-demo-output">
            <span className="output-label">Output:</span>
            <div className="output-content" dangerouslySetInnerHTML={{ __html: output }} />
          </div>
        )}
      </div>
    </div>
  );
}
