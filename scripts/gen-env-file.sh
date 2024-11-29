#!/bin/bash

echo "=== Saisie ton env de taff ==="
echo "1) stage"
echo "2) dev"
echo "3) main"

# Demander le choix à l'utilisateur
read -p "Veuillez sélectionner un env (1, 2 ou 3) : " choix

# Gérer le choix avec une structure case
case $choix in
    1)
        cp file_config_env/stage/Info.plist ../ios/Runner/
        cp file_config_env/stage/GoogleService-Info.plist ../ios/Runner/
        cp file_config_env/stage/AppDelegate.swift ../ios/Runner/
        cp file_config_env/stage/google-services.json ../android/app/
        cp file_config_env/stage/build.gradle ../android/app/
        cp file_config_env/stage/AndroidManifest.xml ../android/app/src/main
        cp file_config_env/stage/secrets_firebase.dart ../lib/secrets
        ;;
    2)
        cp file_config_env/dev/Info.plist ../ios/Runner/
        cp file_config_env/dev/GoogleService-Info.plist ../ios/Runner/
        cp file_config_env/dev/AppDelegate.swift ../ios/Runner/
        cp file_config_env/dev/google-services.json ../android/app/
        cp file_config_env/dev/build.gradle ../android/app/
        cp file_config_env/dev/AndroidManifest.xml ../android/app/src/main
        cp file_config_env/dev/secrets_firebase.dart ../lib/secrets
        ;;
    3)
        cp file_config_env/main/Info.plist ../ios/Runner/
        cp file_config_env/main/GoogleService-Info.plist ../ios/Runner/
        cp file_config_env/main/AppDelegate.swift ../ios/Runner/
        cp file_config_env/main/google-services.json ../android/app/
        cp file_config_env/main/build.gradle ../android/app/
        cp file_config_env/main/AndroidManifest.xml ../android/app/src/main
        cp file_config_env/main/secrets_firebase.dart ../lib/secrets
        ;;
    *)
        echo "Choix invalide. Veuillez relancer le script et entrer 1, 2 ou 3."
        ;;
esac
