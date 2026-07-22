MY_IP=$(curl -s https://checkip.amazonaws.com)
echo "Current IP: $MY_IP"

# Update security group rule
aws ec2 authorize-security-group-ingress \
  --group-id sg-0b980db1fd506745b \
  --protocol tcp \
  --port 5432 \
  --cidr "${MY_IP}/32" \
  --region eu-west-1