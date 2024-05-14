#!/bin/bash

MAGENTA='\033[0;35m'
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'
BOLD_CYAN='\033[1;36m'
total_tests=0
successfull_tests=0
total=0
philo_count=0

handle_ctrl_c()
{
    echo -e "\nStopped tester"
    rm out
    exit 1
}

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
    timeout $1 ./philo "${@:2}" > out
    if [ $? -eq 1 ] || grep -q "Error" out || [ $(wc -l < out) -le 2 ]; then
        echo -e "[ TEST $total_tests ] (${@:2}) : " $GREEN"OK"$NC
        ((successfull_tests++))
    else
        echo -e "[ TEST $total_tests ] (${@:2}) :" $RED"KO"$NC
    fi
    rm out
}

dying_test()
{
    ((total_tests++))
    timeout $1 ./philo "${@:2}" > out
    if grep -q "died" out && [ $(grep "died" out | wc -l) -eq 1 ]; then
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
    timeout $1 ./philo "${@:2}" > out
    if <out grep -q "died"; then
        echo -e "[ TEST $total_tests ] (${@:2}) :" $RED"KO"$NC "("$(grep "died" out)$NC")"
    else
        echo -e "[ TEST $total_tests ] (${@:2}) : " $GREEN"OK"$NC
        ((successfull_tests++))
    fi
    rm out
}


check_every_philo()
{
    count=1
    philo_count=$1

    while((count != philo_count + 1))
    do
        if [ $(grep -w "$count is eating" out | wc -l) -ge $2 ]; then
            echo -e "-> Philo $count has eaten enough : " $GREEN"OK"$NC "("$(grep -w "$count is eating" out | wc -l)")"
        else 
            echo -e "-> Philo $count has not eaten enough : " $RED"KO"$NC "("$(grep -w "$count is eating" out | wc -l)")"
            ((successfull_tests--))
        fi
        ((count++))
    done
}

must_eat_test()
{
    ((total_tests++))
    timeout $2 ./philo "${@:3}" | sed 's/\x1b\[[0-9;]*m//g' > out
    if <out grep -q "died"; then
        echo -e "[ TEST $total_tests ] (${@:3}) :" $RED"KO"$NC "("$(grep "died" out)$NC")"
    else
        echo -e "[ TEST $total_tests ] (${@:3}) : " $GREEN"OK"$NC
        ((successfull_tests++))
    fi
    eating_count=$(grep -w "eating" out | wc -l)
    args=("${@:3}")
    check_every_philo ${args[0]} ${args[4]}
    if [ $eating_count -ge $1 ]; then
        echo -e "--[ Total : " $GREEN"OK" "("$(grep -w "eating" out | wc -l)")"$NC" ]--"
    else
        echo -e "--[ Total : " $RED"KO" "("$(grep -w "eating" out | wc -l)")"$NC" ]--"
        ((successfull_tests--))
    fi
    rm out
}

input()
{
    read -p "How much second for timeout ? (default 10s) : " TIMEOUT
    if [ -z "$TIMEOUT" ]; then
        TIMEOUT=10
    fi
    clear
}

tester()
{
    input
    check_norminette
    check_compilation
    trap handle_ctrl_c INT
    echo -e $BOLD_CYAN"\n--Parsing tests--"$NC
    total_tests=0

    parsing_test $TIMEOUT 1
    parsing_test $TIMEOUT 0 410 200 200
    parsing_test $TIMEOUT 1 800
    parsing_test $TIMEOUT 1 800 200
    parsing_test $TIMEOUT 4 2147483649 200 200
    parsing_test $TIMEOUT 5 800 -200 200
    parsing_test $TIMEOUT 5 800 asd 123

    echo -e $BOLD_CYAN"\n--Mandatory tests--"$NC
    total=$((total_tests + total))
    total_tests=0

    dying_test $TIMEOUT 1 800 200 200
    living_test $TIMEOUT 5 800 200 200
    must_eat_test 35 $TIMEOUT 5 800 200 200 7
    living_test $TIMEOUT 4 410 200 200
    dying_test $TIMEOUT 4 310 200 100

    echo -e $BOLD_CYAN"\n--Dying tests--"$NC
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

    echo -e $BOLD_CYAN"\n--Living tests--"$NC
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


    echo -e $BOLD_CYAN"\n--Must-eats tests--"$NC
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
