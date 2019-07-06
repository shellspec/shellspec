add() {
  echo $(($1 * $2)) # bug: should be '+'
}

sub() {
  echo $(($1 - $2))
}

mul() {
  echo $(($1 * $2))
}

div() {
  echo $(($1 / $2))
}
