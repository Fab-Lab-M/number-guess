#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

NUMBER=$(( RANDOM % 1000 + 1 )) #random number

echo -e "\nEnter your username:"

read USER_NAME

NAME_AVAILABLE=$($PSQL "
  SELECT name
  FROM users
  WHERE name='$USER_NAME'
")

GAMES_PLAYED=$($PSQL "
  SELECT
    COUNT(DISTINCT games.game_id)
  FROM games
    LEFT JOIN  users
      ON games.user_id = users.user_id
  WHERE users.name = '$USER_NAME'
")

if [[ $GAMES_PLAYED == 0 ]]
then
  echo -e "\nWelcome, $USER_NAME! It looks like this is your first time here."
  
  if [[ -z $NAME_AVAILABLE ]]
  then
    INSERT_USER=$($PSQL "
      INSERT INTO users(name)
      VALUES ('$USER_NAME')
    ")
  fi

else
  BEST_GAME_N_GUESSES=$($PSQL "
    SELECT MIN(n_guess) 
    FROM games
      LEFT JOIN users
        ON games.user_id = users.user_id 
    WHERE users.name = '$USER_NAME'
  ")

  echo -e "\nWelcome back, $USER_NAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME_N_GUESSES guesses."

fi


echo  -e "\nGuess the secret number between 1 and 1000:"
GUESS=0

USER_ID=$($PSQL "
  SELECT user_id FROM users WHERE name='$USER_NAME'
")

N_GUESS=0

echo -e "$NUMBER"

while true
do
  read GUESS
  
  if [[ ! $GUESS =~ ^[0-9]+$ ]]
  then
    echo -e "\nThat is not an integer, guess again:"
  else
    N_GUESS=$((N_GUESS + 1))

    
    if [[ $GUESS -gt $NUMBER ]]
    then
      echo -e "\nIt's lower than that, guess again:"
    elif [[ $GUESS -lt $NUMBER ]]
    then
      echo -e "\nIt's higher than that, guess again:"
    else
      INSERT_GAME=$($PSQL "
        INSERT INTO games (random_number, user_id,n_guess)
        VALUES ($NUMBER, $USER_ID, $N_GUESS)
      ")
      echo -e "\nYou guessed it in $N_GUESS tries. The secret number was $NUMBER. Nice job!"
      break
    fi
  fi
done

