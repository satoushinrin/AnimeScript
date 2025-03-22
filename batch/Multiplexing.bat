@echo off
setlocal enabledelayedexpansion

:: Set mkvmerge path
set mkvmerge_path="C:\Tools\bin\mkvmerge.exe"

:: Check if mkvmerge exists
if not exist %mkvmerge_path% (
    echo mkvmerge not found! Please check the path.
    pause
    exit /b
)

:: Check if at least one file is provided
if "%~1"=="" (
    echo No files selected!
    pause
    exit /b
)

:: Count the number of files
set "file_count=0"
for %%F in (%*) do (
    set /a file_count+=1
)

:: If only one file is provided, send warn
if !file_count! equ 1 (
    echo Please use sendto!
    pause
    exit /b
)

:: Input title
set /p file_title="Set file title (press Enter to skip): "
echo.

:: Setup inputed file
set "video_files="
set "audio_files="
set "subtitle_files="
set "chapter_file="

:: Check extension
for %%F in (%*) do (
    set "ext=%%~xF"
    :: Video format
    if /I "!ext!"==".mp4" set "video_files=!video_files! %%~F"
    if /I "!ext!"==".mkv" set "video_files=!video_files! %%~F"
    if /I "!ext!"==".avi" set "video_files=!video_files! %%~F"
    if /I "!ext!"==".mov" set "video_files=!video_files! %%~F"
    if /I "!ext!"==".flv" set "video_files=!video_files! %%~F"
    if /I "!ext!"==".webm" set "video_files=!video_files! %%~F"
    if /I "!ext!"==".mpg" set "video_files=!video_files! %%~F"
    if /I "!ext!"==".mpeg" set "video_files=!video_files! %%~F"
    if /I "!ext!"==".vob" set "video_files=!video_files! %%~F"
    if /I "!ext!"==".ts" set "video_files=!video_files! %%~F"
    if /I "!ext!"==".wmv" set "video_files=!video_files! %%~F"

    :: Audio format
    if /I "!ext!"==".aac" set "audio_files=!audio_files! %%~F"
    if /I "!ext!"==".mp3" set "audio_files=!audio_files! %%~F"
    if /I "!ext!"==".flac" set "audio_files=!audio_files! %%~F"
    if /I "!ext!"==".opus" set "audio_files=!audio_files! %%~F"
    if /I "!ext!"==".ogg" set "audio_files=!audio_files! %%~F"
    if /I "!ext!"==".ac3" set "audio_files=!audio_files! %%~F"
    if /I "!ext!"==".dts" set "audio_files=!audio_files! %%~F"
    if /I "!ext!"==".wav" set "audio_files=!audio_files! %%~F"
    if /I "!ext!"==".m4a" set "audio_files=!audio_files! %%~F"

    :: Subtitle format
    if /I "!ext!"==".srt" set "subtitle_files=!subtitle_files! %%~F"
    if /I "!ext!"==".ass" set "subtitle_files=!subtitle_files! %%~F"
    if /I "!ext!"==".ssa" set "subtitle_files=!subtitle_files! %%~F"
    if /I "!ext!"==".vtt" set "subtitle_files=!subtitle_files! %%~F"
    if /I "!ext!"==".sub" set "subtitle_files=!subtitle_files! %%~F"
    if /I "!ext!"==".idx" set "subtitle_files=!subtitle_files! %%~F"
    if /I "!ext!"==".pgs" set "subtitle_files=!subtitle_files! %%~F"

    :: Chapter
    if /I "!ext!"==".xml" set "chapter_file=%%~F"

    :: Font format
    if /I "!ext!"==".ttf" set "font_files=!font_files! %%~F"
    if /I "!ext!"==".otf" set "font_files=!font_files! %%~F"
)

:: Sort
set "temp_dir=%TEMP%\mkvmerge_sort"
if not exist "!temp_dir!" mkdir "!temp_dir!"

:: Sort video
if defined video_files (
    >"!temp_dir!\video.txt" (
        for %%F in (!video_files!) do echo %%~nxF %%F
    )
    sort "!temp_dir!\video.txt" /o "!temp_dir!\video_sorted.txt"
    set "video_files="
    for /f "tokens=1,*" %%A in ('type "!temp_dir!\video_sorted.txt"') do (
        set "video_files=!video_files! %%B"
    )
)

:: Sort audio
if defined audio_files (
    >"!temp_dir!\audio.txt" (
        for %%F in (!audio_files!) do echo %%~nxF %%F
    )
    sort "!temp_dir!\audio.txt" /o "!temp_dir!\audio_sorted.txt"
    set "audio_files="
    for /f "tokens=1,*" %%A in ('type "!temp_dir!\audio_sorted.txt"') do (
        set "audio_files=!audio_files! %%B"
    )
)

:: Sort subtitle
if defined subtitle_files (
    >"!temp_dir!\sub.txt" (
        for %%F in (!subtitle_files!) do echo %%~nxF %%F
    )
    sort "!temp_dir!\sub.txt" /o "!temp_dir!\sub_sorted.txt"
    set "subtitle_files="
    for /f "tokens=1,*" %%A in ('type "!temp_dir!\sub_sorted.txt"') do (
        set "subtitle_files=!subtitle_files! %%B"
    )
)

:: Clean up temp dir
rd /s /q "!temp_dir!"

:: Combine video - audio - subtitle
set "media_files=!video_files! !audio_files! !subtitle_files!"

:: Create command
set "command=%mkvmerge_path% -o "%~n1_muxed.mkv""
if defined file_title set "command=!command! --title "!file_title!""

:: Setup command
for %%F in (!media_files!) do (
    echo Track: %%~nxF
    set /p track_name="Set track name (press Enter to skip): "
    set /p track_lang="Set language (2-letter language code, press Enter to skip): "
    set /p track_default="Set as default track? (y/n, press Enter to skip): "

    :: Build parameters for this file
    set "file_params="
    if not "!track_name!"=="" set "file_params=!file_params! --track-name 0:"!track_name!""
    if not "!track_lang!"=="" set "file_params=!file_params! --language 0:!track_lang!"
    if /I "!track_default!"=="y" set "file_params=!file_params! --default-track 0:yes"
    if /I "!track_default!"=="n" set "file_params=!file_params! --default-track 0:no"

    :: Add parameters and file to command
    set "command=!command! !file_params! "%%~F""
    echo.
)

:: Add chapter file
if defined chapter_file (
    echo Chapter file detected: !chapter_file!
    set "command=!command! --chapters "!chapter_file!""
    echo.
)

:: Execute
echo Muxing files...
%command%

if %ERRORLEVEL% EQU 0 (
    echo File created successfully: "%~n1_muxed.mkv"
) else (
    echo Error occurred during muxing!
    echo Command executed: %command%
    pause
)
exit /b