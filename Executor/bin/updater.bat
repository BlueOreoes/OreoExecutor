@echo off
echo Current directory: %cd%
taskkill /f /im oreo.exe
echo oreo.exe has been closed if it was running.
pause
