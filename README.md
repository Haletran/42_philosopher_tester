# 42_philosopher_tester
![Size](https://img.shields.io/github/repo-size/Haletran/42_philosopher_tester)
![Open Source](https://badges.frapsoft.com/os/v2/open-source.svg?v=103)

>Minimalistic philosopher tester made in bash script

## Usage

Put the tester next to your executable and run the tester with :
```bash
bash tester.sh
```
or run this command if you don't want to download the repo:
```bash
bash <(wget -qO- https://raw.githubusercontent.com/Haletran/42_philosopher_tester/main/tester.sh)
```

> <picture>
>   <source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/Mqxx/GitHub-Markdown/main/blockquotes/badge/light-theme/warning.svg">
>   <img alt="Warning" src="https://raw.githubusercontent.com/Mqxx/GitHub-Markdown/main/blockquotes/badge/dark-theme/warning.svg">
> </picture><br>
>
> If your printing message aren't these one the tester is going to put KO :
> <br>
> -> TIMESTAMP NB_OF_PHILO died <br>
> -> TIMESTAMP NB_OF_PHILO is eating <br>
> -> TIMESTAMP NB_OF_PHILO is sleeping <br>
> -> TIMESTAMP NB_OF_PHILO is thinking


## Add tests

If you want to add tests, just add a line in the corresponding parts.

Exemple if you want to add a test that check if the simulation runs forever, add this :
```bash
#TEST_NAME $TIMEOUT ARGS
living_test $TIMEOUT 5 800 200 200
```


## Calculator

Small script that check if the philo should died or not.

Run the script with this command :
```bash
bash <(wget -qO- https://raw.githubusercontent.com/Haletran/42_philosopher_tester/main/calculator.sh)
```

## License

This project is licensed under the [MIT License](LICENSE)


