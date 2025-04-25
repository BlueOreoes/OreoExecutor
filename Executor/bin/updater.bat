@echo off
echo Current directory: %cd%

:: Close any oreo.exe processes
taskkill /f /im oreo.exe
echo oreo.exe has been closed if it was running.

:: Check if curl is available
where curl >nul 2>nul
if errorlevel 1 (
    echo Curl is not installed. Please install Curl to proceed.
    pause
    exit /b
)

:: Check if PowerShell is available (for extracting ZIP)
where powershell >nul 2>nul
if errorlevel 1 (
    echo PowerShell is not available. Please ensure PowerShell is installed.
    pause
    exit /b
)

:: Download the entire repository as a ZIP from GitHub
echo Downloading repository contents...
curl -L -o OreoExecutor.zip https://github.com/BlueOreoes/OreoExecutor/archive/refs/heads/main.zip

:: Extract the ZIP file
echo Extracting contents...
powershell -Command "Expand-Archive -Force 'OreoExecutor.zip' -DestinationPath '%cd%'"

:: Copy the contents of the Executor directory into the current directory
echo Copying Executor folder contents into the current directory...
xcopy /s /e /y "%cd%\OreoExecutor-main\Executor\*" "%cd%\"

:: Clean up the downloaded ZIP file and temporary folder
echo Cleaning up...
del /f /q OreoExecutor.zip
rmdir /s /q "%cd%\OreoExecutor-main"

echo Download complete and files have been copied. Cleanup complete.
