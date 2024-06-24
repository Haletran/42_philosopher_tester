#!/bin/bash

MAGENTA='\033[0;35m'
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'
BOLD='\033[1m'
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
    check_ok=1
    philo_count=$1

    while((count != philo_count + 1))
    do
        if [ $(grep -w "$count is eating" out | wc -l) -ge $2 ]; then
            ((check_ok++))
        else 
            echo -e "-> Philo $count has not eaten enough : " $RED"KO"$NC "("$(grep -w "$count is eating" out | wc -l)")"
        fi
        ((count++))
        if [ $check_ok -eq $philo_count ]; then
            echo -e "-> All philos have eaten at least "$BOLD$2$NC time" : " $GREEN"OK"$NC
        fi
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
    fi
    rm out
}

input()
{
    read -p "How much second for timeout ? (default 10s) : " TIMEOUT
    if [ $? -eq 1 ] ; then exit 1; fi
    if [ -z "$TIMEOUT" ]; then
        TIMEOUT=10
    fi
    echo -e "[1] Parsing tests"
    echo -e "[2] Mandatory tests"
    echo -e "[3] Dying tests"
    echo -e "[4] Living tests"
    echo -e "[5] Must-eats tests"
    read -p "Choose test ? (default 0 = all) : " CHOICE
    if [ $? -eq 1 ] ; then exit 1; fi
    if [ -z "$CHOICE" ]; then
        CHOICE=0
    fi
    if [ $CHOICE -lt 0 ] || [ $CHOICE -gt 5 ]; then
        echo -e $RED"Invalid choice"$NC
        exit 1
    fi
    clear
}

tester()
{
    input
    check_norminette
    check_compilation
    trap handle_ctrl_c INT

    if [ $CHOICE -eq 1 ] || [ $CHOICE -eq 0 ]; then
        echo -e $BOLD_CYAN"\n--Parsing tests--"$NC
        total_tests=0
        parsing_test $TIMEOUT 1
        parsing_test $TIMEOUT 0 410 200 200
        parsing_test $TIMEOUT 1 800
        parsing_test $TIMEOUT 1 800 200
        parsing_test $TIMEOUT 4 2147483649 200 200
        parsing_test $TIMEOUT 5 800 -200 200
        parsing_test $TIMEOUT 5 800 asd 123
    fi


    if [ $CHOICE -eq 2 ] || [ $CHOICE -eq 0 ]; then
        echo -e $BOLD_CYAN"\n--Mandatory tests--"$NC
        total=$((total_tests + total))
        total_tests=0
        dying_test $TIMEOUT 1 800 200 200
        living_test $TIMEOUT 5 800 200 200
        must_eat_test 35 $TIMEOUT 5 800 200 200 7
        living_test $TIMEOUT 4 410 200 200
        dying_test $TIMEOUT 4 310 200 100
    fi

    if [ $CHOICE -eq 3 ] || [ $CHOICE -eq 0 ]; then
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
    fi


    if [ $CHOICE -eq 4 ] || [ $CHOICE -eq 0 ]; then
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
        living_test $TIMEOUT 5 310 100 100
        living_test $TIMEOUT 4 190 60 60
        living_test $TIMEOUT 3 190 60 60
    fi

    if [ $CHOICE -eq 5 ] || [ $CHOICE -eq 0 ]; then
        echo -e $BOLD_CYAN"\n--Must-eats tests--"$NC
        total=$((total_tests + total))
        total_tests=0
        must_eat_test 50 $TIMEOUT 5 800 200 200 10
        must_eat_test 35 $TIMEOUT 5 800 200 200 7
        must_eat_test 190 $TIMEOUT 19 210 69 139 10
        must_eat_test 30 $TIMEOUT 3 210 65 135 10
        must_eat_test 180 $TIMEOUT 18 180 85 85 20
    fi
    total=$((total_tests + total))

    notify-send "Job complete" "Total : $successfull_tests/$total"  
    echo -e "\nTotal :" $MAGENTA"$successfull_tests/$total"$NC
}

tester
