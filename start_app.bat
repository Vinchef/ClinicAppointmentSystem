@echo off
echo ================================================
echo   Horizon Clinic Appointment System
echo   ALWAYS RUN THIS FILE TO KEEP YOUR DATA!
echo ================================================
echo.
echo Starting on port 8080 (data persists on this port)...
echo.
cd /d "%~dp0"
flutter run -d chrome --web-port=8080
pause
