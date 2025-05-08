#!/bin/bash

# А–Я
# а–я
# 0–9
# !@#$%^&*()_+=-{}[]:;,.?
#PASS_REGEX='^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[!@#$%^&*()_+=\-{}\[\]:;,.?]).{12,}$'

FILE_PATH="/logs/softaculous.log"
if [[ ! -f "$FILE_PATH" ]]; then
    echo "File not found!"
    exit 1
fi

check_strength() {
    local pass="$1"
    COUNTER=0

    local issues=()

    [[ ! "$pass" =~ [a-z] ]] && issues+=("Not contain lowercase letters")
    [[ ! "$pass" =~ [A-Z] ]] && issues+=("Not contain uppercase letters")
    [[ ! "$pass" =~ [0-9] ]] && issues+=("Not contain digits")
    [[ ! "$pass" =~ [^[:alnum:]] ]] && issues+=("Not contain special characters")
    [[ ${#pass} -lt 12 ]] && issues+=("Less than 12 characters")

    weakness_check "$pass"

    if [[ ${#issues[@]} -gt 0 ]]; then
        for issue in "${issues[@]}"; do
            echo "$pass - $issue"
        done
    elif [[ "$COUNTER" -gt 0 ]]; then
        echo "$pass - Contain weak word"
    else
        echo "$pass - Strong password"
    fi
}

weakness_check() {
    local pass="$1"
    local pass_lc=$(echo "$pass" | tr '[:upper:]' '[:lower:]')
    weak_words=("password" "123456" "qwerty" "admin" "test")
    for word in "${weak_words[@]}"; do
        if [[ "$pass_lc" == *"$word"* ]]; then
            COUNTER=$((COUNTER + 1))
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
done
echo "}"

echo ""
echo "admin_pass passwords {"
echo "----------------------------------"
grep "admin_pass" "$FILE_PATH" | sed -n "s/.*admin_pass' => '\([^']*\)'.*/\1/p" | sort -u | while read -r pass; do
    check_strength "$pass"
echo "----------------------------------"
done
echo "}"

echo "-----------------------------------Services-----------------------------------"
echo "Started Services:"
grep "Finished Install" softaculous.log | sed 's/^.*Software Details :.*name => //;s/,.*$//'
echo "------------------------------------------------------------------------------"
echo "Finished Services:"
grep "Finished Remove" softaculous.log | sed 's/^.*Software Details :.*name => //;s/,.*$//'
echo "------------------------------------------------------------------------------"
