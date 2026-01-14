module components

pub struct PostCard {
pub:
    title    string
    excerpt  string
    date     string
    url      string
}

pub fn (p PostCard) render() string {
    return '
<article class="post-card">
    <a href="${p.url}" class="post-card-link">
        <h2 class="post-card-title">${p.title}</h2>
        <p class="post-card-excerpt">${p.excerpt}</p>
        <time class="post-card-date">${p.date}</time>
    </a>
</article>
    '
}
