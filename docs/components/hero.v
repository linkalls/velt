module components

pub struct Hero {
pub:
    title string
    subtitle string
    btn_text string
    btn_link string
}

pub fn (h Hero) render() string {
    return '
    <header class="hero">
        <div class="hero-content">
            <h1 class="hero-title">${h.title}</h1>
            <p class="hero-subtitle">${h.subtitle}</p>
            <div class="hero-actions">
                <a href="${h.btn_link}" class="btn btn-primary">${h.btn_text}</a>
                <a href="https://github.com/vlang/velt" class="btn btn-secondary">View on GitHub</a>
            </div>
        </div>
    </header>
    '
}
