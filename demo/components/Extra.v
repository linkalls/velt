// demo/components/Counter.v
module components

pub struct Counter {
pub:
    start int
    max int
}

pub fn (c Counter) render() string {
    return '
    <div class="counter">
        <p>Start: ${c.start}</p>
        <p>Max: ${c.max}</p>
    </div>
    '
}

// demo/components/Alert.v
pub struct Alert {
pub:
    type_ string // 'type' is a keyword? 'type' is keyword in V.
    content string
}

pub fn (a Alert) render() string {
    color := if a.type_ == 'warning' { 'yellow' } else { 'blue' }
    return '
    <div class="alert" style="background-color: ${color};">
        ${a.content}
    </div>
    '
}
