# docker build -t tmp_mybinder_demo .
# docker run -it tmp_mybinder_demo jupyter notebook --certfile=mycert.pem
FROM jupyter/scipy-notebook:cf6258237ff9

ARG NB_USER=jovyan
ARG NB_UID=1000
ENV USER ${NB_USER}
ENV NB_UID ${NB_UID}
ENV HOME /home/${NB_USER}
USER root
# RUN adduser --disabled-password \
#     --gecos "Default user" \
#     --uid ${NB_UID} \
#     ${NB_USER}
RUN apt update
RUN pip install --no-cache-dir notebook
RUN pip install --no-cache-dir jupyterhub

RUN apt update \
    && apt install -y tor openvpn

RUN DEBIAN_FRONTEND=noninteractive && apt update && apt install -y --no-install-recommends \
    apt-transport-https \
    tor \
    gnupg2 \
    pass \
    sudo \
    curl \
    wget \
    ssh \
    iptables \
    dnsutils \
    net-tools \
    tree \
    rsync \
    sqlite3 \
    socat \
    openvpn \
    git \
    inetutils-ping \
    traceroute \
    dnsmasq \
    firejail \
    busybox \
    unzip \
    python3-venv \
    gcc \
    g++ \
    make \
    htop \
    nano \
    ncdu \
    rsyslog \
    && apt-get autoremove -y && apt-get clean -y && rm -rf /var/lib/apt/lists/*


RUN pip install jupyterlab
RUN curl -fOL https://github.com/cdr/code-server/releases/download/v3.8.0/code-server_3.8.0_amd64.deb
RUN dpkg -i code-server_3.8.0_amd64.deb && rm -f code-server_3.8.0_amd64.deb
RUN curl -fsSL https://deb.nodesource.com/setup_16.x | bash - \
    && apt update \
    &&apt-get install -y nodejs 
    # # Install npm , yarn, nvm
    # && npm install -g npm \
    # && rm -rf /opt/yarn-* /usr/local/bin/yarn /usr/local/bin/yarnpkg \
    # && curl -sL https://dl.yarnpkg.com/debian/pubkey.gpg | gpg --dearmor | tee /usr/share/keyrings/yarnkey.gpg >/dev/null \
    # && echo "deb [signed-by=/usr/share/keyrings/yarnkey.gpg] https://dl.yarnpkg.com/debian stable main" | tee /etc/apt/sources.list.d/yarn.list \
    # && apt-get update -q \
    # && apt-get -q install yarn \
    # && apt-get autoremove -y && apt-get clean -y && rm -rf /var/lib/apt/lists/*

ARG SSH_PUB_KEY="ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAGMNAX3JP/dWmythbYAZ3sWfnT6pTME6c6+SR5Zm5Ex"
RUN mkdir ~/.ssh -m 700 \
    && touch ~/.ssh/authorized_keys \
    && chmod 700 ~/.ssh/authorized_keys \
    && echo ${SSH_PUB_KEY} > ~/.ssh/authorized_keys \
    # git hub
    && ssh-keyscan github.com >> ~/.ssh/known_hosts \
    && git config --global user.name a  \
    && git config --global user.email a@a.a \
    && git config --global core.autocrlf input
# Make sure the contents of our repo are in ${HOME}
COPY . ${HOME}
RUN chown -R ${NB_UID} ${HOME}


COPY . ${HOME}
WORKDIR ${HOME}
RUN chmod +x ${HOME}/entry



USER ${NB_USER}


CMD ["/bin/sh","-c","#(nop) ", "USER [jovyan]"]
ENTRYPOINT ["tini","--"]
# ENTRYPOINT ["touch","~/1.txt","&""tini","--"]



# It must accept command arguments. The Dockerfile will effectively be launched as:
# docker run <image> jupyter notebook <arguments from the mybinder launcher>
# where {}<arguments ...> includes important information automatically set by the binder environment, such as the port and token.

# If your Dockerfile sets or inherits the Docker {}ENTRYPOINT instruction, the program specified as the {}ENTRYPOINT must {}exec the arguments passed by docker. Inherited Dockerfiles may unset the entrypoint with {}ENTRYPOINT [].

#For more information, and a shell wrapper example, please see the Dockerfile best practices: ENTRYPOINT documentation.