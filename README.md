# 42_philosopher_tester
>Minimalistic philosopher tester
>Made in bash script

![tester gif](tester.gif)


## Usage

Put the tester next to your executable and run the tester with :
```
bash tester.sh
```
or run this command if you don't want to download the repo:
```
bash <(wget -qO- https://raw.githubusercontent.com/Haletran/42_philosopher_tester/main/tester.sh)
```

## Add tests

If you want to add tests, just add a line in the corresponding parts.

Exemple if you want to add a test that check if the simulation runs forever, add this :
```bash
#TEST_NAME $TIMEOUT ARGS
living_test $TIMEOUT 5 800 200 200
```
