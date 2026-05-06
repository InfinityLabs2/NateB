$port = 5500
$root = "C:\Users\USER\Desktop\NateBarrber"

$mimeTypes = @{
    '.html' = 'text/html; charset=utf-8'
    '.css'  = 'text/css'
    '.js'   = 'application/javascript'
    '.png'  = 'image/png'
    '.jpg'  = 'image/jpeg'
    '.jpeg' = 'image/jpeg'
    '.mp4'  = 'video/mp4'
    '.webp' = 'image/webp'
    '.ico'  = 'image/x-icon'
}

$listener = New-Object System.Net.HttpListener
$listener.Prefixes.Add("http://localhost:$port/")
$listener.Start()
Write-Host "Server running at http://localhost:$port" -ForegroundColor Green
Write-Host "Press Ctrl+C to stop." -ForegroundColor Yellow

try {
    while ($listener.IsListening) {
        $ctx   = $listener.GetContext()
        $req   = $ctx.Request
        $res   = $ctx.Response
        $upath = $req.Url.LocalPath
        if ($upath -eq '/') { $upath = '/index.html' }
        $filePath = Join-Path $root $upath.TrimStart('/')

        if (Test-Path $filePath -PathType Leaf) {
            $ext     = [System.IO.Path]::GetExtension($filePath).ToLower()
            $mime    = if ($mimeTypes[$ext]) { $mimeTypes[$ext] } else { 'application/octet-stream' }
            $bytes   = [System.IO.File]::ReadAllBytes($filePath)
            $res.ContentType   = $mime
            $res.ContentLength64 = $bytes.Length
            $res.OutputStream.Write($bytes, 0, $bytes.Length)
        } else {
            $res.StatusCode = 404
            $body = [System.Text.Encoding]::UTF8.GetBytes('Not found')
            $res.OutputStream.Write($body, 0, $body.Length)
        }
        $res.OutputStream.Close()
    }
} finally {
    $listener.Stop()
}
