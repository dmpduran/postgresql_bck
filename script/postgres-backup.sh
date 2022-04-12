#file-name: postgres-backup.sh
#!/bin/bash

cd /home/root
date1=$(date +%Y%m%d-%H%M)
mkdir pg-backup
PGPASSWORD="$PG_PASS" pg_dumpall -O -x -h postgresql-postgresql.devtroncd -p 5432 -U postgres -U postgres > pg-backup/postgres-db.tar
file_name="pg-backup-"$date1".tar.gz"

#Compressing backup file for upload
tar -zcvf $file_name pg-backup

notification_msg="Postgres-Backup-failed"
filesize=$(stat -c %s $file_name)
mfs=10
if [[ "$filesize" -gt "$mfs" ]]; then
# Uploading to s3
aws s3 cp pg-backup-$date1.tar.gz $S3_BUCKET
notification_msg="Postgres-Backup-was-successful"
fi

#Slack notification of successful / unsuccesful backup. 
#send_slack_notification()
# {
#payload='payload={"text": "'$1'"}'
#  cmd1= curl --silent --data-urlencode \
#    "$(printf "%s" $payload)" \
#    ${APP_SLACK_WEBHOOK} || true
#}
#send_slack_notification $notification_msg