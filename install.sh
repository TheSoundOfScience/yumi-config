#!/bin/bash

# Récupérer l'utilisateur qui exécute le script
REAL_USER="$USER"

# Initialisation de la variable OWNER
OWNER=""

# Récupérer le répertoire de l'utilisateur
if [ -n "$SUDO_USER" ]; then
    echo "shell script execute by with sudo :  user is $SUDO_USER"
    if [ "$SUDO_USER" = "runner" ]; then
        # Définir USER_HOME spécifiquement pour 'runner' et définir OWNER à 'pi'
        USER_HOME="/home/pi"
        OWNER="pi"
    else
        USER_HOME=$(getent passwd "$SUDO_USER" | cut -d: -f6)
        OWNER="$SUDO_USER"
    fi
else
    USER_HOME=$(getent passwd "$USER" | cut -d: -f6)
    OWNER="$USER"
    echo "shell script execute without sudo : user is $USER"
fi

echo "Real user: $REAL_USER"
echo "User's home directory: $USER_HOME"
echo "Owner for chown: $OWNER"

# Define the Klipper directory using USER_HOME instead of HOME
KLIPPER_DIR="$USER_HOME/klipper"
echo "Klipper directory: $KLIPPER_DIR"

# Define the project directory
PROJECT_DIR="$PWD"
echo "Project directory: $PROJECT_DIR"

KLIPPER_CONFIG_DIR="$KLIPPER_DIR/printer_data/config"
echo "Répertoire du config: $KLIPPER_CONFIG_DIR"

# Définition de la fonction d'installation
function install {
  # Remplacer les fichiers du projet dans le répertoire Klipper
  rm -f "$KLIPPER_CONFIG_DIR/smartpad-cpu-temp.cfg" && echo "smartpad-cpu-temp.cfg supprimé avec succès." || echo "Erreur lors de la suppression de smartpad-cpu-temp.cfg."
  cp "$PROJECT_DIR/smartpad-generic/smartpad-cpu-temp.cfg" "$KLIPPER_CONFIG_DIR" && echo "smartpad-cpu-temp.cfg copié avec succès." || echo "Erreur lors de la copie de smartpad-cpu-temp.cfg."
  rm -f "$KLIPPER_CONFIG_DIR/smartpad-adxl345.cfg" && echo "smartpad-adxl345.cfg supprimé avec succès." || echo "Erreur lors de la suppression de smartpad-adxl345.cfg."
  cp "$PROJECT_DIR/smartpad-generic/smartpad-adxl345.cfg" "$KLIPPER_CONFIG_DIR" && echo "smartpad-adxl345.cfg copié avec succès." || echo "Erreur lors de la copie de smartpad-adxl345.cfg."
 
  if [ "$1" == "smartpad-generic" ]; then
  rm -f "$KLIPPER_CONFIG_DIR/printer.cfg" && echo "printer.cfg supprimé avec succès." || echo "Erreur lors de la suppression de printer.cfg."
  cp "$PROJECT_DIR/$1/printer.cfg" "$KLIPPER_CONFIG_DIR" && echo "printer.cfg copié avec succès." || echo "Erreur lors de la copie de printer.cfg."
  fi

  # Modifier les permissions pour que l'utilisateur "pi" conserve les droits sur les fichiers créés ou modifiés
  chown -R pi:pi "$KLIPPER_CONFIG_DIR"
}

# Vérifier si le script a été appelé avec un argument
if [ "$1" == "" ]; then
  # Si aucun argument n'est passé, installer smartpad-generic
  echo "Aucun argument passé. Installation de smartpad-generic."
  install "smartpad-generic"
else
  # Vérifier si le dossier correspondant à l'argument existe
  if [ ! -d "$PROJECT_DIR/$1" ]; then
    echo "Erreur : $PROJECT_DIR/$1 n'existe pas. Installation de smartpad-generic."
    install "smartpad-generic"
  else
    echo "Installation du projet : $1"
    install "$1"
  fi
fi

echo "Installation terminée."
