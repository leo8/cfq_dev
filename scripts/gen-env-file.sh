#!/bin/bash

echo "=== Saisie ton env de taff ==="
echo "1) stage"
echo "2) dev"
echo "3) prod"

# Demander le choix à l'utilisateur
read -p "Veuillez sélectionner un env (1, 2 ou 3) : " choix

# Gérer le choix avec une structure case
case $choix in
    1)
        cp file_config_env/stage/Info.plist ../ios/Runner/
        cp file_config_env/stage/GoogleService-Info.plist ../ios/Runner/
        cp file_config_env/stage/google-services.json ../android/app/
        cp file_config_env/stage/build.gradle ../android/app/
        ;;
    2)
        cp file_config_env/dev/Info.plist ../ios/Runner/
        cp file_config_env/dev/GoogleService-Info.plist ../ios/Runner/
        cp file_config_env/dev/google-services.json ../android/app/
        cp file_config_env/dev/build.gradle ../android/app/
        ;;
    3)
        cp file_config_env/prod/Info.plist ../ios/Runner/
        cp file_config_env/prod/GoogleService-Info.plist ../ios/Runner/
        cp file_config_env/prod/google-services.json ../android/app/
        cp file_config_env/prod/build.gradle ../android/app/
        ;;
    *)
        echo "Choix invalide. Veuillez relancer le script et entrer 1, 2 ou 3."
        ;;
esac
