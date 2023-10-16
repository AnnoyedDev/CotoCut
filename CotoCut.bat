@echo off
chcp 65001
setlocal enabledelayedexpansion

:: Demande à l'utilisateur du numéro.
set /p file_number="Entrez le numéro du fichier (par exemple, 00001 pour 00001.m2ts et 00001.mpls): "
set input_file=!file_number!.m2ts

:: Extraction des chapitres avec eac3to
eac3to !file_number!.mpls chapters.txt

:chapter_select
:: Demander à partir de quel chapitre commencer
set /p start_chapter="A partir de quel chapitre voulez-vous commencer (1 pour defaut, 6942 pour aide selection du chapitre)? "

if "%start_chapter%"=="6942" goto preview_mode

:: Initialiser le timestamp de départ et demander l'épisode si nécessaire
if "%start_chapter%" NEQ "1" (
    set /p episode="A partir de quel épisode voulez-vous commencer? "
    if not defined episode set episode=1
    
    set /a index=1
    for /f "tokens=2 delims==" %%a in (chapters.txt) do (
        if !index! EQU %start_chapter% (
            set start_time=%%a
        )
        set /a index+=1
    )
) else (
    set start_time=0:0:0.0
    set episode=1
)

:: Boucle principale pour découper les épisodes
:main_loop
set /p count="Nombre de chapitres pour cet episode? "
if not defined count goto end_script

:: Trouver le timestamp de fin
set /a target_chapter=current_chapter+count-1
set /a index=1
for /f "tokens=2 delims==" %%a in (chapters.txt) do (
    if !index! EQU !target_chapter! (
        set end_time=%%a
    )
    set /a index+=1
)

:: Découpage du fichier vidéo
ffmpeg -i "%input_file%" -ss !start_time! -to !end_time! -c copy "output_episode_!episode!.m2ts"

:: Mettre à jour le timestamp de départ et les compteurs pour le prochain segment
set start_time=!end_time!
set /a current_chapter+=count
set /a episode+=1

goto main_loop

:preview_mode
:: Demande du numéro du chapitre à prévisualiser
set /p preview_chapter="Entrez le numéro du chapitre que vous souhaitez prévisualiser (6942 pour revenir en arrière) : "

if "%preview_chapter%"=="6942" goto chapter_select

:: Trouver le timestamp de début pour le chapitre de prévisualisation
set /a index=1
for /f "tokens=2 delims==" %%a in (chapters.txt) do (
    if !index! EQU %preview_chapter% (
        set preview_start_time=%%a
    )
    set /a index+=1
)

:: Trouver le timestamp de début pour le chapitre de prévisualisation
set /a index=1
for /f "tokens=2 delims==" %%a in (chapters.txt) do (
    if !index! EQU %preview_chapter% (
        set preview_start_time=%%a
    )
    set /a index+=1
)

:: Conversion du preview_start_time en secondes et ajouter 20 secondes
for /f "tokens=1-3 delims=:" %%h in ("!preview_start_time!") do (
    set /a hours=%%h*3600
    set /a minutes=%%i*60
    set /a seconds=%%j
)

set /a total_seconds=hours + minutes + seconds + 20

:: Conversion total_seconds en format HH:MM:SS
set /a hours=total_seconds/3600
set /a minutes=(total_seconds%%3600)/60
set /a seconds=total_seconds%%60

if %hours% lss 10 set hours=0%hours%
if %minutes% lss 10 set minutes=0%minutes%
if %seconds% lss 10 set seconds=0%seconds%

set preview_end_time=%hours%:%minutes%:%seconds%

:: Créer un fichier MKV pour le chapitre de prévisualisation
ffmpeg -i "%input_file%" -ss !preview_start_time! -to !preview_end_time! -c:v copy -an "preview_!preview_chapter!.mkv"

echo Fichier preview_!preview_chapter!.mkv créé pour le chapitre !preview_chapter!

goto preview_mode

:end_script
endlocal
