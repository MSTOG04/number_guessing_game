#!/bin/bash

PSQL="psql -X --username=freecodecamp --dbname=number_guess --tuples-only -c"



INPUT() {
  echo -e "\nEnter your username: \n"
  read NAME

  LEN=$(echo -n "$NAME" | wc -m)

  if  [[  $LEN -le 22 ]] && [[ $LEN -gt 0 ]]
  then
    USER=$($PSQL "SELECT * FROM users WHERE username = '$NAME'")
    
    if [[ -z $USER ]]
    then
      USERNAME=$NAME
      echo "Welcome, $USERNAME! It looks like this is your first time here."
      
    
    else
    
      USER_ID=$(echo $($PSQL "SELECT user_id FROM users WHERE username = '$NAME'") | sed 's/ //g')
      USERNAME=$(echo $($PSQL "SELECT username FROM users WHERE username = '$NAME'") | sed 's/ //g')
      GAMES_PLAYED=$(echo $($PSQL "SELECT games_played FROM users WHERE username = '$NAME'") | sed 's/ //g')
      echo $USER_ID $USERNAME $GAMES_PLAYED 

    
    fi

  else 
    INPUT
  fi

  ANSWER=$(( $RANDOM % 1000 + 1 ))
  echo $ANSWER
  GUESS_COUNT=0

  GAME $USERNAME $ANSWER $GUESS_COUNT
}

GAME() {

  USER_GUESS=$4

  if [[ -z $USER_GUESS ]]
  then
    echo "Guess the secret number between 1 and 1000:"
    read USER_GUESS
  fi 
  
  if [[ ! $USER_GUESS  =~ ^[0-9]+$ ]]
  then
    echo "That is not an integer, guess again:"
    read USER_GUESS
    GAME $USERNAME $ANSWER $GUESS_COUNT $USER_GUESS
  
  else
    GUESS_COUNT=$(( $GUESS_COUNT + 1 )) 
    CHECK_ANSERW $USERNAME $ANSWER $GUESS_COUNT $USER_GUESS
  fi
}

CHECK_ANSERW(){
  
  if [[ $USER_GUESS -lt $ANSWER ]]
  then
    echo "It's lower than that, guess again:"
    read USER_GUESS
    
    GAME $USERNAME $ANSWER $GUESS_COUNT $USER_GUESS

  elif [[ $USER_GUESS -gt $ANSWER ]]
  then
    echo "It's higher than that, guess again:"
    read USER_GUESS
    GAME $USERNAME $ANSWER $GUESS_COUNT $USER_GUESS

  else
    echo $GUESS_COUNT
  fi

}

INPUT