#!/bin/bash

# Verifica si no se proporcionó un argumento
if [[ -z $1 ]]; then
  echo "Please provide an element as an argument."
  exit 0  # Salir del script sin errores
fi

# Comando para conectarse a la base de datos
PSQL="psql -X --username=freecodecamp --dbname=periodic_table --tuples-only -c"

# Obtiene el símbolo o número atómico del argumento
SYMBOL=$1

# Verifica si el argumento es un número
if [[ $SYMBOL =~ ^[0-9]+$ ]]; then
  # Si es un número, consulta por el número atómico
  DATA=$($PSQL "SELECT * FROM elements INNER JOIN properties USING(atomic_number) INNER JOIN types USING (type_id) WHERE atomic_number=$SYMBOL")
else
  # Si no es un número, trata como símbolo o nombre
  LENGTH=$(echo -n "$SYMBOL" | wc -m)
  if [[ $LENGTH -gt 2 ]]; then
    # Consulta por nombre
    DATA=$($PSQL "SELECT * FROM elements INNER JOIN properties USING(atomic_number) INNER JOIN types USING (type_id) WHERE name='$SYMBOL'")
  else
    # Consulta por símbolo
    DATA=$($PSQL "SELECT * FROM elements INNER JOIN properties USING(atomic_number) INNER JOIN types USING (type_id) WHERE symbol='$SYMBOL'")
  fi
fi

# Procesa el resultado de la consulta
if [[ -z $DATA ]]; then
  echo "I could not find that element in the database."
else
  echo "$DATA" | while read BAR BAR NUMBER BAR SYMBOL BAR NAME BAR WEIGHT BAR MELTING BAR BOILING BAR TYPE
  do
    echo "The element with atomic number $NUMBER is $NAME ($SYMBOL). It's a $TYPE, with a mass of $WEIGHT amu. $NAME has a melting point of $MELTING celsius and a boiling point of $BOILING celsius."
  done
fi
