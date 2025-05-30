#!/bin/bash


##############################################################################################################
# Configuration


BRANCH="main"
ORIGIN="git@github.com:HydraMeshnet/HVPN.git"
FILES_ADD=("*")
FILES_REMOVE=(".git/*")
COMMENT_COMMIT="$(date +%Y-%m-%d_%H:%M:%S)"
COMMENT_CLEAR="Removed history, due to sensitive data"
COMMENT_INIT="Initial commit"


##############################################################################################################
# Functions


_prompt() {
  echo -e "Origin: ${ORIGIN}"
  echo -e "Branch: ${BRANCH}"
  echo -e ""
  echo -e ""
  echo -e "Select an option:"
  options=("Diff" "Pull" "Commit/Push" "Clear History" "Init" "Init (Pull only)" "Init (Push only)" "Exit")
  select opt in "${options[@]}"; do
    case $opt in
    "Diff"*)
      _diff
      break;;
    "Pull"*)
      _pull
      break;;
    "Commit/Push"*)
      _commit
      break;;
    "Clear History"*)
      _clear
      break;;
    "Init (Pull only)"*)
      _init_pull
      break;;
    "Init (Push only)"*)
      _init_push
      break;;
    "Init"*)
      _init
      break;;
    "Exit"*)
      echo -e ""
      echo -e "Exit"
      break;;
    *)
      echo -e "Invalid choice!"
      break;;
    esac
  done
}


_define_files() {
  for file in ${FILES_ADD[@]}; do
    git add "${file}"
  done

  for file in ${FILES_REMOVE[@]}; do
    git reset -- "${file}"
  done
}


_diff() {
  git diff --numstat
}


_pull() {
  echo -e ""
  echo -e "Pull"

  git pull origin "${BRANCH}"
}


_commit() {
  _define_files

  git diff --numstat

  echo -e ""
  echo -e "Commit/Push to Git"
  echo -e "Comment:"

  read VAR
  if [ -z "${VAR}" ]; then
    VAR="${COMMENT_COMMIT}"
  fi

  git commit -a -m "${VAR}"
  git push
}


_clear() {
  echo -e ""
  echo -e "Clear History"
  echo -e "Comment:"

  read VAR
  if [ -z "${VAR}" ]; then
    VAR="${COMMENT_CLEAR}"
  fi

  rm -rf .git

  git init

  _define_files

  git commit -m "${VAR}"
  git branch -M "${BRANCH}"
  git remote add origin "${ORIGIN}"
  git push -f -u origin "${BRANCH}"
}


_init() {
  echo -e ""
  echo -e "Init"
  echo -e "Comment:"

  read VAR
  if [ -z "${VAR}" ]; then
    VAR="${COMMENT_INIT}"
  fi

  rm -rf .git

  git init

  _define_files

  git branch -M "${BRANCH}"
  git remote add origin "${ORIGIN}"

  git pull origin "${BRANCH}"

  git commit -m "${VAR}"

  git push -f -u origin "${BRANCH}"
}


_init_pull() {
  echo -e ""
  echo -e "Init (Pull only)"

  read VAR
  if [ -z "${VAR}" ]; then
    VAR="${COMMENT_INIT}"
  fi

  rm -rf .git

  git init

  _define_files

  git branch -M "${BRANCH}"
  git remote add origin "${ORIGIN}"

  git pull origin "${BRANCH}"

  git push -f -u origin "${BRANCH}"
}


_init_push() {
  echo -e ""
  echo -e "Init (Push only)"

  read VAR
  if [ -z "${VAR}" ]; then
    VAR="${COMMENT_INIT}"
  fi

  rm -rf .git

  git init

  _define_files

  git branch -M "${BRANCH}"
  git remote add origin "${ORIGIN}"

  git push -f -u origin "${BRANCH}"
}


##############################################################################################################
# Setup/Start


_prompt