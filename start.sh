set -x

export AWS_DEFAULT_REGION=ap-southeast-1
export queue_example=example
export queue_inbound=inbound
export scheduler_tbl=dynein_schedules

count_queue() {
  aws sqs list-queues --queue-name $1 --query 'length(QueueUrls)' --region ${AWS_DEFAULT_REGION}
}

cnt_example=$(count_queue ${queue_example})
if [ ${cnt_example} -eq 0 ] ; then
  aws sqs create-queue --queue-name ${queue_example} --region ${AWS_DEFAULT_REGION}
else
  echo "[INFO] Queue ${queue_example} ALRD exists!!!"
fi

cnt_inbound=$(count_queue ${queue_inbound})
if [ ${cnt_inbound} -eq 0 ] ; then
  aws sqs create-queue --queue-name ${queue_inbound} --region ${AWS_DEFAULT_REGION}
else
  echo "[INFO] Queue ${queue_inbound} ALRD exists!!!"
fi

dynamotbl_cnt=$(aws dynamodb list-tables --query 'TableNames' --region ${AWS_DEFAULT_REGION} | grep ${scheduler_tbl} | wc -l)
if [ ${dynamotbl_cnt} -eq 0 ] ; then
  aws dynamodb create-table --table-name ${scheduler_tbl} \
    --attribute-definitions AttributeName=shard_id,AttributeType=S AttributeName=date_token,AttributeType=S \
    --key-schema AttributeName=shard_id,KeyType=HASH AttributeName=date_token,KeyType=RANGE \
    --billing-mode PAY_PER_REQUEST --region ${AWS_DEFAULT_REGION}
else
  echo "[INFO] Scheduler Table ${scheduler_tbl} ALRD exists!!!"
fi

gradle run --args='server /home/gradle/scheduler/config.yml'