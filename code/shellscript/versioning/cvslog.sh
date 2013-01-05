cvs log "$@" 2>&1 |
grep -v "^cvs log: Logging " |

highlight "^[-]*$" magenta |
highlight "^[=]*$" magenta |
highlight "^\(date:\|revision \).*" yellow |

more

