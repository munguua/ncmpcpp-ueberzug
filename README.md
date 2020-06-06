# ncmpcpp-ueberzug

![ncmpcpp-ueberzug](img/demo.png)

**This is a work in progress! Not ready for distribution.**

ncmpcpp-ueberzug is a script displaying ncmpcpp album art using [ueberzug](https://github.com/seebye/ueberzug). It works on `Alacritty`, `st`, `urxvt`,  `kitty`, `xterm` and `lxterm`.


## Compatibility

No problem:
* `Alacritty`, `st`, `urxvt`,  `kitty`, `xterm`, `lxterm`

Broken:
* `gnome-terminal`, (Image displays on the last opened terminal irrespective of which is the ncmpcpp window, resizing can result in slightly incorrect geometry)
* `cool-retro-term` (geometry sometimes breaks on resize)
* `Konsole`, `Guake`, `terminator`, `sakura`, `terminology`, `xfce4-terminal`  (geometry is wrong)

