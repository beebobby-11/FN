# ==================================================================
# Auto-Install HeikinAshiStrategyEA to MetaTrader 5
# ==================================================================
# Description: Automatically install EA files to MT5 Data Folder
# Repository: https://github.com/beebobby-11/FN
# ==================================================================

param(
    [string]$MT5DataFolder = "",
    [switch]$Help
)

# Show help
if ($Help) {
    Write-Host @"
╔════════════════════════════════════════════════════════════════╗
║         HeikinAshiStrategyEA Auto-Installer for MT5           ║
╚════════════════════════════════════════════════════════════════╝

USAGE:
    .\Install-MT5-EA-Auto.ps1
    .\Install-MT5-EA-Auto.ps1 -MT5DataFolder "C:\Path\To\MT5\MQL5"

OPTIONS:
    -MT5DataFolder    Specify MT5 data folder path (optional)
    -Help             Show this help message

EXAMPLES:
    # Auto-detect MT5 folder
    .\Install-MT5-EA-Auto.ps1

    # Specify custom path
    .\Install-MT5-EA-Auto.ps1 -MT5DataFolder "C:\MT5\MQL5"

WHAT THIS SCRIPT DOES:
    1. Find MT5 Data Folder (auto-detect or manual)
    2. Copy EA files to Experts\
    3. Copy helper classes to Include\
    4. Copy indicator to Indicators\
    5. Copy documentation
    6. Show success message with next steps

REQUIREMENTS:
    - Windows PowerShell 5.0+
    - MetaTrader 5 installed
    - Downloaded/cloned repo: https://github.com/beebobby-11/FN

"@
    exit 0
}

# ==================================================================
# Color Functions
# ==================================================================
function Write-Success { param($msg) Write-Host "✓ $msg" -ForegroundColor Green }
function Write-Error { param($msg) Write-Host "✗ $msg" -ForegroundColor Red }
function Write-Warning { param($msg) Write-Host "⚠ $msg" -ForegroundColor Yellow }
function Write-Info { param($msg) Write-Host "ℹ $msg" -ForegroundColor Cyan }
function Write-Step { param($msg) Write-Host "`n▶ $msg" -ForegroundColor Magenta }

# ==================================================================
# Banner
# ==================================================================
Clear-Host
Write-Host @"
╔════════════════════════════════════════════════════════════════╗
║         HeikinAshiStrategyEA Auto-Installer v1.0              ║
║         Repository: github.com/beebobby-11/FN                 ║
╚════════════════════════════════════════════════════════════════╝

"@ -ForegroundColor Cyan

# ==================================================================
# Step 1: Find Current Script Location
# ==================================================================
Write-Step "Step 1: Locating source files..."

$ScriptPath = Split-Path -Parent $MyInvocation.MyCommand.Path
Write-Info "Script location: $ScriptPath"

# Check if we're in the right directory
if (-not (Test-Path "$ScriptPath\HeikinAshiStrategyEA.mq5")) {
    Write-Error "HeikinAshiStrategyEA.mq5 not found!"
    Write-Warning "Please run this script from the repository root folder."
    Write-Info "Expected structure:"
    Write-Host "  📁 Repository/"
    Write-Host "  ├── HeikinAshiStrategyEA.mq5"
    Write-Host "  ├── Include/*.mqh"
    Write-Host "  └── Indicators/*.mq5"
    exit 1
}

Write-Success "Source files found"

# ==================================================================
# Step 2: Find MT5 Data Folder
# ==================================================================
Write-Step "Step 2: Finding MetaTrader 5 Data Folder..."

