#in sever
deco
cd /var/www/html/designing-case.com/dc_ver4/app/webroot/img/case_img/ && find . -name "*.png" | xargs ls -l| sed 's/[\t ]\+/\t/g' | cut -f5 > ~/test/output
exit
scp -p deco@133.242.171.30:~/test/output output


#!/bin/bash
temp=`cat output`
FIRST=0
SECOND=0
for i in $temp; do
    if [[ $i -gt $FIRST ]]; then
        FIRST=$i
    elif [[ $i -gt $SECOND ]]; then
        SECOND=$i
    fi
done

echo "FIRST: $FIRST"
echo "SECOND: $SECOND"
