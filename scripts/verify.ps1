<#
.SYNOPSIS
    Deterministic Verification Gate (verify.ps1)
    Detects repository type and runs zero-cost static analysis and test suites.
.DESCRIPTION
    Runs:
      1. Static Analysis / Typecheck (mypy, tsc, eslint, node syntax check)
      2. Unit and Integration Tests (pytest, vitest, npm test)
    Returns exit code 0 if all gates pass, 1 otherwise.
#>

param(
    [switch]$Quick,
    [string]$TargetTest,
    [switch]$Alarm,
    [switch]$Voice
)

$ErrorActionPreference = "Continue"
$failed = $false

Write-Host ""
Write-Host "🔍 [FLEET LOOP] Running Deterministic Verification..." -ForegroundColor Cyan

# 1. Detect Python Project
$isPython = (Test-Path "pyproject.toml") -or (Test-Path "requirements.txt") -or (Test-Path "setup.py")
if ($isPython) {
    Write-Host ""
    Write-Host "--- [Python Gate] ---" -ForegroundColor Yellow

    $hasMypy = Get-Command mypy -ErrorAction SilentlyContinue
    if ($hasMypy) {
        Write-Host "Running mypy static analysis..." -ForegroundColor Gray
        mypy .
        if ($LASTEXITCODE -ne 0) {
            Write-Host "❌ mypy typecheck failed!" -ForegroundColor Red
            $failed = $true
        } else {
            Write-Host "✅ mypy typecheck passed." -ForegroundColor Green
        }
    }

    if (-not $failed) {
        $hasPytest = Get-Command pytest -ErrorAction SilentlyContinue
        if ($hasPytest) {
            Write-Host "Running pytest..." -ForegroundColor Gray
            if ($TargetTest) {
                pytest -k $TargetTest -v
            } else {
                pytest -q
            }
            if ($LASTEXITCODE -ne 0) {
                Write-Host "❌ pytest tests failed!" -ForegroundColor Red
                $failed = $true
            } else {
                Write-Host "✅ pytest tests passed." -ForegroundColor Green
            }
        }
    }
}

# 2. Detect Node / Astro / TypeScript Project
$isNode = Test-Path "package.json"
if ($isNode) {
    Write-Host ""
    Write-Host "--- [Astro / Node Static Verification Gate] ---" -ForegroundColor Yellow

    Write-Host "Running Astro Type Check (npx astro check)..." -ForegroundColor Gray
    npx astro check
    if ($LASTEXITCODE -ne 0) {
        Write-Host "❌ astro check failed!" -ForegroundColor Red
        $failed = $true
    } else {
        Write-Host "✅ astro check passed." -ForegroundColor Green
    }

    if (-not $failed) {
        Write-Host "Running Astro Production Build (npm run build)..." -ForegroundColor Gray
        npm run build
        if ($LASTEXITCODE -ne 0) {
            Write-Host "❌ npm run build failed!" -ForegroundColor Red
            $failed = $true
        } else {
            Write-Host "✅ npm run build succeeded! Static artifacts generated in dist/." -ForegroundColor Green
        }
    }
}

# 3. Detect JavaScript / Web Project (e.g. docs/app.js syntax check)
if (Test-Path "docs/app.js") {
    Write-Host ""
    Write-Host "--- [Web and JavaScript Gate] ---" -ForegroundColor Yellow
    $hasNode = Get-Command node -ErrorAction SilentlyContinue
    if ($hasNode) {
        Write-Host "Checking docs/app.js syntax..." -ForegroundColor Gray
        node --check docs/app.js
        if ($LASTEXITCODE -ne 0) {
            Write-Host "❌ docs/app.js syntax check failed!" -ForegroundColor Red
            $failed = $true
        } else {
            Write-Host "✅ docs/app.js syntax check passed." -ForegroundColor Green
        }
    }
}

# 4. Agent Alarm Resolver
$alarmScript = Join-Path $PSScriptRoot "agent-alarm.ps1"
if (-not (Test-Path $alarmScript)) {
    $alarmScript = Join-Path $env:USERPROFILE ".gemini\config\skills\agent-alarm\scripts\agent-alarm.ps1"
}

# 5. Overall Verification Result
if ($failed) {
    Write-Host ""
    Write-Host "⛔ [VERIFICATION FAILED] Please fix errors before proceeding." -ForegroundColor Red
    if ($Alarm -or $Voice) {
        if (Test-Path $alarmScript) {
            $alarmArgs = @("-Type", "Failure", "-Message", "Verification failed. Attention required.")
            pwsh -File $alarmScript @alarmArgs
        } else {
            try { [System.Media.SystemSounds]::Hand.Play() } catch {}
        }
    }
    exit 1
}

Write-Host ""
Write-Host "🎉 [VERIFICATION PASSED] All deterministic gates green." -ForegroundColor Green
if ($Alarm -or $Voice) {
    if (Test-Path $alarmScript) {
        $alarmArgs = @("-Type", "Success", "-Message", "All verification gates are green.")
        pwsh -File $alarmScript @alarmArgs
    } else {
        try { [System.Media.SystemSounds]::Asterisk.Play() } catch {}
    }
}
exit 0
