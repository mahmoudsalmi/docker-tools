#!/bin/sh

. "$HOME/.local/scripts/100-shell-tools-printer.sh"
. "$HOME/.local/scripts/101-shell-tools-files.sh"

usage() {
  printf "Usage: docker-tools volumes COMMAND VOLUME_NAME [BKP_FILENAME]\n\n"
  printf "  docker volumes tools scripts \n\n"
  printf "Commands list:\n"
  printf "    editor  | -e       Open editor (volume mounted on /volume)\n"
  printf "    backup  | -b       Backup existing docker volume\n"
  printf "    restore | -r       Restore volume from existing backup\n"
  printf "    help    | -h       Display usage\n"
  printf "\n"
}

if [ -z "${DOCKER_TOOLS_VOLUMES_BKP}" ]; then 
  exitError "Variable [ DOCKER_TOOLS_VOLUMES_BKP ] is not defined !\n" 1>&2 11
fi

if [ ! -d "${DOCKER_TOOLS_VOLUMES_BKP}" ]; then
  exitError "Folder [ ${DOCKER_TOOLS_VOLUMES_BKP} ] invalid or not exists !\n" 1>&2 12
fi

backup() {
  VOLUME_NAME=$1
  BKP_FILENAME="$2" 
  BKP_FOLDER="${DOCKER_TOOLS_VOLUMES_BKP}$VOLUME_NAME"

  # ---------------------------------- Check volume
  # VOLUME_NAME must be given
  if [ -z "$VOLUME_NAME" ]; then
    exitError "Not enough arguments!\nfor more information: docker-tools volumes help" 10
  fi
  # check if volume exists
  if ! docker volume inspect --format '{{.Name}}' "$VOLUME_NAME" > /dev/null 2>&1; then
    exitError "Volume [$VOLUME_NAME] does not exist !" 13 
  fi

  # ---------------------------------- Check backup folder and backup filename
  # set default BKP_FILENAME if not given 
  if [ -z "$BKP_FILENAME" ]; then 
    BKP_FILENAME="${VOLUME_NAME}_$(date +%Y%m%d%H%M%S).tar.gz"
  fi

  # Create BKP_FOLDER if not exists
  if [ ! -d "$BKP_FOLDER" ]; then
    newDir "$BKP_FOLDER"
  fi

  # check if BKP_FILE is already exists
  if [ -f "${BKP_FOLDER}/$BKP_FILENAME" ]; then
    exitError "Backup [$BKP_FILENAME] already exist !" 14
  fi

  # ---------------------------------- Run backup
  printKV "Backup" "[${VOLUME_NAME}] => [${BKP_FILENAME}]"
  if ! docker run --rm \
    -v "$VOLUME_NAME":/volume \
    -v "$BKP_FOLDER":/bkp \
    busybox \
    tar -zcvf /bkp/"$BKP_FILENAME" /volume;
  then
    exitError "Failed to start busybox backup container !" 15
  fi

  # ---------------------------------- Run backup
  printDone "[${VOLUME_NAME}] => [${BKP_FILENAME}]"
}

restore() {
  VOLUME_NAME=$1
  BKP_FILENAME="$2"
  BKP_FOLDER="${DOCKER_TOOLS_VOLUMES_BKP}$VOLUME_NAME"
  

  # ---------------------------------- Check volume
  # VOLUME_NAME must be given
  if [ -z "$VOLUME_NAME" ]; then
    exitError "Not enough arguments!\nfor more information: docker-tools volumes help" 16
  fi
  # check if volume exists
  if docker volume inspect --format '{{.Name}}' "$VOLUME_NAME" > /dev/null 2>&1; then
    exitError "Volume [$VOLUME_NAME] already exist !\nPlease remove volume before restore." 13 
  else
    printKV "Create volume" "${VOLUME_NAME}"
    if ! docker volume create "$VOLUME_NAME"; then
      exitError "Failed to create volume [$VOLUME_NAME] !" 15
    fi
  fi
  
  # ---------------------------------- check backup file
  # Calculate BKP_FILE
  if [ -z "$BKP_FILENAME" ]; then
    BKP_FILE=$(/bin/ls -At "$BKP_FOLDER/"*.tar.gz 2> /dev/null | head -n 1)
  else 
    BKP_FILE="$(ls "$BKP_FOLDER/$BKP_FILENAME" 2> /dev/null)"
  fi
  # check caluculate BKP_FILE
  if [ -z "$BKP_FILE" ]; then
    exitError "Backup [$BKP_FILENAME] not found!" 17
  else 
    BKP_FILENAME=$(basename "$BKP_FILE")
  fi

  # ----------------------------------- Run restore
  printKV "Backup" "${VOLUME_NAME} => ${BKP_FILENAME}"
  if ! docker run --rm \
    -v "$VOLUME_NAME":/volume \
    -v "$BKP_FOLDER":/bkp \
    busybox \
    tar -xvzf /bkp/"$BKP_FILENAME" -C /; 
  then
    exitError "Failed to start busybox container" 18
    exit 1
  fi

  
  printDone "[${BKP_FILE}] => [${VOLUME_NAME}]"
}

editor() {
  VOLUME_NAME=$1

  # ---------------------------------- Check volume
  # VOLUME_NAME must be given
  if [ -z "$VOLUME_NAME" ]; then
    exitError "Not enough arguments!\nfor more information: docker-tools volumes help" 10
  fi
  # check if volume exists
  if ! docker volume inspect --format '{{.Name}}' "$VOLUME_NAME" > /dev/null 2>&1; then
    exitError "Volume [$VOLUME_NAME] does not exist !" 13
  fi

  # check if volume exists
  DOCKER_EDITOR_VOLUME="docker_volume_editor_data"
  if ! docker volume inspect --format '{{.Name}}' "${DOCKER_EDITOR_VOLUME}" > /dev/null 2>&1; then
    printKV "Create volume" "${DOCKER_EDITOR_VOLUME}"
    if ! docker volume create "${DOCKER_EDITOR_VOLUME}"; then
      exitError "Failed to create volume [$DOCKER_EDITOR_VOLUME] !" 15
    fi
  fi

  if ! docker run -it --rm \
    -v "$DOCKER_EDITOR_VOLUME:/root/" \
    -v "${VOLUME_NAME}:/volume" \
    kickstart-nvim;
  then
    exitError "Failed to start kickstart-nvim container" 18
  fi
  
  printDone "Editor closed"
}

printTitle "Volumes tools"
COMMAND="$1"
shift
case $COMMAND in
  editor|-e) editor "$@" ;;
  backup|-b) backup "$@" ;;
  restore|-r) restore "$@" ;;
  help|-h) usage ;;
  *) exitError "Command [${COMMAND:-" "}] not found!\nfor more information: docker-tools volumes help" 10 ;;
esac

exit 0

