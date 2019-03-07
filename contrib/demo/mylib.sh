add() {
  echo $(($1 * $2)) # bug: should be '+'
}