if ($MT5DataFolder -eq "") {
    # Auto-detect MT5 folder
    $PossiblePaths = @(
        "$env:APPDATA\MetaQuotes\Terminal\*\MQL5",
        "$env:USERPROFILE\AppData\Roaming\MetaQuotes\Terminal\*\MQL5"
    )
    
    $FoundPaths = @()
    foreach ($pattern in $PossiblePaths) {
        $found = Get-ChildItem -Path $pattern -Directory -ErrorAction SilentlyContinue
        if ($found) {
            $FoundPaths += $found
        }
    }
    
    if ($FoundPaths.Count -eq 0) {
        Write-Error "MT5 Data Folder not found!"
        Write-Warning "Please specify manually using -MT5DataFolder parameter"
        Write-Info "Example: .\Install-MT5-EA-Auto.ps1 -MT5DataFolder 'C:\MT5\MQL5'"
        Write-Info ""
        Write-Info "To find your MT5 folder:"
        Write-Info "  1. Open MetaTrader 5"
        Write-Info "  2. File → Open Data Folder"
        Write-Info "  3. Navigate to MQL5\ folder"
        exit 1
    }
    
    if ($FoundPaths.Count -eq 1) {
        $MT5DataFolder = $FoundPaths[0].FullName
        Write-Success "Auto-detected: $MT5DataFolder"
    } else {
        Write-Warning "Multiple MT5 installations found:"
        for ($i = 0; $i -lt $FoundPaths.Count; $i++) {
            Write-Host "  [$i] $($FoundPaths[$i].FullName)"
        }
        
        $choice = Read-Host "`nSelect MT5 folder (0-$($FoundPaths.Count - 1))"
        if ($choice -match '^\d+$' -and [int]$choice -lt $FoundPaths.Count) {
            $MT5DataFolder = $FoundPaths[[int]$choice].FullName
            Write-Success "Selected: $MT5DataFolder"
        } else {
            Write-Error "Invalid selection"
            exit 1
        }
    }
} else {
    # User specified path
    if (-not (Test-Path $MT5DataFolder)) {
        Write-Error "Specified folder not found: $MT5DataFolder"
        exit 1
    }
    Write-Success "Using specified folder: $MT5DataFolder"
}

# Verify it's a valid MQL5 folder
if (-not (Test-Path "$MT5DataFolder\Experts")) {
    Write-Error "Invalid MQL5 folder (Experts\ not found)"
    Write-Info "Make sure you're pointing to the MQL5\ folder, not MT5 root"
    exit 1
}

# ==================================================================
# Step 3: Prepare Folders
# ==================================================================
Write-Step "Step 3: Preparing destination folders..."

$Folders = @(
    "$MT5DataFolder\Experts",
    "$MT5DataFolder\Include",
    "$MT5DataFolder\Indicators"
)

foreach ($folder in $Folders) {
    if (-not (Test-Path $folder)) {
        New-Item -Path $folder -ItemType Directory -Force | Out-Null
        Write-Success "Created: $folder"
    }
}

Write-Success "Folders ready"

# ==================================================================
# Step 4: Copy Files
# ==================================================================
Write-Step "Step 4: Copying files..."

# Define file mappings
$FileMappings = @(
    @{
        Source = "$ScriptPath\HeikinAshiStrategyEA.mq5"
        Dest = "$MT5DataFolder\Experts\HeikinAshiStrategyEA.mq5"
        Name = "EA (Main)"
    },
    @{
        Source = "$ScriptPath\Include\StateManager.mqh"
        Dest = "$MT5DataFolder\Include\StateManager.mqh"
        Name = "StateManager"
    },
    @{
        Source = "$ScriptPath\Include\HeikinAshiHTF.mqh"
        Dest = "$MT5DataFolder\Include\HeikinAshiHTF.mqh"
        Name = "HeikinAshiHTF"
    },
    @{
        Source = "$ScriptPath\Include\FilterManager.mqh"
        Dest = "$MT5DataFolder\Include\FilterManager.mqh"
        Name = "FilterManager"
    },
    @{
        Source = "$ScriptPath\Include\OrderManager.mqh"
        Dest = "$MT5DataFolder\Include\OrderManager.mqh"
        Name = "OrderManager"
    },
    @{
        Source = "$ScriptPath\Indicators\HeikinAshiM90.mq5"
        Dest = "$MT5DataFolder\Indicators\HeikinAshiM90.mq5"
        Name = "Indicator"
    }
)

$CopySuccess = 0
$CopyFailed = 0

foreach ($mapping in $FileMappings) {
    if (Test-Path $mapping.Source) {
        try {
            Copy-Item -Path $mapping.Source -Destination $mapping.Dest -Force
            Write-Success "Copied: $($mapping.Name)"
            $CopySuccess++
        } catch {
            Write-Error "Failed to copy: $($mapping.Name)"
            Write-Warning "  Error: $($_.Exception.Message)"
            $CopyFailed++
        }
    } else {
        Write-Warning "Source not found: $($mapping.Name)"
        Write-Info "  Expected: $($mapping.Source)"
        $CopyFailed++
    }
}

