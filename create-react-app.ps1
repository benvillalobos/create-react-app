param(
    [string]$folderPath = "",
    [string]$name = ""
)

if ([string]::IsNullOrWhiteSpace($folderPath)) {
    Write-Host "Where would you like to generate this project?" -ForegroundColor Cyan
    Write-Host "1) playground (c:/src/playgrounds/)"
    Write-Host "2) Current directory"
    Write-Host "3) Custom path"
    $choice = Read-Host "Enter your choice (1-3)"

    switch ($choice) {
        "1" { $folderPath = "c:/src/playgrounds/" }
        "2" { $folderPath = (Get-Location).Path }
        "3" { $folderPath = Read-Host "Enter custom path" }
        default {
            Write-Host "Invalid choice. Exiting." -ForegroundColor Red
            exit
        }
    }
}

Write-Host "Changing directory to: $folderPath" -ForegroundColor Green
Set-Location $folderPath

$name = $name.Trim()
if (-not $name) {
    $name = Read-Host "What would you like to name this project?"
    $name = $name.Trim()
}

if (-not $name) {
    Write-Host "Error: Project name cannot be empty." -ForegroundColor Red
    exit
}

if ($name -match '[<>:"/\\|?*]') {
    Write-Host "Error: Project name contains invalid characters." -ForegroundColor Red
    exit
}

Write-Host "Creating and changing directory to: $name" -ForegroundColor Green
New-Item -ItemType Directory -Path $name -Force | Out-Null
Set-Location $name

Write-Host "Running: npm create vite@latest . --template react-ts" -ForegroundColor Green
npm create vite@latest . --template react-ts --force

Write-Host "Running: git init" -ForegroundColor Green
git init -b main

Write-Host "Running: git add ." -ForegroundColor Green
git add .

Write-Host "Running: git commit -m 'initial commit'" -ForegroundColor Green
git commit -m "initial commit"

Write-Host "Running: npm install" -ForegroundColor Green
npm i

Write-Host "Running: npm i --save-dev --save-exact prettier" -ForegroundColor Green
npm i --save-dev --save-exact prettier

Write-Host "Creating .vscode/settings.json with Prettier configuration..." -ForegroundColor Green
New-Item -ItemType Directory -Path ".vscode" -Force | Out-Null
@"
{
  "editor.defaultFormatter": "esbenp.prettier-vscode",
  "editor.formatOnSave": true
}
"@ | Set-Content -Path ".vscode/settings.json" -Force

Write-Host "Creating .vscode/launch.json for debugging configuration..." -ForegroundColor Green
@"
{
  "version": "0.2.0",
  "configurations": [
    {
      "type": "node",
      "request": "launch",
      "name": "Web App",
      "runtimeExecutable": "npm",
      "runtimeArgs": ["run", "dev"],
      "cwd": "\${workspaceFolder}"
    },
    {
      "type": "msedge",
      "request": "launch",
      "name": "Launch Edge against localhost",
      "port": 5173,
      "webRoot": "\${workspaceFolder}",
      "url": "http://localhost:5173"
    }
  ]
}
"@ | Set-Content -Path ".vscode/launch.json" -Force

Write-Host "Opening project in VS Code Insiders..." -ForegroundColor Green
code-insiders .
