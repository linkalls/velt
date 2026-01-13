module components

pub struct FeaturesSection {
}

pub fn (f FeaturesSection) render() string {
    return '
    <section class="features-section" id="features">
        <div class="features-grid">
            <div class="feature-card">
                <div class="feature-icon">⚡</div>
                <h3 class="feature-title">Blazingly Fast</h3>
                <p class="feature-details">Powered by the V compiler. Millisecond builds.</p>
            </div>
            <div class="feature-card">
                <div class="feature-icon">🛡️</div>
                <h3 class="feature-title">Type Safe</h3>
                <p class="feature-details">Components are V structs. Props are checked at compile time.</p>
            </div>
            <div class="feature-card">
                <div class="feature-icon">🚫</div>
                <h3 class="feature-title">Zero Runtime JS</h3>
                <p class="feature-details">Generates pure HTML/CSS. No client-side hydration.</p>
            </div>
        </div>
    </section>
    '
}
