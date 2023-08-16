#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Do not change code above this line. Use the PSQL variable above to query your database.
#year,round,winner,opponent,winner_goals,opponent_goals

TRUNCATE_RESULT="$($PSQL "TRUNCATE teams, games;")"
echo $TRUNCATE_RESULT

cat games.csv | while IFS="," read YEAR ROUND WINNER OPPONENT WINNER_GOALS OPPONENT_GOALS
do
  if [[ $WINNER != 'winner' ]]
  then
    existing_team_id=$($PSQL "SELECT team_id FROM teams WHERE name='$WINNER';")

    if [[ -z "$existing_team_id" ]]
    then
      INSERT_WINNER_RESULT="$($PSQL "INSERT INTO teams(name) VALUES('$WINNER');")"
      echo $INSERT_WINNER_RESULT
    else
      echo $WINNER ist schon in der datenbank
    fi

    existing_team_id=$($PSQL "SELECT team_id FROM teams WHERE name='$OPPONENT';")

    if [[ -z "$existing_team_id" ]]
    then
      INSERT_LOOSER_RESULT="$($PSQL "INSERT INTO teams(name) VALUES('$OPPONENT');")"
      echo $INSERT_LOOSER_RESULT
    else
      echo $OPPONENT ist schon in der datenbank
    fi
  fi
done

cat games.csv | while IFS="," read YEAR ROUND WINNER OPPONENT WINNER_GOALS OPPONENT_GOALS
do
  if [[ $YEAR != 'year' ]]
  then
    WINNER_ID="$($PSQL "SELECT team_id FROM teams WHERE name='$WINNER';")"
    LOOSER_ID="$($PSQL "SELECT team_id FROM teams WHERE name='$OPPONENT';")"


    INSERT_ROW_RESULT="$($PSQL "INSERT INTO games(year,round,winner_id,opponent_id,winner_goals,opponent_goals) VALUES($YEAR,'$ROUND',$WINNER_ID,$LOOSER_ID,$WINNER_GOALS,$OPPONENT_GOALS);")"
    echo $INSERT_ROW_RESULT
  fi
done