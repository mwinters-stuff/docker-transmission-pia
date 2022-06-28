#!/bin/bash
cd /scripts || exit 1
# Change this if you wish to log the verification
LOG_FILE=/downloads/torrent-end.log
export HOME=/scripts

# TR_TORRENT_ID=$1
# TR_TORRENT_NAME=$2
# TR_TORRENT_DIR=$3
touch $LOG_FILE
{ 
  echo "RUN: ${*}" 
  echo "TR_TORRENT_DIR=${TR_TORRENT_DIR}" 
  echo "TR_TORRENT_ID=${TR_TORRENT_ID}"
  echo "TR_TORRENT_NAME=${TR_TORRENT_NAME}"
} >> $LOG_FILE

function startTorrent {
  echo "Re-Starting ${TR_TORRENT_NAME}" >> $LOG_FILE
  transmission-remote -t "${TR_TORRENT_ID}" --start >> $LOG_FILE
}

function stopTorrent {
  echo "Stopping ${TR_TORRENT_NAME}" >> $LOG_FILE
  transmission-remote -t "${TR_TORRENT_ID}" --stop >> $LOG_FILE
}

function deleteTorrent {
  echo "Deleting ${TR_TORRENT_NAME}" >> $LOG_FILE
  transmission-remote -t "${TR_TORRENT_ID}" --remove-and-delete >> $LOG_FILE
}


echo "Processing ${TR_TORRENT_NAME}" >> $LOG_FILE

stopTorrent

find "${TR_TORRENT_DIR}" -name "*.nfo" -delete
find "${TR_TORRENT_DIR}" -name "*.txt" -delete
find "${TR_TORRENT_DIR}" -name "*.exe" -delete

TEMPLOG=/tmp/nmamer$$.log
ln -sf /scripts/mnamer.json ~/.mnamer-v2.json
echo "about to mnamer ${TR_TORRENT_DIR}/${TR_TORRENT_NAME}" >> $LOG_FILE

mnamer -b --verbose --no-style "${TR_TORRENT_DIR}/${TR_TORRENT_NAME}" > $TEMPLOG
tvrrv=$?
cat $TEMPLOG >>  $LOG_FILE
echo "RESULT $tvrrv" >> $LOG_FILE
if [ $tvrrv -eq 0 ]
then
  if grep -i "processed successfully" $TEMPLOG >> $LOG_FILE
  then
    echo "Rename Success  ${TR_TORRENT_DIR}" >> $LOG_FILE
    deleteTorrent
    /usr/bin/curl "https://xelp.winters.nz:32400/library/sections/1/refresh?X-Plex-Token=dqG18RQoR2FMWqUX2pTT" >> $LOG_FILE 2>&1 
    /usr/bin/curl "https://xelp.winters.nz:32400/library/sections/4/refresh?X-Plex-Token=dqG18RQoR2FMWqUX2pTT" >> $LOG_FILE 2>&1 
  else
    echo "Rename Failed" >> $LOG_FILE
    echo "RUN: ${*}" >> $LOG_FILE
  fi
else
  echo "Rename Failed ${tvrrv} ${TR_TORRENT_DIR}/${TR_TORRENT_NAME}" >> $LOG_FILE
fi

