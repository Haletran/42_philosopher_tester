# 42_philosopher_tester
![Size](https://img.shields.io/github/repo-size/Haletran/42_philosopher_tester)
![Open Source](https://badges.frapsoft.com/os/v2/open-source.svg?v=103)

>Minimalistic philosopher tester
>Made in bash script
<img src="show_tester.gif" width="600" height="500">


## Usage

Put the tester next to your executable and run the tester with :
```bash
bash tester.sh
```
or run this command if you don't want to download the repo:
```bash
bash <(wget -qO- https://raw.githubusercontent.com/Haletran/42_philosopher_tester/main/tester.sh)
```

## Add tests

If you want to add tests, just add a line in the corresponding parts.

Exemple if you want to add a test that check if the simulation runs forever, add this :
```bash
#TEST_NAME $TIMEOUT ARGS
living_test $TIMEOUT 5 800 200 200
```


## Calculator

Small script that check if the simulation is feasible or not.

Run the script with this command :
```bash
bash <(wget -qO- https://raw.githubusercontent.com/Haletran/42_philosopher_tester/main/calculator.sh)
```

