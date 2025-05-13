#!/bin/bash

# Script pour générer les icônes de l'application à partir du logo
# Vérifie si ImageMagick est installé
if ! command -v convert &> /dev/null
then
    echo "ImageMagick n'est pas installé. Veuillez l'installer avec:"
    echo "sudo apt-get install imagemagick"
    exit 1
fi

# Chemin vers le logo source
LOGO_SOURCE="/home/naova/Documents/perso/food_guess/assets/logo_foodguess.png"

# Vérifier si le logo source existe
if [ ! -f "$LOGO_SOURCE" ]; then
    echo "Logo source introuvable: $LOGO_SOURCE"
    exit 1
fi

# Définir les tailles pour chaque densité d'écran
declare -A SIZES=(
    ["mipmap-mdpi"]=48
    ["mipmap-hdpi"]=72
    ["mipmap-xhdpi"]=96
    ["mipmap-xxhdpi"]=144
    ["mipmap-xxxhdpi"]=192
)

# Chemin de base pour les ressources Android
BASE_PATH="/home/naova/Documents/perso/food_guess/android/app/src/main/res"

# Traiter chaque taille
for dir in "${!SIZES[@]}"; do
    size=${SIZES[$dir]}
    output_path="$BASE_PATH/$dir/ic_launcher.png"
    
    echo "Génération de l'icône pour $dir (${size}x${size})..."
    
    # Créer le répertoire s'il n'existe pas
    mkdir -p "$BASE_PATH/$dir"
    
    # Redimensionner l'image en conservant le ratio et en ajoutant un fond blanc
    convert "$LOGO_SOURCE" -resize ${size}x${size} \
        -gravity center -background white \
        -extent ${size}x${size} "$output_path"
done

echo "Génération des icônes terminée!"
