# VS Code Server Proxy

This is a reverse proxy for [Visual Studio Code Server](https://code.visualstudio.com/blogs/2022/07/07/vscode-server). This provides a login form and ssl termination (https) for Visual Studio Code Server running locally.

## Run (on server)
1. Install Docker
2. Copy the [.env-sample](./.env-sample) to [.env](./.env) and make desired changes
3. Execute `./generate-certs.sh`
4. Execute `./run.sh`
5. Navigate to `https://{your-ip}:4443`

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

## Install certificate

1. Install the [windows-trusted-ca.crt](./cert/windows-trusted-ca.crt) in your Windows 'Local Machine'

## How It Works

- Your VS Code Server runs on `http://127.0.0.1:8000`
- Nginx reverse proxy runs on `https://0.0.0.0:4443`
- Users are presented with a simple login page
- After successful login, a secure cookie is set for 24 hours
- All subsequent requests are proxied to the VS Code Server backend
