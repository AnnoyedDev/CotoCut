@echo off
title CotoCut
chcp 65001
setlocal enabledelayedexpansion

:: Demande du numéro du fichier
set /p file_number="Entrez le numéro du fichier (par exemple, 00001 pour 00001.m2ts et 00001.mpls): "
set input_file=!file_number!.m2ts
set chapters_file=chapters.txt

:: Détection des pistes audio
echo Pistes audio disponibles :
ffmpeg -hide_banner -i "%input_file%" 2>&1 | find "Stream" | find "Audio"

:: Demander quelles pistes audio il souhaite choisir
set /p audio_streams="Entrez les numéros des pistes audio que vous souhaitez choisir, séparés par des virgules (par ex. 0:1,0:2): "

:: Demander à partir de quel chapitre commencer
set /p start_chapter="A partir de quel chapitre voulez-vous commencer (1 par defaut)? "
if not defined start_chapter set start_chapter=1

:: Initialisation du timestamp de départ


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
set /p count="Nombre de chapitres pour cet episode? "
if not defined count goto end_script

:: Trouver le timestamp de fin
set /a target_chapter=current_chapter+count-1
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
echo Decoupage de l'episode avec les chapitres de !start_time! a !end_time!
ffmpeg -i "%input_file%" -ss !start_time! -to !end_time! !map_args! -c copy "output_episode_!episode!.m2ts"

:: Mettre à jour le timestamp de départ et les compteurs pour le prochain segment
set start_time=!end_time!
set /a current_chapter+=count
set /a episode+=1

goto main_loop

:end_script
endlocal
