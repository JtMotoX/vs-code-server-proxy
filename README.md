# VS Code Server Proxy

This is a reverse proxy for [Visual Studio Code Server](https://code.visualstudio.com/blogs/2022/07/07/vscode-server). This provides a login form and ssl termination (https) for Visual Studio Code Server running locally.

## Run
1. Install Docker
1. Generate an SSL cert and place in the [cert](cert) directory as `server.crt` and `server.key`
1. Create a file called [.connection-token](.connection-token) and save your password in that file
1. Execute `./run.sh`
1. Navigate to `https://{your-ip}:4443` (*the port can be set in the [docker-compose.yml](docker-compose.yml) and [nginx.conf](nginx.conf) files*)

## Install background service to launch at boot (macOS)
1. Execute the `./run.sh` script first to make sure everything is working (see [Run](#run) section).
1. Open `Settings > Security & Privacy > Full Disk Acces` and add `/bin/sh`
1. Make a symbolic link: `ln -s $(pwd)/run.sh /usr/local/bin/vs-code-server`
1. Install the service: `./service.sh install`
2. Execute the `./run.sh` script to start the service.

## Install background service to launch at boot (Linux)
1. Execute the `./run.sh` script first to make sure everything is working (see [Run](#run) section).
1. Install the service: `./service.sh install`
2. Execute the `./run.sh` script to start the service.
