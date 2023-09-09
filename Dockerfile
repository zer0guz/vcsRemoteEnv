# Use an official Ubuntu as a parent image
FROM ubuntu:latest

# Set the maintainer label
LABEL maintainer="zer0guz"

ENV DEBIAN_FRONTEND=non-interactive \
    TERM=xterm-256color \
    PATH=$PATH:/opt/ghidra_*/bin

# Install the foundational or larger tools
RUN apt-get update && \
    apt-get install -y xorg openjdk-17-jdk dbus-x11 python3 openssh-client python3-pip gdb && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Install the smaller, more frequently modified tools
RUN apt-get update && \
    apt-get install -y wget curl git tmux unzip jq zsh xclip && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*


# Download and install Ghidra from the latest release on GitHub
WORKDIR /opt
RUN LATEST_RELEASE_URL="https://api.github.com/repos/NationalSecurityAgency/ghidra/releases/latest" && \
    GHIDRA_ZIP_URL=$(wget -O- -q $LATEST_RELEASE_URL | jq -r ".assets[] | select(.name | test(\".zip\")) | .browser_download_url") && \
    wget "$GHIDRA_ZIP_URL" -O ghidra.zip && \
    unzip ghidra.zip && \
    rm ghidra.zip

RUN pip3 install pwntools


RUN wget -q -O- https://github.com/hugsy/gef/raw/master/scripts/gef.sh | sh && \
    chsh -s $(which zsh)

# Install oh-my-zsh
RUN sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)" "" --unattended



# SSH tasks: Add github.com to known hosts and clone a repository
RUN --mount=type=ssh ssh-keyscan github.com > /etc/ssh/ssh_known_hosts && \
    git clone --depth=1 'git@github.com:zer0guz/ctf.git'

# Run zsh when the container launches
CMD ["/bin/zsh"]

#docker run -it -e DISPLAY=:0 -v /tmp/.X11-unix:/tmp/.X11-unix ubuntu-desktop
#eval $(ssh-agent -s) && ssh-add && set "DOCKER_BUILDKIT=1" && docker build -t 'ubuntu-desktop' --ssh default .