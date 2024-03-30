#!/bin/bash
PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

echo "Enter your username:"
read USERNAME

USER_RESULT=$($PSQL "SELECT username FROM users WHERE username='$USERNAME'")

if [[ -z $USER_RESULT ]]; then
  echo "Welcome, $USERNAME! It looks like this is your first time here."
  INSERT_USER=$($PSQL "INSERT INTO users(username, games_played, best_game) VALUES('$USERNAME', 0, 1000)")
  GAMES_PLAYED=0
  BEST_GAME=1000
else
  GAMES_PLAYED=$($PSQL "SELECT games_played FROM users WHERE username='$USERNAME'")
  BEST_GAME=$($PSQL "SELECT best_game FROM users WHERE username='$USERNAME'")
  echo "Welcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
fi

CORRECT_NUMBER=$(( ( $RANDOM % 1000 ) + 1 ))
echo $CORRECT_NUMBER
GUESS_COUNT=1
GUESS=0
echo "Guess the secret number between 1 and 1000:"

while [[ $GUESS != $CORRECT_NUMBER ]]; do
  read GUESS

  if [[ $GUESS =~ ^[0-9]+$ ]]; then
    if [[ $GUESS < $CORRECT_NUMBER ]]; then
      GUESS_COUNT=$(( GUESS_COUNT + 1 ))
      echo "It's higher than that, guess again:"
    elif [[ $GUESS > $CORRECT_NUMBER ]]; then
      GUESS_COUNT=$(( GUESS_COUNT + 1 ))
      echo "It's lower than that, guess again:"
    else
      echo "You guessed it in $GUESS_COUNT tries. The secret number was $CORRECT_NUMBER. Nice job!"
      BEST_GAME=$(( $GUESS_COUNT < $BEST_GAME ? $GUESS_COUNT : $BEST_GAME ))
      GAMES_PLAYED=$(( $GAMES_PLAYED + 1 ))
      UPDATE_RESULT=$($PSQL "UPDATE users SET games_played='$GAMES_PLAYED', best_game='$BEST_GAME' WHERE username='$USERNAME'")
    fi
  else
    echo "That is not an integer, guess again:"
  fi
done

