#!/bin/bash
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'
TIMEOUT=10

echo "--Dying test--"

./philo 2 250 140 100 > out
<out grep -q "died" && echo -e "[ TEST 1 ] (2 250 140 100) : " $GREEN"OK"$NC "("$(grep "died" out)$NC")" || echo -e "[ TEST 1 ] :" $RED"KO"$NC "("$(grep "died" out)$NC")"
rm out
./philo 1 200 200 200 > out
<out grep -q "died" && echo -e "[ TEST 2 ] (1 200 200 200) :" $GREEN"OK"$NC "("$(grep "died" out)$NC")" || echo -e "[ TEST 2 ] :" $RED"KO"$NC "("$(grep "died" out)$NC")"
rm out
./philo 4 200 210 200 > out
<out grep -q "died" && echo -e "[ TEST 3 ] (4 200 210 200) :" $GREEN"OK"$NC "("$(grep "died" out)$NC")" || echo -e "[ TEST 3 ] :" $RED"KO"$NC "("$(grep "died" out)$NC")"
rm out
./philo 4 310 200 100 > out
<out grep -q "died" && echo -e "[ TEST 4 ] (4 310 200 100) :" $GREEN"OK"$NC "("$(grep "died" out)$NC")" || echo -e "[ TEST 4 ] :" $RED"KO"$NC "("$(grep "died" out)$NC")"
rm out
./philo 131 596 200 200 > out
<out grep -q "died" && echo -e "[ TEST 5 ] (131 596 200 200) :"  $GREEN"OK"$NC "("$(grep "died" out)$NC")" || echo -e "[ TEST 5 ] :" $RED"KO"$NC "("$(grep "died" out)$NC")"
rm out
./philo 131 596 200 200 10 > out
<out grep -q "died" && echo -e "[ TEST 6 ] (131 596 200 200 10) :" $GREEN"OK"$NC "("$(grep "died" out)$NC")" || echo -e "[ TEST 6 ] :" $RED"KO"$NC "("$(grep "died" out)$NC")"
rm out
./philo 50 400 200 200 > out
<out grep -q "died" && echo -e "[ TEST 7 ] (50 400 200 200) :" $GREEN"OK"$NC "("$(grep "died" out)$NC")" || echo -e "[ TEST 7 ] :" $RED"KO"$NC "("$(grep "died" out)$NC")"
rm out

echo "--Living test--" "(timeout $TIMEOUT)"

timeout $TIMEOUT ./philo 4 410 200 200 > out
grep -q "died" out && echo -e "[ TEST 1 ] :" $RED"KO"$NC || echo -e "[ TEST 1 ] : " $GREEN"OK"$NC
rm out
timeout $TIMEOUT ./philo 2 800 200 200 > out
grep -q "died" out && echo -e "[ TEST 2 ] :" $RED"KO"$NC || echo -e "[ TEST 2 ] : " $GREEN"OK"$NC
rm out
timeout $TIMEOUT ./philo 5 800 200 200 > out
grep -q "died" out && echo -e "[ TEST 3 ] :" $RED"KO"$NC || echo -e "[ TEST 3 ] : " $GREEN"OK"$NC
rm out
timeout $TIMEOUT ./philo 4 2147483647 200 200 > out
grep -q "died" out && echo -e "[ TEST 4 ] :" $RED"KO"$NC || echo -e "[ TEST 4 ] : " $GREEN"OK"$NC
rm out
timeout $TIMEOUT ./philo 200 410 200 200 > out
grep -q "died" out && echo -e "[ TEST 5 ] :" $RED"KO"$NC || echo -e "[ TEST 5 ] : " $GREEN"OK"$NC
rm out

echo "--Must eats--"

./philo 5 800 200 200 10 > out
grep -q "died" out && echo -e "[ TEST 1 ] :" $RED"KO"$NC || echo -e "[ TEST 1 ] : " $GREEN"OK"$NC
if [ $(grep "eating" out | wc -l) -ge 50 ]; then
    echo -e "-> count : " $GREEN"OK" "("$(<out grep "eating" | wc -l)")"$NC "("$(<out grep "thinking" | wc -l)")" "("$(<out grep "sleeping" | wc -l)")"
else
    echo -e "-> count : " $RED"KO" "("$(<out grep "eating" | wc -l)")"$NC "("$(<out grep "thinking" | wc -l)")" "("$(<out grep "sleeping" | wc -l)")"
fi
rm out
./philo 5 800 200 200 7 > out
grep -q "died" out && echo -e "[ TEST 2 ] :" $RED"KO"$NC || echo -e "[ TEST 2 ] : " $GREEN"OK"$NC
if [ $(grep "eating" out | wc -l) -ge 35 ]; then
    echo -e "-> count : " $GREEN"OK" "("$(<out grep "eating" | wc -l)")"$NC "("$(<out grep "thinking" | wc -l)")" "("$(<out grep "sleeping" | wc -l)")"
else
    echo -e "-> count : " $RED"KO" "("$(<out grep "eating" | wc -l)")"$NC "("$(<out grep "thinking" | wc -l)")" "("$(<out grep "sleeping" | wc -l)")"
fi
rm out
./philo 131 596 200 200 10 > out
grep -q "died" out && echo -e "[ TEST 3 ] :" $GREEN"OK"$NC || echo -e "[ TEST 3 ] : " $RED"KO"$NC
rm out
