param(
  [Parameter(Mandatory = $true)]
  [string]$Message
)

$repoRoot = Resolve-Path (Join-Path $PSScriptRoot '..')
Set-Location $repoRoot

git add server

$stagedServerChanges = git diff --cached --name-only -- server
if (-not $stagedServerChanges) {
  Write-Host 'No server changes are staged.'
  exit 0
}

git commit -m $Message -- server

$branch = git branch --show-current
if (-not $branch) {
  Write-Error 'Unable to detect current git branch.'
  exit 1
}

git push origin $branch
