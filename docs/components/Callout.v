module components

pub struct Callout {
pub:
    type_ string = 'info'
    content string
}

pub fn (c Callout) render() string {
    return '
    <div class="callout callout-${c.type_}">
        ${c.content}
    </div>
    '
}
