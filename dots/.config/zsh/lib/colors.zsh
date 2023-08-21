#!/usr/bin/env zsh

reset_color="$(tput sgr0)"
UNDERLINE="$(tput smul)"
BOLD="$(tput bold)"
STANDOUT="$(tput smso)"
BLINK="$(tput blink)"

echo_rgb() {
	local red
	local green
	local blue

	red="${1}"
	green="${2}"
	blue="${3}"

	printf "\e[0;38;2;%s;%s;%sm" "${red}" "${green}" "${blue}"
}

echo_hex() {
	local hex="${1:1}"
	local hex_rgb
	IFS=" " read -A hex_rgb <<< "$(printf "%d %d %d" 0x"${hex:0:2}" 0x"${hex:2:2}" 0x"${hex:4:2}")"
	echo_rgb ${hex_rgb[@]}
}

cleanup-colors() {
	unset echo_hex
	unset echo_rgb
	unset reset_color
	unset underline
	unset bold
	unset standout
	unset blink
	unset kanagawa
}

typeset -A kanagawa=(
	sumiInk0      $(echo_hex "#16161D")
	sumiInk1      $(echo_hex "#181820")
	sumiInk2      $(echo_hex "#1a1a22")
	sumiInk3      $(echo_hex "#1F1F28")
	sumiInk4      $(echo_hex "#2A2A37")
	sumiInk5      $(echo_hex "#363646")
	sumiInk6      $(echo_hex "#54546D")
	waveBlue1     $(echo_hex "#223249")
	waveBlue2     $(echo_hex "#2D4F67")
	winterGreen   $(echo_hex "#2B3328")
	winterYellow  $(echo_hex "#49443C")
	winterRed     $(echo_hex "#43242B")
	winterBlue    $(echo_hex "#252535")
	autumnGreen   $(echo_hex "#76946A")
	autumnRed     $(echo_hex "#C34043")
	autumnYellow  $(echo_hex "#DCA561")
	samuraiRed    $(echo_hex "#E82424")
	roninYellow   $(echo_hex "#FF9E3B")
	waveAqua1     $(echo_hex "#6A9589")
	oldWhite      $(echo_hex "#C8C093")
	fujiWhite     $(echo_hex "#DCD7BA")
	fujiGray      $(echo_hex "#727169")
	oniViolet     $(echo_hex "#957FB8")
	oniViolet2    $(echo_hex "#b8b4d0")
	crystalBlue   $(echo_hex "#7E9CD8")
	springViolet1 $(echo_hex "#938AA9")
	springViolet2 $(echo_hex "#9CABCA")
	springBlue    $(echo_hex "#7FB4CA")
	lightBlue     $(echo_hex "#A3D4D5")
	waveAqua2     $(echo_hex "#7AA89F")
	springGreen   $(echo_hex "#98BB6C")
	boatYellow1   $(echo_hex "#938056")
	boatYellow2   $(echo_hex "#C0A36E")
	carpYellow    $(echo_hex "#E6C384")
	sakuraPink    $(echo_hex "#D27E99")
	waveRed       $(echo_hex "#E46876")
	peachRed      $(echo_hex "#FF5D62")
	surimiOrange  $(echo_hex "#FFA066")
	katanaGray    $(echo_hex "#717C7C")
)
