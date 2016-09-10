ADDRS="10.72.11.13 10.72 10.72.11.131"
SEP=""
for ADDR in ${ADDRS//,/ }; do
if expr "$ADDR" : '^[0-9][0-9]*\.[0-9][0-9]*\.[0-9][0-9]*\.[0-9][0-9]*$' >/dev/null; then
QCOMM+="$SEP$ADDR"
else
QCOMM+="$SEP$(host -t A "$ADDR" | awk '{ print $4 }' | paste -sd ",")"
fi
SEP=,
done
echo "Starting node, connecting to qcomm://$QCOMM"