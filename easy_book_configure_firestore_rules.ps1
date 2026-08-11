$ErrorActionPreference = "Stop"

$projectId = "easy-book-zaki"
$projectRoot = (Get-Location).Path
$rulesSource = (Resolve-Path (Join-Path $PSScriptRoot "firestore.rules")).Path
$rulesTarget = Join-Path $projectRoot "firestore.rules"

if (-not (Test-Path ".\firebase.json")) {
    throw "firebase.json was not found. Run this script from the Easy Book project root."
}

if (-not (Test-Path $rulesSource)) {
    throw "firestore.rules was not found next to this script."
}

Copy-Item ".\firebase.json" ".\firebase.json.before-firestore-rules.bak" -Force

if ($rulesSource -ne $rulesTarget) {
    Copy-Item $rulesSource $rulesTarget -Force
}

$config = Get-Content ".\firebase.json" -Raw | ConvertFrom-Json

$firestoreConfig = [pscustomobject]@{
    rules = "firestore.rules"
}

if ($null -eq $config.firestore) {
    $config | Add-Member -NotePropertyName "firestore" -NotePropertyValue $firestoreConfig
} else {
    $config.firestore = $firestoreConfig
}

$config | ConvertTo-Json -Depth 30 | Set-Content ".\firebase.json" -Encoding UTF8

Write-Host ""
Write-Host "Easy Book Firestore rules configured successfully." -ForegroundColor Green
Write-Host "Backup: firebase.json.before-firestore-rules.bak"
Write-Host ""
Write-Host "Review changes:" -ForegroundColor Cyan
Write-Host "  git diff -- firebase.json firestore.rules"
Write-Host ""
Write-Host "Then deploy:" -ForegroundColor Cyan
Write-Host "  firebase deploy --only firestore:rules --project easy-book-zaki"
