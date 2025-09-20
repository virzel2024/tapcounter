@echo off
echo ====================================
echo    SMART AUTO SYNC TO GITHUB
echo ====================================
echo.
echo Choose sync mode:
echo 1. Manual sync now
echo 2. Auto sync every 30 seconds
echo 3. Auto sync every 2 minutes
echo 4. Auto sync every 5 minutes
echo 5. Exit
echo.
set /p choice="Enter choice (1-5): "

if "%choice%"=="1" goto manual_sync
if "%choice%"=="2" set sync_interval=30 && goto auto_sync
if "%choice%"=="3" set sync_interval=120 && goto auto_sync
if "%choice%"=="4" set sync_interval=300 && goto auto_sync
if "%choice%"=="5" exit
goto start

:manual_sync
echo.
echo Checking for changes...
git status --porcelain > temp_status.txt
set /p changes=<temp_status.txt
del temp_status.txt

if not "%changes%"=="" (
    echo Changes detected:
    git status --short
    echo.
    set /p commit_msg="Enter commit message (or press Enter for auto message): "
    
    git add .
    
    if "%commit_msg%"=="" (
        git commit -m "Manual sync: %date% %time%"
    ) else (
        git commit -m "%commit_msg%"
    )
    
    git push
    echo ✅ Successfully synced to GitHub!
) else (
    echo No changes to sync.
)
echo.
pause
goto start

:auto_sync
echo.
echo 🚀 Auto-sync started! (Every %sync_interval% seconds)
echo Press Ctrl+C to stop
echo.

:sync_loop
echo [%time%] Checking for changes...

git status --porcelain > temp_status.txt
set /p changes=<temp_status.txt
del temp_status.txt

if not "%changes%"=="" (
    echo [%time%] 📝 Changes detected! Syncing...
    git status --short
    git add .
    git commit -m "Auto-sync: %date% %time%"
    git push
    echo [%time%] ✅ Synced to GitHub!
) else (
    echo [%time%] ✓ No changes
)

echo.
timeout /t %sync_interval% /nobreak >nul
goto sync_loop

:start