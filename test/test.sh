#!/bin/bash

color_reset="\x1b[0m"
color_green="\x1b[32m"
color_red="\x1b[31m"

test_count=0
failed_count=0

green() {
    echo -e "${color_green}$1${color_reset}"
}

red() {
    echo -e "${color_red}$1${color_reset}"
}

try() {
    expected="$1"
    input="$2"
    ./hcc "$input" > tmp.s
    gcc -o tmp tmp.s

    ./tmp
    actual="$?"

    test_count=$((test_count + 1))
    if [ "$actual" = "$expected" ]; then
        echo -e "$(green "[OK]") $input => $actual"

    else
        echo -e "$(red "[NG]") $expected expected, but got $actual"
        failed_count=$((failed_count + 1))
        return 1
    fi
}

try 0 0
try 42 42
try 24 '12+14-2'
try 10 '5 + 4 + 3 - 2'
try 20 '(1 + 4) * 4'
try 3 '3 * 3 / 3'
try 0 '0 / 1'

echo ---------------------------------------------------------------------

if [ "$failed_count" -lt 1 ]; then
    echo -e "$(green '[SUCCESS]') [$test_count/$test_count] tests are passed."
    exit 0
else
    echo -e "$(red '[FAILURE]') [$failed_count/$test_count] tests are failed."
    exit 1
fi