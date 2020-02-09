#!/usr/bin/env bash

PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH

readonly VERSION="1.0.0"

readonly FONT_COLOR_GREEN_PREFIX="\033[32m"
readonly FONT_COLOR_RED_PREFIX="\033[31m"
readonly FONT_COLOR_SUFFIX="\033[0m"
readonly BACKGROUND_COLOR_GREEN_PREFIX="\033[42;37m"
readonly BACKGROUND_COLOR_RED_PREFIX="\033[41;37m"

readonly MESSAGE_TIP_INFO="${FONT_COLOR_GREEN_PREFIX}[Info]${FONT_COLOR_SUFFIX}"
readonly MESSAGE_TIP_ERROR="${FONT_COLOR_RED_PREFIX}[Error]${FONT_COLOR_SUFFIX}"
readonly MESSAGE_TIP_WARNING="${FONT_COLOR_GREEN_PREFIX}[Warning]${FONT_COLOR_SUFFIX}"

SHELL_FOLDER="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

require_root(){
  [[ $EUID != 0 ]] && echo -e "${MESSAGE_TIP_ERROR} 当前账号非ROOT(或没有ROOT权限)，无法继续操作，请使用${FONT_COLOR_GREEN_PREFIX} sudo su ${FONT_COLOR_SUFFIX}来获取临时ROOT权限（执行后会提示输入当前账号的密码）。" && exit 1
}

shutdown(){
  kill -s 9 $(ps aux | grep ngrok | grep -v grep | awk 'NR==1{print $2}')
}

main(){
  require_root
  
  shutdown
}

main "$@"
