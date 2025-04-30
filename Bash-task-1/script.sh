#!/bin/bash

# А–Я
# а–я
# 0–9
# !@#$%^&*()_+=-{}[]:;,.?
PASS_REGEX='^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[!@#$%^&*()_+=\-{}\[\]:;,.?]).{12,}$'
FILE_PATH=/logs/softaculous.log
#cat $FILE_PATH

cat $FILE_PATH | while read -r line; do
    grep -E "softdbpass|admin_pass"

done 
