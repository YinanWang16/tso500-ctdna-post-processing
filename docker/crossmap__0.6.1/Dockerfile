############################################################
# Dockerfile to build Genotype imputation
# Based on Ubuntu 20.04
############################################################

# Set the base image to Ubuntu
FROM ubuntu:20.04

# File Author / Maintainer
LABEL maintenair="Yinan Wang ywang16@illumina.com"

ENV LANG=C.UTF-8 LC_ALL=C.UTF-8

################## BEGIN INSTALLATION ######################

# Install wget
RUN apt-get update &&  \
  apt-get install -y python3.8 python3-pip && \
  apt-get clean && \
  rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN pip3 install CrossMap

RUN useradd --create-home --shell /bin/bash ubuntu && \
  chown -R ubuntu:ubuntu /home/ubuntu

USER ubuntu
