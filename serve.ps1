$root = "C:\Users\ACER\ayvu-site"
$prefix = "http://localhost:8099/"
$listener = New-Object System.Net.HttpListener
$listener.Prefixes.Add($prefix)
$listener.Start()
Write-Host "Serving $root at $prefix"
$mimes = @{ ".html"="text/html"; ".css"="text/css"; ".js"="application/javascript"; ".png"="image/png"; ".jpg"="image/jpeg"; ".svg"="image/svg+xml" }
while ($listener.IsListening) {
  try {
    $ctx = $listener.GetContext()
    $path = $ctx.Request.Url.LocalPath.TrimStart('/')
    if ([string]::IsNullOrEmpty($path)) { $path = "index.html" }
    $file = Join-Path $root $path
    if (Test-Path $file -PathType Leaf) {
      $ext = [System.IO.Path]::GetExtension($file).ToLower()
      $ct = $mimes[$ext]; if (-not $ct) { $ct = "application/octet-stream" }
      $bytes = [System.IO.File]::ReadAllBytes($file)
      $ctx.Response.ContentType = $ct
      $ctx.Response.OutputStream.Write($bytes, 0, $bytes.Length)
    } else {
      $ctx.Response.StatusCode = 404
    }
    $ctx.Response.Close()
  } catch { }
}
