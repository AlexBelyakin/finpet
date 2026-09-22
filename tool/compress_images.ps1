Add-Type -AssemblyName System.Drawing

function Save-FastJpeg {
  param(
    [string]$Src,
    [string]$Dest,
    [int]$MaxLong = 1920,
    [long]$Quality = 84
  )
  $fs = [System.IO.File]::OpenRead((Resolve-Path $Src))
  $img = [System.Drawing.Image]::FromStream($fs)
  try {
    $w = $img.Width
    $h = $img.Height
    $long = [Math]::Max($w, $h)
    $scale = if ($long -gt $MaxLong) { $MaxLong / $long } else { 1.0 }
    $nw = [int][Math]::Max(1, [Math]::Round($w * $scale))
    $nh = [int][Math]::Max(1, [Math]::Round($h * $scale))
    $bmp = New-Object System.Drawing.Bitmap $nw, $nh
    $g = [System.Drawing.Graphics]::FromImage($bmp)
    try {
      $g.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
      $g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::HighQuality
      $g.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::HighQuality
      $g.CompositingQuality = [System.Drawing.Drawing2D.CompositingQuality]::HighQuality
      $g.Clear([System.Drawing.Color]::White)
      $g.DrawImage($img, 0, 0, $nw, $nh)
      $codec = [System.Drawing.Imaging.ImageCodecInfo]::GetImageEncoders() |
        Where-Object { $_.MimeType -eq 'image/jpeg' }
      $ep = New-Object System.Drawing.Imaging.EncoderParameters 1
      $ep.Param[0] = New-Object System.Drawing.Imaging.EncoderParameter (
        [System.Drawing.Imaging.Encoder]::Quality,
        $Quality
      )
      $dir = Split-Path $Dest -Parent
      if (-not (Test-Path $dir)) { New-Item -ItemType Directory -Path $dir | Out-Null }
      if (Test-Path $Dest) { Remove-Item $Dest -Force }
      $bmp.Save($Dest, $codec, $ep)
    } finally {
      $g.Dispose()
      $bmp.Dispose()
    }
  } finally {
    $img.Dispose()
    $fs.Dispose()
  }
}

$root = Split-Path $PSScriptRoot -Parent
$img = Join-Path $root 'assets\images'

$jobs = @(
  @{ Src = 'bg_room_morning.png'; Dest = 'bg_room_morning.jpg'; Max = 1920 }
  @{ Src = 'bg_room_evening.png'; Dest = 'bg_room_evening.jpg'; Max = 1920 }
  @{ Src = 'bg_room_night.png'; Dest = 'bg_room_night.jpg'; Max = 1920 }
  @{ Src = 'bg_room_morning_planshet.png'; Dest = 'bg_room_morning_planshet.jpg'; Max = 2048 }
  @{ Src = 'bg_room_evening_planshet.png'; Dest = 'bg_room_evening_planshet.jpg'; Max = 2048 }
  @{ Src = 'bg_room_night_planshet.jpg'; Dest = 'bg_room_night_planshet.jpg'; Max = 2048 }
  @{ Src = 'room2_morning.png'; Dest = 'room2_morning.jpg'; Max = 1920 }
  @{ Src = 'room2_evening.png'; Dest = 'room2_evening.jpg'; Max = 1920 }
  @{ Src = 'room2_night.png'; Dest = 'room2_night.jpg'; Max = 1920 }
  @{ Src = 'room2_morning_planshet.png'; Dest = 'room2_morning_planshet.jpg'; Max = 2048 }
  @{ Src = 'room2_evening_planshet.png'; Dest = 'room2_evening_planshet.jpg'; Max = 2048 }
  @{ Src = 'room2_night_planshet.png'; Dest = 'room2_night_planshet.jpg'; Max = 2048 }
  @{ Src = 'bg_splash.png'; Dest = 'bg_splash.jpg'; Max = 1920 }
  @{ Src = 'logo_finni.png'; Dest = 'logo_finni.jpg'; Max = 640; Quality = 88 }
)

# Night tablet is already jpg and is also Dest — write to temp first.
$tmpNight = Join-Path $env:TEMP 'finpet_night_planshet.jpg'
foreach ($job in $jobs) {
  $src = Join-Path $img $job.Src
  $dest = Join-Path $img $job.Dest
  $quality = if ($job.ContainsKey('Quality')) { $job.Quality } else { 84 }
  $out = $dest
  if ($src -eq $dest) { $out = $tmpNight }
  Write-Host "compress $($job.Src) -> $($job.Dest) max=$($job.Max)"
  Save-FastJpeg -Src $src -Dest $out -MaxLong $job.Max -Quality $quality
  if ($out -eq $tmpNight) {
    Copy-Item $tmpNight $dest -Force
    Remove-Item $tmpNight -Force
  }
  $before = [math]::Round((Get-Item $src).Length / 1KB, 1)
  $after = [math]::Round((Get-Item $dest).Length / 1KB, 1)
  Write-Host ("  {0} KB -> {1} KB" -f $before, $after)
}
