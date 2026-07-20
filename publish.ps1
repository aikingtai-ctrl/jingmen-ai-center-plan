# 京门大厦方案页 —— 一键发布到 GitHub Pages
# 用法：在本目录打开 PowerShell，执行  .\publish.ps1

$ErrorActionPreference = "Stop"
$repo = "jingmen-ai-center-plan"
$owner = "aikingtai-ctrl"
$url = "https://$owner.github.io/$repo/"

Set-Location $PSScriptRoot

Write-Host "[1/4] 创建公开仓库并推送..." -ForegroundColor Cyan
gh repo create $repo --public --source=. --push --description "京门大厦一至四层 2.4 万平方米商场改造为行业+AI落地中心的整体规划方案"
if (-not $?) { Write-Host "仓库创建失败，请检查 gh auth status" -ForegroundColor Red; exit 1 }

Write-Host "[2/4] 开启 GitHub Pages（main 分支根目录）..." -ForegroundColor Cyan
try {
  gh api -X POST "repos/$owner/$repo/pages" -f "source[branch]=main" -f "source[path]=/" | Out-Null
} catch {
  Write-Host "  Pages 可能已开启，继续。" -ForegroundColor Yellow
}

Write-Host "[3/4] 等待站点构建（最多 5 分钟）..." -ForegroundColor Cyan
$ok = $false
for ($i = 1; $i -le 30; $i++) {
  Start-Sleep -Seconds 10
  try {
    $r = Invoke-WebRequest -Uri $url -UseBasicParsing -TimeoutSec 15
    if ($r.StatusCode -eq 200) { $ok = $true; break }
  } catch { }
  Write-Host "  第 $i 次探测，尚未就绪..." -ForegroundColor DarkGray
}

Write-Host "[4/4] 结果" -ForegroundColor Cyan
if ($ok) {
  Write-Host "站点已上线：$url" -ForegroundColor Green
  Start-Process $url
} else {
  Write-Host "构建仍在进行。稍后手动访问：$url" -ForegroundColor Yellow
  Write-Host "查看构建状态： gh api repos/$owner/$repo/pages/builds/latest --jq '.status,.error.message'" -ForegroundColor DarkGray
}
