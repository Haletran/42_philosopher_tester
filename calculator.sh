#!/bin/bash

RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'


check_simulation()
{
    if [ $n_philo -eq 1 ]; then
        echo -e $RED"One philosopher should die"$NC
        return
    elif [ $n_philo -gt 1 ]; then
        if [ $(($n_philo % 2)) -eq 0 ]; then
            if [ $time_to_die -lt $(($time_to_eat + $time_to_sleep)) ]; then
                if [ $time_to_eat -gt $(($time_to_die / 2)) ]; then
                    echo -e $RED"One philosopher should die"$NC
                    return
                fi
            fi
        elif [ $(($n_philo % 2)) -eq 1 ]; then
            if [ $time_to_die -lt $(($time_to_eat + $time_to_sleep)) ]; then
                if [ $time_to_eat -gt $(($time_to_die / 3)) ]; then
                    echo -e $RED"One philosopher should die"$NC
                    return
                fi
            fi
        fi
    fi
    echo -e $GREEN"No philosopher should die"$NC
}
echo -e "--This script will check if the simulation is correct or not--\n"
read -p "Enter the number of philosophers: " n_philo
read -p "Enter the time to die: " time_to_die
read -p "Enter the time to eat: " time_to_eat
read -p "Enter the time to sleep: " time_to_sleep
check_simulation