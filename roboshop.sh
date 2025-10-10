#!/bin/bash

AMI_ID="ami-09c813fb71547fc4f"
SG_ID="sg-020cf2e239d3ab3ae"

for instance in $@
do
    INSTANCE_ID=$(aws ec2 run-instances --image-id $AMI_ID --instance-type t3.micro --security-group-ids $SG_ID --tag-specifications 'ResourceType=instance,Tags=[{Key=Name,Value=Test}]' --query 'Instances[0].InstanceId' --output $instance)
    # this it will create the instance id
    
    # get private ip
    if [ $instance !="frontend" ]; then
       IP=$(aws ec2 describe-instances --instance-ids $INSTANCE_ID --query 'Reservations[0].Instances[0].PrivateIpAddress' --output $instance)
    else
       IP=(aws ec2 describe-instances --instance-ids $INSTANCE_ID --query 'Reservations[0].Instances[0].PublicIpAddress' --output $instance)
    fi
      echo "$instance:$IP"
done        