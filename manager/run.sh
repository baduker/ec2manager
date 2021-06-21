#!/usr/bin/env bash

set -uef -o pipefail

OPTION="$1"

usage() {
    echo "Use this script to manage an EC2 instance state. The script has
    the following commands:
  - ${START_EC2} - Starts the EC2.
  - ${STOP_EC2} - Stops the EC2.
  - ${RESTART_EC2} - Restarts the EC2.
  - ${CHECK_STATUS} - Checks the EC2 status: can be either running or stopped.

Usage:
    docker run --env-file PATH_TO_ENV_FILE -it ec2-manager OPTION
    --start-ec2
      Start an EC2, if it's not already running.
    --stop-ec2
      Stop an EC2, if it's not already stopped.
    --restart-ec2
      Restart an EC2.
    --check-status
      Check the current status of an EC2. Can be either running or stopped.
" >&2
    exit 1
}

start_ec2() {
  status=$(
    aws --region "${REGION}" ec2 start-instances --instance-ids "${INSTANCE_ID}" \
    | jq .StartingInstances[].CurrentState.Name | tr -d '"'
  )
    if [ "$status" == "running" ]; then
        echo "The EC2 $INSTANCE_ID is already running."
        exit 1
    else
        echo "The EC2 ${INSTANCE_ID} is $status." \
        && echo "Waiting for the EC2 ${INSTANCE_ID} to start." \
        && aws --region "${REGION}" ec2 wait instance-running \
        --instance-ids "${INSTANCE_ID}" \
        && check_status
    fi
}

prompt_for_change() {
  read -rp "$1 [y/N] " confirm \
   && [[ $confirm == [yY] || $confirm == [yY][eE][sS] ]] || exit 1
}

stop_ec2() {
  status=$(
  aws --region "${REGION}" ec2 stop-instances --instance-ids "${INSTANCE_ID}" \
  | jq .StoppingInstances[].PreviousState.Name | tr -d '"'
  )
    if [ "$status" == "running" ]; then
      echo "The EC2 $INSTANCE_ID is running."
      prompt_for_change "Are you sure you want to stop it?"
      if [ "$confirm" ]; then
        echo "The EC2 ${INSTANCE_ID} was $status." \
        && echo "Waiting for the EC2 ${INSTANCE_ID} to stop." \
        && aws --region "${REGION}" ec2 wait instance-stopped \
        --instance-ids "${INSTANCE_ID}" \
        && echo "The EC2 ${INSTANCE_ID} is stopped."
      fi
    else
      echo "The EC2 $INSTANCE_ID is already stopped."
      prompt_for_change "Would you like to start it?"
      if [ "$confirm" ]; then
          start_ec2
      fi
    fi
}

restart_ec2() {
  stop_ec2
  start_ec2
}

check_status() {
  status=$(
    aws --region "${REGION}" ec2 describe-instance-status \
    --instance-id "${INSTANCE_ID}" \
    | jq .InstanceStatuses[].InstanceState.Name | tr -d '"'
  )
    if [ "$status" == "" ]; then
        echo "The EC2 ${INSTANCE_ID} is stopped."
        prompt_for_change "Would you like to start it?"
        if [ "$confirm" ]; then
          start_ec2
        fi
    else
     echo "The EC2 ${INSTANCE_ID} is $status."
    fi
}

case "$OPTION" in
  --start-ec2)
    start_ec2
    ;;
  --stop-ec2)
    stop_ec2
    ;;
  --restart-ec2)
    restart_ec2
    ;;
  --check-status)
    check_status
    ;;
  *)
    usage
    ;;
esac