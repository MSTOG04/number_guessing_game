#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"



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
      BEST_GUESS=$(echo $($PSQL "SELECT MIN(best_game) FROM users LEFT JOIN games USING(user_id) WHERE user_id=$USER_ID;") | sed 's/ //g')
      
      echo "Welcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GUESS guesses."

    
    fi

  else 
    INPUT
  fi

  ANSWER=$(( $RANDOM % 1000 + 1 ))
  
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

  elif [[ $USER_GUESS -eq $ANSWER ]]
  then
    SAVE_USER $GUESS_COUNT $USERNAME

    NUMBER_OF_GUESSES=$GUESS_COUNT
    SECRET_NUMBER=$ANSWER
    echo "You guessed it in $NUMBER_OF_GUESSES tries. The secret number was $SECRET_NUMBER. Nice job!"
    
  fi

}

SAVE_USER(){

  CHECK_USER=$($PSQL "SELECT username FROM users WHERE username = '$USERNAME'")

  if [[ -z $CHECK_USER ]]
  then
    INSERT_USER=$($PSQL "INSERT INTO users(username, games_played) VALUES('$USERNAME', 1)")
  
  else
    GET_GAMES=$($PSQL "SELECT games_played FROM users WHERE username = '$CHECK_USER'")
    INSERT_USER=$($PSQL "UPDATE users SET games_played = ($GET_GAMES + 1) WHERE username = '$USERNAME'")

  fi

  SAVE_GAME $GUESS_COUNT $USERNAME
}

SAVE_GAME(){

  USER_ID=$($PSQL "SELECT user_id FROM users WHERE username='$USERNAME';")
  INSERT_GAME=$($PSQL "INSERT INTO games(user_id, best_game) VALUES($USER_ID, $GUESS_COUNT);")
  USERNAME=$($PSQL "SELECT username FROM users WHERE user_id=$USER_ID;")
}

INPUT