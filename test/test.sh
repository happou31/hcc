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

    echo -n "[$test_count] "
    if [ "$actual" = "$expected" ]; then
        echo -e "$(green "[OK]") $input => $actual"

    else
        echo -e "$(red "[NG]") $input => $actual (expected $expected)"
        mv ./tmp.s ./${test_count}_tmp.s
        failed_count=$((failed_count + 1))
        return 1
    fi
}

try 0 '0;'
try 42 '42;'
try 24 '12+14-2;'
try 10 '5 + 4 + 3 - 2;'
try 20 '(1 + 4) * 4;'
try 3 '3 * 3 / 3;'
try 0 '0 / 1;'
try 100 '1 + 1 + 1 + 1 + 1 + 1 + 1 + 1 + 1 + 1 + 1 + 1 + 1 + 1 + 1 + 1 + 1 + 1 + 1 + 1 + 1 + 1 + 1 + 1 + 1 + 1 + 1 + 1 + 1 + 1 + 1 + 1 + 1 + 1 + 1 + 1 + 1 + 1 + 1 + 1 + 1 + 1 + 1 + 1 + 1 + 1 + 1 + 1 + 1 + 1 + 1 + 1 + 1 + 1 + 1 + 1 + 1 + 1 + 1 + 1 + 1 + 1 + 1 + 1 + 1 + 1 + 1 + 1 + 1 + 1 + 1 + 1 + 1 + 1 + 1 + 1 + 1 + 1 + 1 + 1 + 1 + 1 + 1 + 1 + 1 + 1 + 1 + 1 + 1 + 1 + 1 + 1 + 1 + 1 + 1 + 1 + 1 + 1 + 1 + 1;'
try 12 'a=6+6; return a;'
try 10 'a = 5; b = a + 5; return b;'
try 20 'hoge = 10; fuga = hoge + 10; return fuga;'
try 20 'a = 1; b = 1; c = a + b; c = c * 10; return c;'
try 5 'return 15 % 10;'
try 5 'return 5 % 10;'
try 10 'return -15 + (+25);'
try 0 'a = -5; b = 5; return a + b;'
try 1 'return 5 == 5;'
try 0 'return 4 == 3;'
try 1 'return 10 != 0;'
try 0 'return 20 != 20;'
try 1 'return 5 >= 4;'
try 0 'return 5 >= 6;'
try 1 'return 4 <= 5;'
try 0 'return 5 <= 4;'
try 1 'return 5 > 4;'
try 0 'return 5 > 5;'
try 1 'return 4 < 5;'
try 0 'return 5 < 4;'
try 1 'a = 10; b = 10; return a == b;'
try 1 'a = 10; b = 20; return a != b;'
try 1 'a = 30; b = 20; return a >= b;'
try 1 'a = 10; b = 20; return a <= b;'
try 42 'if (0) return 1; return 42;'
try 42 'if (0) return 0; else return 42;'
try 42 'if (0) return 0; else return 42; return 1919;'
try 42 'hoge = 10; fuga = 20; if (hoge > fuga) return 0; else return 42;'
try 42 'n = 0; while (n < 42) n = n + 1; return n;'
try 0 'n = 42; while (n > 0) n = n - 1; return n;'
try 45 'result = 0; for (n = 0; n < 10; n = n + 1) result = result + n; return result;'
try 120 '(((((((((((((((1 + 2) + 3) + 4) + 5) + 6) + 7) + 8) + 9) + 10) + 11) + 12) + 13) + 14) + 15));'
try 10 'super_long_var_name_wwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwww = 10; return super_long_var_name_wwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwww;'
try 10 'x = 0; if(x == 0) { y = x + 10; return y; } else { return x; }'
try 20 'x = 1; y = 0; if (x == 0) { y = 10; } else { y = 20; } return y;'

echo ---------------------------------------------------------------------

if [ "$failed_count" -lt 1 ]; then
    echo -e "$(green '[SUCCESS]') [$test_count/$test_count] tests are passed."
    exit 0
else
    echo -e "$(red '[FAILURE]') [$failed_count/$test_count] tests are failed."
    exit 1
fi
