RMDATE=`date --date '4 day ago' +%Y%m%d`
echo $RMDATE
rm -rf /data1/$RMDATE

if [[ ! -e /data1/$RMDATE ]]; then
  echo "OK:"$RMDATE
fi
