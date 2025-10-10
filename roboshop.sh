#!/bin/bash

# Define your AMI and Security Group ID
AMI_ID="ami-09c813fb71547fc4f"
SG_ID="sg-020cf2e239d3ab3ae"

# Loop over all arguments passed to the script
for instance in "$@"
do
    echo "Launching instance: $instance"
    
    # Launch EC2 instance and capture the instance ID
    INSTANCE_ID=$(aws ec2 run-instances \
        --image-id "$AMI_ID" \
        --instance-type t3.micro \
        --security-group-ids "$SG_ID" \
        --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=$instance}]" \
        --query 'Instances[0].InstanceId' \
        --output text)

    echo "Launched Instance ID: $INSTANCE_ID"

    # Wait for the instance to be in 'running' state
    echo "Waiting for instance to start..."
    aws ec2 wait instance-running --instance-ids "$INSTANCE_ID"

    # Get IP address (Private or Public based on instance name)
    if [ "$instance" != "frontend" ]; then
        IP=$(aws ec2 describe-instances \
            --instance-ids "$INSTANCE_ID" \
            --query 'Reservations[0].Instances[0].PrivateIpAddress' \
            --output text)
    else
        IP=$(aws ec2 describe-instances \
            --instance-ids "$INSTANCE_ID" \
            --query 'Reservations[0].Instances[0].PublicIpAddress' \
            --output text)
    fi

    # Output instance name and its IP
    echo "$instance: $IP"
done      