@echo off
echo ====================================
echo       AUTO SYNC TO GITHUB
echo ====================================
echo.

:sync_loop
echo [%date% %time%] Checking for changes...

:: Check if there are any changes
git status --porcelain > temp_status.txt
set /p changes=<temp_status.txt
del temp_status.txt

if not "%changes%"=="" (
    echo [%date% %time%] Changes detected! Syncing to GitHub...
    echo.
    
    :: Show what changed
    git status --short
    echo.
    
    :: Add all changes
    git add .
    
    :: Commit with timestamp
    git commit -m "Auto-sync: %date% %time%"
    
    :: Push to GitHub
    git push
    
    echo [%date% %time%] ✅ Successfully synced to GitHub!
    echo.
) else (
    echo [%date% %time%] No changes detected.
)

:: Wait 10 seconds before checking again
timeout /t 10 /nobreak >nul
goto sync_loop