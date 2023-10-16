@echo off
chcp 65001
title CotoCut
setlocal enabledelayedexpansion

:: Demande du numéro du fichier
set /p file_number="Entrez le numéro du fichier (par exemple, 00001 pour 00001.m2ts et 00001.mpls): "
set input_file=!file_number!.m2ts
set chapters_file=chapters.txt

:: Extraction des chapitres avec eac3to
eac3to !file_number!.mpls chapters.txt

:: Demander à partir de quel chapitre commencer
:chapter_select
set /p start_chapter="A partir de quel chapitre voulez-vous commencer (Vide = défaut | "aide" = à la selection du chapître)? "
set helpselection="debut"
if "%start_chapter%"=="aide" goto preview_mode
if not defined start_chapter set start_chapter=1

:: Détection des pistes audio
echo Pistes audio disponibles :
ffmpeg -hide_banner -i "%input_file%" 2>&1 | find "Stream" | find "Audio"

:: Demander quelles pistes audio il souhaite choisir
set /p audio_streams="Entrez les numéros des pistes audio que vous souhaitez choisir, séparés par des virgules (par ex. 0:1,0:2): "

:: Initialisation du timestamp de départ et demande du numéro de l'épisode si besoin

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

set current_chapter=%start_chapter%


:: Boucle principale
:main_loop
set /p count="Nombre de chapitres pour l'épisode !episode!, Chapitre actuel : !current_chapter! ("aide" = à la selection du chapitre | "retour" = Menu principal) ^> "
set helpselection="loop"
if "%count%"=="aide" goto preview_mode
if "%count%"=="retour" goto chapter_select
if not defined count goto end_script

:: Trouver le timestamp de fin
set /a target_chapter=current_chapter+count
set /a index=1
for /f "tokens=2 delims==" %%a in (%chapters_file%) do (
    if !index! EQU !target_chapter! (
        set end_time=%%a
    )
    set /a index+=1
)

:: Préparation des mappings pour FFmpeg
:: Mapper uniquement le flux vidéo
set map_args=-map 0:v
for %%a in (%audio_streams%) do (
    set map_args=!map_args! -map %%a
)

:: Découper le fichier vidéo avec les pistes audio sélectionnées
echo Decoupage de l'episode !episode! avec les chapitres !current_chapter!^-^>!target_chapter! de !start_time! a !end_time!
ffmpeg -i "%input_file%" -ss !start_time! -to !end_time! !map_args! -c copy "output_episode_!episode!.m2ts"

:: Mettre à jour le timestamp de départ et les compteurs pour le prochain segment
set start_time=!end_time!
set /a current_chapter+=count
set /a episode+=1

goto main_loop

:return_helper
if "%helpselection%"=="loop" goto main_loop
if "%helpselection%"=="debut" goto chapter_selec
goto chapter_select

:preview_mode
:: Demande du numéro du chapitre à prévisualiser
set /p preview_chapter="Entrez le numéro du chapitre que vous souhaitez prévisualiser ("retour" pour revenir en arrière) : "

if "%preview_chapter%"=="retour" goto return_helper

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
ffmpeg -i "%input_file%" -ss !preview_start_time! -to !preview_end_time! -c copy "preview_!preview_chapter!.mkv"

echo Fichier preview_!preview_chapter!.mkv créé pour le chapitre !preview_chapter!

goto preview_mode

:end_script
endlocal