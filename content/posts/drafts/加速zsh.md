zsh-bench

调整.zshcompdump

默认`compinit`

```shell
==> benchmarking login shell of user maruka ...
creates_tty=0
has_compsys=1
has_syntax_highlighting=0
has_autosuggestions=1
has_git_prompt=1
first_prompt_lag_ms=9.656
first_command_lag_ms=121.354
command_lag_ms=7.518
input_lag_ms=3.161
exit_time_ms=55.218
```

```shell
==> benchmarking login shell of user maruka ...
creates_tty=0
has_compsys=1
has_syntax_highlighting=0
has_autosuggestions=1
has_git_prompt=1
first_prompt_lag_ms=9.631
first_command_lag_ms=118.865
command_lag_ms=7.559
input_lag_ms=2.856
exit_time_ms=55.503
```

```shell
==> benchmarking login shell of user maruka ...
creates_tty=0
has_compsys=1
has_syntax_highlighting=0
has_autosuggestions=1
has_git_prompt=1
first_prompt_lag_ms=9.805
first_command_lag_ms=121.162
command_lag_ms=7.537
input_lag_ms=2.973
exit_time_ms=54.887
```

`compinit -d /tmp/.zshcompdump`

```shell
==> benchmarking login shell of user maruka ...
creates_tty=0
has_compsys=1
has_syntax_highlighting=0
has_autosuggestions=1
has_git_prompt=1
first_prompt_lag_ms=10.208
first_command_lag_ms=120.725
command_lag_ms=7.556
input_lag_ms=2.701
exit_time_ms=55.146
```

```shell
==> benchmarking login shell of user maruka ...
creates_tty=0
has_compsys=1
has_syntax_highlighting=0
has_autosuggestions=1
has_git_prompt=1
first_prompt_lag_ms=9.769
first_command_lag_ms=120.444
command_lag_ms=7.491
input_lag_ms=3.073
exit_time_ms=54.962
```

```shell
==> benchmarking login shell of user maruka ...
creates_tty=0
has_compsys=1
has_syntax_highlighting=0
has_autosuggestions=1
has_git_prompt=1
first_prompt_lag_ms=9.635
first_command_lag_ms=119.905
command_lag_ms=7.531
input_lag_ms=3.041
exit_time_ms=55.236
```