# FROM ubuntu:latest
# Initial
FROM nvidia/cuda:12.2.0-runtime-ubuntu20.04

# Update and install desktop environment and XRDP
# RUN apt update && \
#     DEBIAN_FRONTEND=noninteractive apt install -y openssh-client && \
#     DEBIAN_FRONTEND=noninteractive apt install -y lubuntu-desktop && \
#     apt install -y xrdp && \
#     adduser xrdp ssl-cert

# Create a user and add to sudo group
RUN useradd -m testuser && \
    echo "testuser:1234" | chpasswd && \
    usermod -aG sudo testuser

WORKDIR /root

ARG DEBIAN_FRONTEND=noninteractive 
ENV TZ=Asia/Shanghai

RUN apt-get update && apt-get install -y libxdo3 xvfb kde-plasma-desktop wget wmctrl openssh-client
RUN apt-get install curl gstreamer1.0-pipewire

# Instal matlab requirements
ADD ./matlab-deps.txt /root
RUN apt-get install -y $(cat /root/matlab-deps.txt)

# Install rustdesk
RUN curl -o rustdesk-x86_64.deb https://github.com/rustdesk/rustdesk/releases/download/1.4.0/rustdesk-1.4.0-x86_64.deb
# ADD ./rustdesk-1.4.0-x86_64.deb /root
RUN dpkg -i   ./rustdesk-x86_64.deb

# Install Vivado requirements
RUN apt-get install -y libtinfo5 libncurses5 gcc


# Expose port 3389
# EXPOSE 3389

# Start services
RUN cp -ra /home/testuser /dockeruser

COPY ./startup.sh /
RUN chmod +x /startup.sh

ENV NVIDIA_VISIBLE_DEVICES=all
ENV NVIDIA_DRIVER_CAPABILITIES=compute,video,utility

ENTRYPOINT /startup.sh
