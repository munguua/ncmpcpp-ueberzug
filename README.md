# ncmpcpp-ueberzug

![ncmpcpp-ueberzug](img/demo.png)

`ncmpcpp-ueberzug` is a POSIX shell script displaying ncmpcpp album art using [ueberzug](https://github.com/seebye/ueberzug). It works on `alacritty`, `st`, `urxvt`,  `kitty`, `xterm` and `lxterm`. Unlike previous scripts, it dynamically sizes and positions the cover art such that the window can be any size, even resized. It has many settings to customize the position of the album art to suit your ncmpcpp setup,

## Setup

First install [ueberzug](https://github.com/seebye/ueberzug). If you already have Python and pip:

```bash
$ sudo pip3 install ueberzug
```

Navigate to your ncmpcpp config folder and clone the repository: 
```bash
$ cd ~/.ncmpcpp
$ git clone https://github.com/alnj/ncmpcpp-ueberzug.git
```

Make `ncmpcpp-ueberzug` and `ncmpcpp_cover_art.sh` executable: 
```bash
$ cd ncmpcpp-ueberzug
$ chmod +x ncmpcpp-ueberzug ncmpcpp_cover_art.sh
```
Open your ncmpcpp config at `~/.ncmpcpp/config` and add this line: 
```toml
execute_on_song_change="~/.ncmpcpp/ncmpcpp-ueberzug/ncmpcpp_cover_art.sh"
```

Open `ncmpcpp_cover_art.sh` and adjust the settings at the top of the script to suit to your setup:
```toml
# How to installHow to installSETTINGS
music_library="$HOME/music"
fallback_image="$HOME/.ncmpcpp/ncmpcpp-ueberzug/fallback.png"
padding_top=3 # These values are in characters
padding_bottom=1
padding_right=2
max_width=0 # Cover art will not expand past this limit. 0 = unlimited
reserved_playlist_cols=30
reserved_cols_in_percent="false" # Change this if you use ncmpcpp columns mode,
                                 # see README for more info
force_square="false" # If "true", the cover art will downsize
                     # instead of cropping horizontally
square_alignment="top" # top, center or bottom

```
The `padding_` and `reserved_playlist_cols` values are in *characters*, here is an image to make it easier to understand:

![ncmpcpp-ueberzug settings](img/settings_explained.png)

`reserved_playlist_cols` is the number of columns you want to protect from the cover image such that it will not be covered by it. [The cover image will be truncated so as not to cover that area.](img/truncate_reserved_cols.gif) If you use the default "columns" layout in ncmpcpp, read on to the next section.

Now, simply run `ncmpcpp-ueberzug` to open ncmpcpp with album art enabled.
```bash
$ ~/.ncmpcpp/ncmpcpp-ueberzug/ncmpcpp-ueberzug
``` 
You may move or symlink it somewhere in your $PATH such that using its full path is unneeded. For example:
```bash
$ ln -s ~/.ncmpcpp/ncmpcpp-ueberzug/ncmpcpp-ueberzug ~/.local/bin/
$ ncmpcpp-ueberzug
```

### Additional steps for ncmpcpp columns mode

In order for [ncmpcpp columns mode](img/ueberzug_columns_mode.gif) to work well with ncmpcpp-ueberzug, first make sure your columns' total width in `~/.ncmpcpp/config` is inferior to 100%:

```toml
song_columns_list_format = "(25)[6]{a} (35)[4]{t} (5)[2]{l}"
```

Here the total is `(25)` + `(35)` + `(5)` = 65%. For best results, use song length `{l}` as your last column. Next, change the `ncmpcpp_cover_art.sh` settings:

```toml
reserved_playlist_cols=75 # Set this at least 5 percentage points above your columns' total
reserved_cols_in_percent="true" # set this to "true"
```

Album art should now crop and resize properly.


## Compatibility

Known to work:
* `alacritty`, `st`, `urxvt`,  `kitty`, `xterm`, `lxterm`

Require manually setting character size in `ncmpcpp_cover_art.sh`:
* `cool-retro-term` 
* `sakura` (resizing can break geometry)
* `gnome-terminal`, `terminator`, `xfce4-terminal`  (Album art displays on the last opened terminal irrespective of which is the ncmpcpp window, resizing can break geometry)

Broken:
* `konsole` (stops working randomly, geometry is wrong)
* `guake`, `terminology` (geometry is wrong)


## Similar scripts

If ncmpcpp-ueberzug doesn't meet your needs, consider these alternatives.

* [Fixed-width, left-aligned Mopidy album art Python script using Ueberzug](https://www.reddit.com/r/unixporn/comments/addcrf/oc_mopidy_album_art_using_ueberzug/)

* [Ueberzug script that opens the album art in a tmux pane](https://www.reddit.com/r/unixporn/comments/9bifne/ncmpcpp_with_cover_art_ueberzug_tmux_edition/)

* [Fixed-geometry urxvt-compatible script using urxvt background escape codes](https://gist.github.com/vlevit/4588882)



## To-do

* Change cleanup mechanism to allow for several ncmpcpp-ueberzug instances
* Support embedded album art
* Support fetching album art from the web
* Support Spotify album art with mopidy
* Update columns gif with new geometry behaviour
