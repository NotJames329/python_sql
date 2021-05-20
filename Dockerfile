# Use your desired python base image
FROM python:3.8.8

# Install oracle client
RUN apt-get update && apt-get install -y libaio1 wget unzip
WORKDIR /opt/oracle
RUN wget https://download.oracle.com/otn_software/linux/instantclient/instantclient-basiclite-linuxx64.zip && \
    unzip instantclient-basiclite-linuxx64.zip && rm -f instantclient-basiclite-linuxx64.zip && \
    cd /opt/oracle/instantclient* && rm -f *jdbc* *occi* *mysql* *README *jar uidrvci genezi adrci && \
    echo /opt/oracle/instantclient* > /etc/ld.so.conf.d/oracle-instantclient.conf && ldconfig

ENV PYTHONUNBUFFERED 1
ENV WORKON_HOME=~/.venvs

# Install mssql client
WORKDIR /opt/microsoft

RUN curl https://packages.microsoft.com/keys/microsoft.asc | apt-key add - && \
    curl https://packages.microsoft.com/config/debian/10/prod.list > /etc/apt/sources.list.d/mssql-release.list && \
    apt-get update && \
    ACCEPT_EULA=Y apt-get install -y msodbcsql17 && \
    ACCEPT_EULA=y apt-get install -y mssql-tools && \
    apt-get install -y unixodbc-dev -y

# Please Don't change it
WORKDIR /workspace

# Setup SSH with secure root login
# Please don't change it
RUN apt-get update \
 && apt-get install -y sudo openssh-server netcat \
 && mkdir /var/run/sshd \
 && echo 'root:password' | chpasswd \
 && sed -i 's/\#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config

# Installs pipenv and initializes the venv
# if you do not wish using pipenv just remove it
RUN apt-get install -y pipenv vim && \
    python -m venv /.venvs/venv

# Configures zsh
RUN sh -c "$(wget -O- https://github.com/deluan/zsh-in-docker/releases/download/v1.1.1/zsh-in-docker.sh)" -- \
    -t miloshadzic \
    -p git \
    -p safe-paste \
    -p https://github.com/zsh-users/zsh-autosuggestions \
    -p https://github.com/zsh-users/zsh-completions \
    -a "bindkey '^ ' autosuggest-accept" \
    -a "cd /workspace" && \
    echo "source /.venvs/venv/bin/activate" >> ~/.zshrc

EXPOSE 22
CMD ["/usr/sbin/sshd", "-D"]
