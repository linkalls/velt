module components

pub struct Hello {
pub:
    title string = 'Default Title'
}

pub fn (h Hello) render() string {
    return '
    <div class="hello-component">
        <h3>${h.title}</h3>
        <p>This is a V component rendered from .vdx!</p>
    </div>
    '
}
