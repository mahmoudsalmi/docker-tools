#! /bin/sh

. "$HOME/.local/scripts/100-shell-tools-printer.sh"

usage() {
  printf "Usage: docker-tools COMMAND\n\n"
  printf "  docker tools scripts \n\n"
  printf "Commands list:\n"
  printf "    volumes | -v       Volumes tools\n"
  printf "    help    | -h       Display usage\n"
  printf "\n"
}

printBanner() {
  printf "\n"
  printf "░▒█▀▀▄░▄▀▀▄░█▀▄░█░▄░█▀▀░█▀▀▄░░░░▀█▀░▄▀▀▄░▄▀▀▄░█░░█▀▀░░\n"
  printf "░▒█░▒█░█░░█░█░░░█▀▄░█▀▀░█▄▄▀░▀▀░░█░░█░░█░█░░█░█░░▀▀▄░░\n"
  printf "░▒█▄▄█░░▀▀░░▀▀▀░▀░▀░▀▀▀░▀░▀▀░░░░░▀░░░▀▀░░░▀▀░░▀▀░▀▀▀░░\n"
  printf "\n"
}

printBanner

COMMAND="$1"
shift
case $COMMAND in
  volumes|-v) docker-tools-volumes "$@" || exit $? ;;
  help|-h) usage ;;
  *) exitError "Command [${COMMAND:-" "}] not found!\nfor more information: docker-tools -h" 10 ;;
esac

exit 0
