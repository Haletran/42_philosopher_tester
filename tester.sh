#!/bin/bash

MAGENTA='\033[0;35m'
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'
total_tests=0
successfull_tests=0
total=0


check_compilation()
{
    make re > out
    if [ $? -ne 0 ]; then
        echo -e "Compilation :" $RED"KO"$NC
        rm out
        exit 1
    else
        echo -e "Compilation :" $GREEN"OK"$NC
    fi
    rm out
}


check_norminette()
{
    norminette $(pwd) > out
    if <out grep -q "Error"; then
        echo -e "Norminette :" $RED"KO"$NC
    else
        echo -e "Norminette :" $GREEN"OK"$NC
    fi
    rm out
}

parsing_test()
{
    ((total_tests++))
    timeout $1 ./philo "${@:2}"
    if [ $? -eq 1 ]; then
        echo -e "[ TEST $total_tests ] (${@:2}) : " $GREEN"OK"$NC
        ((successfull_tests++))
    else
        echo -e "[ TEST $total_tests ] (${@:2}) :" $RED"KO"$NC
    fi
}


dying_test()
{
    ((total_tests++))
    timeout $1 $leak ./philo "${@:2}" > out
    if <out grep -q "died"; then
        echo -e "[ TEST $total_tests ] (${@:2}) : " $GREEN"OK"$NC "("$(grep "died" out)$NC")"
        ((successfull_tests++))
    else
        echo -e "[ TEST $total_tests ] (${@:2}) :" $RED"KO"$NC
    fi
    rm out
}

living_test()
{
    ((total_tests++))
    timeout $1 $leak ./philo "${@:2}" > out
    if <out grep -q "died"; then
        echo -e "[ TEST $total_tests ] (${@:2}) :" $RED"KO"$NC
    else
        echo -e "[ TEST $total_tests ] (${@:2}) : " $GREEN"OK"$NC
        ((successfull_tests++))
    fi
    rm out
}

must_eat_test()
{
    ((total_tests++))
    timeout $2 $leak ./philo "${@:3}" > out
    if <out grep -q "died"; then
        echo -e "[ TEST $total_tests ] (${@:3}) :" $RED"KO"$NC "("$(grep "died" out)$NC")"
    else
        echo -e "[ TEST $total_tests ] (${@:3}) : " $GREEN"OK"$NC
        ((successfull_tests++))
    fi
    if [ $(grep "eating" out | wc -l) -ge $1 ]; then
        echo -e "-> count : " $GREEN"OK" "("$(<out grep "eating" | wc -l)")"$NC "("$(<out grep "thinking" | wc -l)")" "("$(<out grep "sleeping" | wc -l)")"
    else
        echo -e "-> count : " $RED"KO" "("$(<out grep "eating" | wc -l)")"$NC "("$(<out grep "thinking" | wc -l)")" "("$(<out grep "sleeping" | wc -l)")"
    fi
    rm out

}

input()
{
    read -p "How much second for timeout ? (default 10s) : " TIMEOUT
    if [ -z "$TIMEOUT" ]; then
        TIMEOUT=10
    fi
    
    read -p "Do you want to check leaks ? (y/N) : " LEAK
    if [ "$LEAK" = "y" ]; then
        echo -e $RED"the tester can cause some leaks on living_test"$NC
        leak="valgrind --tool=helgrind --fair-sched=yes"
    else
        leak=""
    fi
    clear
}

tester()
{
    input
    check_norminette
    check_compilation
    echo -e "\n--Parsing tests--"
    total_tests=0

    parsing_test $TIMEOUT 1
    parsing_test $TIMEOUT 0 410 200 200
    parsing_test $TIMEOUT 1 800
    parsing_test $TIMEOUT 1 800 200
    parsing_test $TIMEOUT 4 2147483649 200 200
    parsing_test $TIMEOUT 5 800 -200 200
    parsing_test $TIMEOUT 5 800 asd 123

    echo -e "\n--Mandatory tests--"
    total=$((total_tests + total))
    total_tests=0

    dying_test $TIMEOUT 1 800 200 200
    living_test $TIMEOUT 5 800 200 200
    must_eat_test 35 $TIMEOUT 5 800 200 200 7
    living_test $TIMEOUT 4 410 200 200
    dying_test $TIMEOUT 4 310 200 100

    echo -e "\n--Dying tests--"
    total=$((total_tests + total))
    total_tests=0

    dying_test $TIMEOUT 1 800 200 200
    dying_test $TIMEOUT 1 200 200 200
    dying_test $TIMEOUT 4 200 210 200
    dying_test $TIMEOUT 1 800 200 200
    dying_test $TIMEOUT 4 310 200 100
    dying_test $TIMEOUT 131 596 200 200
    dying_test $TIMEOUT 50 400 200 200
    dying_test $TIMEOUT 4 310 200 100 2
    dying_test $TIMEOUT 131 596 200 200 10

    echo -e "\n--Living tests--"
    total=$((total_tests + total))
    total_tests=0

    living_test $TIMEOUT 4 410 200 200
    living_test $TIMEOUT 2 800 200 200
    living_test $TIMEOUT 5 800 200 200
    living_test $TIMEOUT 4 2147483647 200 200
    living_test $TIMEOUT 200 410 200 200
    living_test $TIMEOUT 200 800 200 200
    living_test $TIMEOUT 105 800 200 200
    living_test $TIMEOUT 113 800 200 200


    echo -e "\n--Must-eats tests--"
    total=$((total_tests + total))
    total_tests=0

    must_eat_test 50 $TIMEOUT 5 800 200 200 10
    must_eat_test 35 $TIMEOUT 5 800 200 200 7
    must_eat_test 190 $TIMEOUT 19 210 69 139 10
    must_eat_test 30 $TIMEOUT 3 210 65 135 10
    must_eat_test 180 $TIMEOUT 18 180 85 85 10

    total=$((total_tests + total))

    echo -e "\nTotal :" $MAGENTA"$successfull_tests/$total"$NC
}

tester
