@echo off
set "ffmpeg_path=C:\Tools\bin\ffmpeg.exe"
set "scxvid_path=C:\Tools\bin\SCXvid.exe"

REM Press Win+R, type "shell:sendto" and put this batch script there. Now you can just right-click, go to "Send to" and select "Create Pass File"
REM Requirements
REM * SCXvid-standalone: https://github.com/soyokaze/SCXvid-standalone/releases
REM * FFmpeg: http://ffmpeg.zeranoe.com/builds/
REM if exist C:\Tools set PATH=%PATH%;C:\Tools

:: Check ffmpeg folder
if not exist "%ffmpeg_path%" (
    echo There is no ffmpeg, please install or update it!
    pause
    exit /b
)

:: Check SCXvid folder
if not exist "%scxvid_path%" (
    echo There is no SCXvid, please install or update it!
    pause
    exit /b
)

:: Check if no file was selected
if "%~1"=="" (
    echo Please select a video file for keyframes.
    pause
    exit /b
)

echo.
echo. 
echo #################################################
REM echo #						#
echo #						#
echo # 	Keyframe Generator by Shinrin		#
REM echo #						#
echo #						#
echo #################################################
echo.
echo Creating Keyframes, please wait...
set "video=%~1"
set "video2=%~n1"
"%ffmpeg_path%" -i "%video%" -f yuv4mpegpipe -vf scale=640:360 -pix_fmt yuv420p -vsync drop -loglevel quiet - | "%scxvid_path%" "%video2%_keyframes.txt"

CLS
echo.
echo. 
echo #################################################
REM echo #						#
echo #						#
echo # 	Keyframes Generator by Shinrin		#
REM echo #						#
echo #						#
echo #################################################
echo.
echo The keyframes file has been created successfully. You may now close this command line interface.
timeout /t 10 >nul
exit /b