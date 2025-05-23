# Monitoring System

> DevOps internship task

## Introduction

This pet project contain 3 SFTP servers, which communicate each other by log files(for example SFTP-server-1 send logs to SFTP-server-2,3) and send logs to python-Flask application endpoint, finally application put logs to MongoDB and operate, visualize logs and statistic.

## Getting Started

### Prerequisites

> Deploy with Vagrant:
- Python 3.12+
- Vagrant
- Oracle VirtualBox
- MongoDB(Local or Docker)
- Git(optional)

> Deploy with Docker:
- Docker
- Vagrant

### Environment variables setup and IP setting

Create environment variable VM_COUNT. [Windows](https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_environment_variables?view=powershell-7.5) | [Linux](https://www.freecodecamp.org/news/how-to-set-an-environment-variable-in-linux/)

VM_COUNT:
  determine virtual machines count for deploying.  

IP ADRESSESS:
   you can setup your own ip addresses by doing changes in /Keys/peers.conf file. But commented line should be commented, in script from this line parse by grep URL to python app. Also, if you change python URL, you need to write this URL to app/.env file.

# Deploying with Vagrant
### Creating local repository 

    $ git clone https://github.com/Andriy29k/Milestone_1.git
    
### Creating SSH keys directory 

    1. Go to `Task-2`.
    2. Create `Keys` directory.
    3. In `Keys` directory put your SSH key named `private-key` and public SSH key named `authorized_keys`.
    4. Create Peers.conf with next template context:
        192.168.33.10
        192.168.33.10
        192.168.33.10
        #HOST_API=http://192.168.0.104:5000
    5. Change these parameters and save file.

### Python application deploy

   Windows
    
     $ python -m venv .venv
    
    CMD 
     $ .venv\Scripts\activate
     $ pip install -r requirements.txt
     $ python app.py
    
    PowerShell
     $ .\.venv\Scripts\Activate.ps1
     $ pip install -r requirements.txt
     $ python app.py
      
   Linux

    $ sudo apt install python3-venv
    $ python3 -m venv .venv
    $ source .venv/bin/activate
    $ pip install -r requirements.txt

# Deploying with Docker
### Creating local repository

    $ git clone https://github.com/Andriy29k/Milestone_1.git

### Creating SSH keys directory 

    1. Go to `Task-2`.
    2. Create `Keys` directory.
    3. In `Keys` directory put your SSH key named `private-key` and public SSH key named `authorized_keys`.
    4. Create Peers.conf with next template context:
        192.168.33.10
        192.168.33.10
        192.168.33.10
        #HOST_API=http://192.168.0.104:5000
    5. Change these parameters and save file(!!!Important change `HOST_API` ip to your host IP).
    
### Python application deploy
In terminal execute:
     
     $ docker-compose up -d --build

### Vagrant infrastructure deploy
In terminal execute:

     $ cd Task2
     $ vagrant up

### Usage

   Go to application URL in browser. You should see main page with 6 buttons, which can redirect us to another routes.
   
    "URL:PORT/upload" - you can not see this route, because it is endpoint that receive logs and put to db.
    -------------------------------------------------------------------------------------------------------
    "URL:PORT/logs" - it is a list of all logs, it prefer for small debuging.
    -------------------------------------------------------------------------------------------------------
    "URL:PORT/stats" - stats of sended logs by VM's.
    -------------------------------------------------------------------------------------------------------
    "URL:PORT/latest" - displays latest log received from someone VM.
    -------------------------------------------------------------------------------------------------------
    "URL:PORT/debug-log" - endpoint to receive log fro VM. This a log of script executions.
    -------------------------------------------------------------------------------------------------------
    "URL:PORT/debug-view" - script execution log output.
    -------------------------------------------------------------------------------------------------------
    "URL:PORT/graph" - contain graphs based on logs statistic.

## License

This software is licensed under the [GNU General Public License, version 3](
./LICENSE).