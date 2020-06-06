#!/bin/sh

# SETTINGS
music_library="$HOME/music"
fallback_image="$HOME/.ncmpcpp/ncmpcpp-ueberzug/fallback.png"

padding_top=3 # These values are in characters
padding_bottom=1
padding_right=2
reserved_playlist_cols=30

# Set this if the geometries are wrong or ncmpcpp shouts at you to do it
font_height=
font_width=

main() {
    kill_previous_instances >/dev/null 2>&1
    find_cover_image        >/dev/null 2>&1
    display_cover_image     2>/dev/null
    detect_window_resizes   >/dev/null 2>&1
}

# ==== Main functions =========================================================

kill_previous_instances() {
    script_name=$(basename "$0")
    for pid in $(pidof -x "$script_name"); do
        if [ "$pid" != $$ ]; then
            kill -15 "$pid"
        fi 
    done
}

find_cover_image() {
    album="$(mpc --format %album% current)"
    file="$(mpc --format %file% current)"
    album_dir="${file%/*}"

    if [ -z "$album_dir" ]; then
        exit 1
    fi

    album_dir="$music_library/$album_dir"
    found_covers="$(find "$album_dir" -type d -exec find {} -maxdepth 1 -type f \
    -iregex ".*/.*\(${album}\|cover\|folder\|artwork\|front\).*[.]\\(jpe?g\|png\|gif\|bmp\)" \; )"
    cover_path="$(echo "$found_covers" | head -n1)"

    if [ -z "$cover_path" ]; then
        cover_path=$fallback_image
    fi
}

display_cover_image() {
    compute_geometry

    send_to_ueberzug \
        action "add" \
        identifier "mpd_cover" \
        path "$cover_path" \
        x "$ueber_left" \
        y "$padding_top" \
        height "$ueber_height" \
        width "$ueber_width" \
        synchronously_draw "True" \
        scaler "forced_cover" \
        scaling_position_x "0.5"
}

detect_window_resizes() {
    {
        trap 'display_cover_image' WINCH
        while :; do sleep .1; done
    } &
}


# ==== Helper functions =========================================================

compute_geometry() {
    unset LINES COLUMNS # Required in order for tput to work in a script
    term_lines=$(tput lines)
    term_cols=$(tput cols)

    if [ -z "$font_height" ] || [ -z "$font_height" ]; then
        guess_font_size
    fi

    ueber_height=$(( term_lines - padding_top - padding_bottom ))
    # Because Ueberzug uses characters as a unit we must multiply
    # the line count (height) by the font size ratio in order to
    # obtain an equivalent width in column count
    ueber_width=$(( ueber_height * font_height / font_width ))
    ueber_left=$(( term_cols - ueber_width - padding_right ))

    if [ "$ueber_left" -lt "$reserved_playlist_cols" ]; then
        ueber_left=$reserved_playlist_cols
        ueber_width=$(( term_cols - reserved_playlist_cols - padding_right ))
    fi
}

guess_font_size() {
    # A font width and height estimate is required to
    # properly compute the Ueberzug width (in columns).
    # We are reproducing the arithmetic used by Ueberzug
    # to guess font size.
    # https://github.com/seebye/ueberzug/blob/master/ueberzug/terminal.py#L24

    guess_terminal_pixelsize

    approx_font_width=$(( term_width / term_cols ))
    approx_font_height=$(( term_height / term_lines ))

    term_xpadding=$(( ( - approx_font_width * term_cols + term_width ) / 2 ))
    term_ypadding=$(( ( - approx_font_height * term_lines + term_height ) / 2 ))

    font_width=$(( (term_width - 2 * term_xpadding) / term_cols ))
    font_height=$(( (term_height - 2 * term_ypadding) / term_lines ))
}

guess_terminal_pixelsize() {
    # We are re-using the same Python snippet that
    # Ueberzug utilizes to retrieve terminal window size.
    # wmctrl/xdotool/xwininfo-based/escape-based solutions
    # are all unreliable and not all faster.
    # https://github.com/seebye/ueberzug/blob/master/ueberzug/terminal.py#L10

    python <<'    END'
import sys, struct, fcntl, termios

def get_geometry():
    fd_pty = sys.stdout.fileno()
    farg = struct.pack("HHHH", 0, 0, 0, 0)
    fretint = fcntl.ioctl(fd_pty, termios.TIOCGWINSZ, farg)
    rows, cols, xpixels, ypixels = struct.unpack("HHHH", fretint)
    return "{} {}".format(xpixels, ypixels)

output = get_geometry()
f = open("/tmp/ncmpcpp_geometry.txt", "w")
f.write(output)
f.close()
    END

    # ioctl doesn't work inside $() for some reason so we
    # must use a temporary file
    term_width=$(awk '{print $1}' /tmp/ncmpcpp_geometry.txt)
    term_height=$(awk '{print $2}' /tmp/ncmpcpp_geometry.txt)
    rm "/tmp/ncmpcpp_geometry.txt"

    if [ -n "$term_height" ] && [ -n "$term_width" ]; then
        return
    else
        echo "ncmpcpp-ueberzug: font size detection failed, please set manually"
    fi
}

send_to_ueberzug() {
    old_IFS="$IFS"

    # Ueberzug's "simple parser" uses tab-separated
    # keys and values so we separate words with tabs
    # and send the result to the wrapper's FIFO
    IFS="$(printf "\t")"
    echo "$*" > "$FIFO_UEBERZUG"

    IFS=${old_IFS}
}


main
