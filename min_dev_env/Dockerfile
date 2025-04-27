FROM debian:bookworm

# Update the package lists and install necessary packages
RUN apt update -y && \
    apt install -y \
    software-properties-common \
    build-essential \
    git \
    wget \
    curl \
    unzip \
    tree \
    sqlite3 \
    libsqlite3-dev    

# installing micro editor
RUN curl https://getmic.ro | bash && \
	mv ./micro /usr/local/bin

RUN cd /root && \
	git clone --recurse-submodules https://github.com/BenSiv/configs.git && \
    git clone --recurse-submodules https://github.com/BenSiv/lua-utils.git && \
    git clone --recurse-submodules https://github.com/BenSiv/lua-automations.git && \
    git clone --recurse-submodules https://github.com/BenSiv/brain-ex.git

ARG LUA_VERSION
ARG LUAROCKS_VERSION
# Install lua
RUN apt-get update -y && \
    apt-get install -y \
    lua${LUA_VERSION} \
    liblua${LUA_VERSION}-dev

RUN wget https://luarocks.org/releases/luarocks-${LUAROCKS_VERSION}.tar.gz -P /tmp && \
    tar zxpf /tmp/luarocks-${LUAROCKS_VERSION}.tar.gz -C /tmp && \
    cd /tmp/luarocks-${LUAROCKS_VERSION} && \
    ./configure && \
    make && \
    make install

RUN luarocks install luafilesystem

RUN apt clean && \
    rm -rf /var/lib/apt/lists/*

# Copy the entrypoint script into the container
COPY entrypoint.sh /entrypoint.sh

# Make the entrypoint script executable
RUN chmod +x /entrypoint.sh

# Set the working directory to /root
WORKDIR /root

# Set the entry point for the container
ENTRYPOINT ["/entrypoint.sh"]
