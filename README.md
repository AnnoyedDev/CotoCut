# CotoCut

`CotoCut` est un script conçus pour découper des fichiers vidéo `.m2ts` en fonction des chapitres définis dans un fichier `chapters.txt` généra automatiquement par le script (via eac3to) via le fichier de chapitre `.mpls`.
Si vous souhaitez utiliser la version Python, lancez le .py

## Prérequis

- Windows
- [ffmpeg](https://ffmpeg.org/download.html): Assurez-vous que `ffmpeg.exe` est accessible depuis la ligne de commande (ajouté au PATH ou placé dans le même répertoire que le script).
- [eac3to](https://madshi.net/eac3to.zip): Nécessaire pour traiter les fichiers `.m2ts` et `.mpls` et générer le fichier `chapters.txt`. Assurez-vous qu'il est également accessible depuis la ligne de commande ou placé dans le même répertoire que le script.
- Fichier `.mpls` contenant les données de chapitrages...
- Fichier `.m2ts` que vous souhaitez découper...

## Comment utiliser

1. Placez `CotoCut.bat` dans le même répertoire que votre fichier `.m2ts`

    Note: Vous pouvez télécharger la dernière version via https://github.com/AnnoyedDev/CotoCut/releases/latest
2. Déplacez votre fichier `.mpls` dans le même répertoire que `CotoCut.bat` et votre `.m2ts`
3. Exécutez `CotoCut.bat`.
4. Suivez les instructions à l'écran pour sélectionner les pistes audio, choisir les chapitres pour le découpage, et éventuellement prévisualiser les chapitres.
5. Les segments vidéo découpés seront sauvegardés dans le même répertoire avec le format `output_episode_[NUMÉRO].m2ts`.
