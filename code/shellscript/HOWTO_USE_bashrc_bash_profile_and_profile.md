Excellent answer here: https://unix.stackexchange.com/questions/192521/loading-profile-from-bash-profile-or-not-using-bash-profile-at-all#192550

But here is the executive summary.

- Put this in `.bash_profile`

    ```sh
    . ~/.profile
    case $- in *i*) . ~/.bashrc;; esac
    ```

- Put login-time things like environment variable definitions in `.profile`

- Put things for interactive shells in `.bashrc`
