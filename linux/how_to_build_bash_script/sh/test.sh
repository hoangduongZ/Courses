#!/usr/bin/env bash

a=5
b=3
sum=$((a + b))
echo "The sum of $a and $b is $sum"
((a++))
echo "After incrementing, a is $a"

echo "--------------------"

FRUITS=("apple" "banana" "cherry")
for fruit in "${FRUITS[@]}"; do
    echo $fruit
done

echo "--------------------"

# Bash - While
count=1
while [ $count -le 5 ]; do
    echo $count
    ((count++))
done

# Until (ngược lại với while)
count=1
until [ $count -gt 5 ]; do
    echo $count
    ((count++))
done

echo "--------------------"

# Bash
declare -A capitals
capitals=(
    ["Vietnam"]="Hanoi"
    ["Japan"]="Tokyo"
    ["USA"]="Washington"
)

# Truy cập
echo ${capitals["Vietnam"]}  # Hanoi

# Lặp qua keys
for country in "${!capitals[@]}"; do
    echo "$country -> ${capitals[$country]}"
done

# Kiểm tra key tồn tại
if [[ -v capitals["Vietnam"] ]]; then
    echo "Vietnam exists"
fi

echo "--------------------"
# Bash - Gán output của command vào biến
DATE=$(date +%Y%m%d)
echo $DATE  # 20251126

FILES=$(ls *.md)
echo $FILES

# Dùng trong string
echo "Today is $(date +%A)"

# Cách cũ (backticks) - không khuyến nghị
DATE=`date +%Y%m%d`