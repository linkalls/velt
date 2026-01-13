module layouts

pub fn default(content string) string {
    return '
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Velt Demo</title>
</head>
<body>
    <header>
        <h1>Velt Demo Site</h1>
    </header>
    <main>
        ${content}
    </main>
    <footer>
        <p>Powered by Velt</p>
    </footer>
</body>
</html>
    '
}
