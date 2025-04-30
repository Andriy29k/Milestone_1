#!/bin/bash

# А–Я
# а–я
# 0–9
# !@#$%^&*()_+=-{}[]:;,.?
PASS_REGEX='^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[!@#$%^&*()_+=\-{}\[\]:;,.?]).{12,}$'

FILE_PATH="/logs/softaculous.log"
if [[ ! -f "$FILE_PATH" ]]; then
    echo "File not found!"
    exit 1
fi

check_strength() {
    local pass="$1"
    
    if [[ ! "$pass" =~ [a-z] ]]; then
        echo "$pass - Not contain lowercase letters"
    elif [[ ! "$pass" =~ [A-Z] ]]; then
        echo "$pass - Not contain uppercase letters"
    elif [[ ! "$pass" =~ [0-9] ]]; then
        echo "$pass - Not contain digits"
    elif [[ ! "$pass" =~ [^[:alnum:]] ]]; then
        echo "$pass - Not contain special characters"
    elif [[ ${#pass} -lt 12 ]]; then
        echo "$pass - Less than 12 characters"
    else
        echo "$pass - Strong password"
    fi

    local pass_lc=$(echo "$pass" | tr '[:upper:]' '[:lower:]')

    weak_words=("password" "123456" "qwerty" "admin" "test")

    for word in "${weak_words[@]}"; do
        if [[ "$pass_lc" == *"$word"* ]]; then
            echo "$pass - Contain weak word - {$word}"
            return
        fi
    done

}

echo "softdbpass passwords {"
echo "----------------------------------"
grep -E "softdbpass" "$FILE_PATH" | sed -n "s/.*'softdbpass' => '\([^']*\)'.*/\1/p" | sort -u | while read -r pass; do
    check_strength "$pass"
echo "----------------------------------"
echo "}"
done

echo ""
echo "admin_pass passwords {"
echo "----------------------------------"
grep "admin_pass" "$FILE_PATH" | sed -n "s/.*admin_pass' => '\([^']*\)'.*/\1/p" | sort -u | while read -r pass; do
    check_strength "$pass"
echo "----------------------------------"
echo "}"
done

echo "-----------------------------------Services-----------------------------------"
echo "Started Services:"
grep "Finished Install" softaculous.log | sed 's/^.*Software Details :.*name => //;s/,.*$//'
echo "------------------------------------------------------------------------------"
echo "Finished Services:"
grep "Finished Remove" softaculous.log | sed 's/^.*Software Details :.*name => //;s/,.*$//'
echo "------------------------------------------------------------------------------"
