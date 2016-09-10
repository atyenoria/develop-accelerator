slack_url=
[ $1 -eq 0 ] && curl -X POST --data-urlencode 'payload={"channel": "#provisioning", "username": "webhookbot", "text": "start", "icon_emoji": ":ghost:"}' $slack_url  && exit 0


[ $1 -eq 1 ] && curl -X POST --data-urlencode 'payload={"channel": "#provisioning", "username": "DEPLOY | END", "text": "end", "icon_emoji": ":ghost:"}' $slack_url && exit 0

[ $1 -eq 2 ] && curl -X POST --data-urlencode 'payload={"channel": "#provisioning", "username": "webhookbot", "text": "protractor start", "icon_emoji": ":ghost:"}' $slack_url && exit 0