# ==================================================================
# Step 5: Copy Documentation (Optional)
# ==================================================================
Write-Step "Step 5: Copying documentation..."

$DocFiles = @(
    "README.md",
    "WINDOWS_QUICK_START.md",
    "PROJECT_RULES_AND_PROGRESS.md",
    "ttt.txt"
)

$DocsFolder = "$MT5DataFolder\..\..\EA_Documentation"
if (-not (Test-Path $DocsFolder)) {
    New-Item -Path $DocsFolder -ItemType Directory -Force | Out-Null
}

foreach ($doc in $DocFiles) {
    $sourcePath = "$ScriptPath\$doc"
    if (Test-Path $sourcePath) {
        Copy-Item -Path $sourcePath -Destination "$DocsFolder\$doc" -Force
        Write-Success "Copied: $doc"
    }
}

# ==================================================================
# Step 6: Summary
# ==================================================================
Write-Step "Installation Summary"

Write-Host ""
Write-Host "═══════════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host "  Files Copied: " -NoNewline
Write-Host "$CopySuccess" -ForegroundColor Green -NoNewline
Write-Host " succeeded, " -NoNewline
Write-Host "$CopyFailed" -ForegroundColor $(if ($CopyFailed -gt 0) { "Red" } else { "Green" }) -NoNewline
Write-Host " failed"
Write-Host "  Target: $MT5DataFolder"
Write-Host "═══════════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host ""

if ($CopyFailed -gt 0) {
    Write-Error "Installation completed with errors"
    Write-Warning "Please check the error messages above and copy files manually if needed"
    exit 1
}

# ==================================================================
# Step 7: Next Steps
# ==================================================================
Write-Step "Next Steps - IMPORTANT!"

Write-Host ""
Write-Host "📋 You MUST follow these steps:" -ForegroundColor Yellow
Write-Host ""
Write-Host "  1. Open MetaEditor (F4 in MT5)" -ForegroundColor White
Write-Host "     • Or: Tools → MetaQuotes Language Editor" -ForegroundColor Gray
Write-Host ""
Write-Host "  2. Compile INDICATOR first:" -ForegroundColor White
Write-Host "     • Navigate to: Indicators → HeikinAshiM90.mq5" -ForegroundColor Gray
Write-Host "     • Press F7 (Compile)" -ForegroundColor Gray
Write-Host "     • Must show: 0 errors, 0 warnings" -ForegroundColor Green
Write-Host ""
Write-Host "  3. Compile EA:" -ForegroundColor White
Write-Host "     • Navigate to: Experts → HeikinAshiStrategyEA.mq5" -ForegroundColor Gray
Write-Host "     • Press F7 (Compile)" -ForegroundColor Gray
Write-Host "     • Must show: 0 errors, 0 warnings" -ForegroundColor Green
Write-Host ""
Write-Host "  4. Strategy Tester:" -ForegroundColor White
Write-Host "     • Press Ctrl+R in MT5" -ForegroundColor Gray
Write-Host "     • Expert: HeikinAshiStrategyEA" -ForegroundColor Gray
Write-Host "     • Symbol: XAUUSD or XAUUSDm" -ForegroundColor Gray
Write-Host "     • Period: M5 (CRITICAL! Must be M5)" -ForegroundColor Red
Write-Host "     • Date: 2024.01.01 - 2024.06.10" -ForegroundColor Gray
Write-Host "     • Model: Every tick" -ForegroundColor Gray
Write-Host ""
Write-Host "  5. Check Journal Tab:" -ForegroundColor White
Write-Host "     • Should see: '✓ Using custom Heikin Ashi M90 indicator'" -ForegroundColor Green
Write-Host "     • Should see trades executing (not 0 trades!)" -ForegroundColor Green
Write-Host ""

Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
Write-Host ""
Write-Host "📚 Documentation:" -ForegroundColor Cyan
Write-Host "   • Quick Start: $DocsFolder\WINDOWS_QUICK_START.md"
Write-Host "   • Full Rules:  $DocsFolder\PROJECT_RULES_AND_PROGRESS.md"
Write-Host "   • Pine Source: $DocsFolder\ttt.txt"
Write-Host ""
Write-Host "🔗 Repository: https://github.com/beebobby-11/FN" -ForegroundColor Cyan
Write-Host ""
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
Write-Host ""

Write-Success "Installation completed successfully!"
Write-Info "Press any key to exit..."
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
