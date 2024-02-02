#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"
SECRET_NUMBER=$(( ( RANDOM % 1000 ) + 1 ))
USER_GUESSES=0

START() {

  echo -e "\nEnter your username:"
  read NAME_INPUT

  if [[ $(echo $NAME_INPUT | wc -m) -le 23 && ! -z $NAME_INPUT ]]
  then

    USER_RESULT="$($PSQL "SELECT player_id, username FROM players WHERE username ILIKE '$NAME_INPUT';")"
    
    if [[ -z $USER_RESULT ]]
    then

      INSERT_RESULT=$($PSQL "INSERT INTO players(username) VALUES('$NAME_INPUT');")
      USER_NAME=$NAME_INPUT
      USER_ID=$($PSQL "SELECT player_id FROM players WHERE username = '$NAME_INPUT';")
      
      echo -e "\nWelcome, $USER_NAME! It looks like this is your first time here."

      GUESS_GAME
      INSERT_RESULT=$($PSQL "INSERT INTO games(player_id, guesses) VALUES($USER_ID, $USER_GUESSES);")
    
    else

      PLAYER_ID="$($PSQL "SELECT player_id FROM players WHERE username ILIKE '$NAME_INPUT';")"
      USERNAME="$($PSQL "SELECT username FROM players WHERE player_id = $PLAYER_ID;")"
      GAMES_PLAYED="$($PSQL "SELECT COUNT(game_id) FROM games WHERE player_id = $PLAYER_ID;")"
      BEST_GAME="$($PSQL "SELECT MIN(guesses) FROM games WHERE player_id = $PLAYER_ID;")"
      
      echo -e "\nWelcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
      
      GUESS_GAME
      INSERT_RESULT=$($PSQL "INSERT INTO games(player_id, guesses) VALUES($PLAYER_ID, $USER_GUESSES);")

    fi
  else

    START
  
  fi
  
}

GUESS_GAME() {

  if [[ ! -z $1 ]]
  then

    echo -e "\n$1"
  else
    echo -e "\nGuess the secret number between 1 and 1000:"
  fi
  read USER_GUESS
  (( USER_GUESSES++ ))

  if [[ ! -z $USER_GUESS ]]
  then
    if [[ $USER_GUESS =~ ^[0-9]+$ ]]
    then
      if [[ $USER_GUESS -gt $SECRET_NUMBER ]]
      then
        GUESS_GAME "It's lower than that, guess again:"
      elif [[ $USER_GUESS -lt $SECRET_NUMBER ]]
      then
        GUESS_GAME "It's higher than that, guess again:"
      else
        echo -e "\nYou guessed it in $USER_GUESSES tries. The secret number was $SECRET_NUMBER. Nice job!"
      fi
    else
      # (( USER_GUESSES-- ))
      GUESS_GAME "That is not an integer, guess again:"
    fi
  else
    # (( USER_GUESSES-- ))
    GUESS_GAME
  fi
}

START
