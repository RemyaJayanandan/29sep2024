#!/bin/bash

# Function to install AWS CLI
install_aws_cli() {
  echo "Installing AWS CLI..."
  curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
  unzip awscliv2.zip
  sudo ./aws/install
  aws --version
  echo "AWS CLI installed successfully."
}

# Function to configure AWS CLI
configure_aws() {
  echo "Configuring AWS CLI..."
  echo "Please enter your AWS Access Key:"
  read aws_access_key
  echo "Please enter your AWS Secret Key:"
  read aws_secret_key
  echo "Please enter your AWS Region (default: ap-south-1):"
  read aws_region

  aws configure set aws_access_key_id "$aws_access_key"
  aws configure set aws_secret_access_key "$aws_secret_key"
  aws configure set region "${aws_region:-ap-south-1}"
  echo "AWS CLI configured successfully."
}

# Function to install Terraform
install_terraform() {
  echo "Installing Terraform..."
  sudo apt-get update -y
  sudo apt-get install -y software-properties-common
  curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key add -
  sudo apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main"
  sudo apt-get update && sudo apt-get install -y terraform
  terraform --version
  echo "Terraform installed successfully."
}

# Function to run Terraform commands
run_terraform() {
  echo "Initializing Terraform..."
  terraform init

  echo "Applying Terraform configuration..."
  terraform apply -auto-approve
}

# Main script execution
echo "Starting setup..."

install_aws_cli
configure_aws
install_terraform
run_terraform

echo "Setup complete."
