# Alvord

## Install
``` bash
git clone git@github.com:jessiahr/alvord.git
cd alvord
mix escript.build && ./alvord seed
```

Then add this line to your bash_rc / profile (path may be different): 

`~/Desktop/dev/alvord/alvord export | source /dev/stdin`

## Basic usage: 

List the blocks and commands available:
``` bash
$  alvord help
Usage: alvord COMMAND

Available commands:
help    --  shows this message
ls      --  list all blocks
inspect --  show details of a block
seed    --  loads and enables hardcoded seeds
export  --  compile and output to stdIO all saved blocks

Active blocks:

-- function             clear_port
-- alias                alvord
-- alias                mc
-- function             show_port
-- config               ALVORD_RENDERED_AT
```


Inspect a block:
``` bash
$  alvord inspect clear_port
[
  {
    "name": "clear_port",
    "script": "pid_found=$(netstat -vanp tcp | grep $1 | awk '{print $9}')\nkill -9 $pid_found\n",
    "type": "function"
  }
]
```



