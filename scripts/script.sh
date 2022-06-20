#!/bin/bash

KOPS_URL=https://github.com/kubernetes/kops/releases/download/v1.23.2/kops-linux-amd64
KUBECTL_URL=https://dl.k8s.io/release/v1.24.1/bin/linux/amd64/kubectl
AWS_CLI_URL=https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip
TERRAFORM_URL=https://releases.hashicorp.com/terraform/1.2.3/terraform_1.2.3_linux_amd64.zip
GRAALVM_URL=https://github.com/graalvm/graalvm-ce-builds/releases/download/vm-22.1.0/graalvm-ce-java17-linux-amd64-22.1.0.tar.gz
NATIVE_IMAGE_URL=https://github.com/graalvm/graalvm-ce-builds/releases/download/vm-22.1.0/native-image-installable-svm-java17-linux-amd64-22.1.0.jar

sudo yum -y update
sudo yum -y install git docker gcc glibc-devel zlib-devel libstdc++-static

# Install AWS CLI v2
curl $AWS_CLI_URL -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install
rm -rf aws
rm awscliv2.zip

# Setup Docker
sudo usermod -a -G docker ec2-user
sudo systemctl enable docker.service

# Install GraalVM, Native Image Installer and set JAVA_HOME
wget -O graalvm-java17.tar.gz $GRAALVM_URL
wget -O graalvm-native-image.jar $NATIVE_IMAGE_URL
GRAALVM_DIR=graalvm-ce-java17-22.1.0
sudo mkdir -p /usr/lib/jvm
sudo tar -xf graalvm-java17.tar.gz -C /usr/lib/jvm
sudo ln -s /usr/lib/jvm/$GRAALVM_DIR/bin/java /usr/bin/java
echo "export JAVA_HOME=/usr/lib/jvm/${GRAALVM_DIR}" | sudo tee /etc/profile.d/java.sh
echo "export GRAALVM_HOME=/usr/lib/jvm/${GRAALVM_DIR}" | sudo tee -a /etc/profile.d/java.sh
sudo /usr/lib/jvm/$GRAALVM_DIR/bin/gu -L install graalvm-native-image.jar
rm graalvm-java17.tar.gz
rm graalvm-native-image.jar

# Install Terraform CLI
curl $TERRAFORM_URL -o "terraformCLI.zip"
unzip terraformCLI.zip -d terraform-cli
sudo mv terraform-cli/terraform /usr/local/bin/
rm -rf terraform-cli
rm terraformCLI.zip

# Install KOPS
curl -Lo kops $KOPS_URL
chmod +x kops
sudo mv kops /usr/local/bin/kops

# Install kubectl - required for KOPS
curl -LO $KUBECTL_URL
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
rm kubectl