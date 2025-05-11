# Monitoring System

> DevOps internship task

## Introduction

This pet project contain 3 SFTP servers, which communicate each other by log files(for example SFTP-server-1 send logs to SFTP-server-2,3) and send logs to python-Flask application endpoint, finally application put logs to MongoDB and operate, visualize logs and statistic.

## Getting Started

### Prerequisites

- Python >= 3.9
- Vagrant

### Environment variables setup and IP setting

Create environment variable VM_COUNT. [Windows](https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_environment_variables?view=powershell-7.5) | [Linux](https://www.freecodecamp.org/news/how-to-set-an-environment-variable-in-linux/)

VM_COUNT
 :determine virtual machines count for deploying.  

IP ADRESSESS
 :you can setup your own ip addresses by doing changes in /Keys/peers.conf file. But commented line should be commented, in script from this line parse by grep URL to python app. Also, if you change python URL, you need to write this URL to app/.env file.

### Deploying infrastructure

    $ git clone https://github.com/Andriy29k/Milestone_1.git
    $ cd Task2
    $ vagrant up
    
### Python application deploy

   Windows
    
     $ python -m venv /path/to/python/application/app/
    
    CMD 
     $ venv\Scripts\activate.bat
     $ pip install -r requirements.txt
     $ & path/to/venv/.venv/Scripts/python.exe path/to/app/app.py
    
    PowerShell
     $ venv\Scripts\Activate.ps1
     $ pip install -r requirements.txt
     $ & path/to/venv/.venv/Scripts/python.exe path/to/app/app.py
      
   Linux

    $ sudo apt install python3-venv
    $ python3 -m venv venv
    $ source venv/bin/activate
    $ venv

### Usage

   Go to application URL in browser. You should see main page with 6 buttons, which can redirect us to another routes.
   
    "URL:PORT/upload" - you can not see this route, because it is endpoint that receive logs and put to db.
    ---------------------------------------------------------------------------------------------
    "URL:PORT/logs" - it is a list of all logs, it prefer for small debuging.
    ---------------------------------------------------------------------------------------------
    "URL:PORT/stats" - stats of sended logs by VM's.
    ---------------------------------------------------------------------------------------------
    "URL:PORT/latest" - displays latest log received from someone VM.
    ---------------------------------------------------------------------------------------------
    "URL:PORT/debug-log" - endpoint to receive log fro VM. This a log of script executions.
    ---------------------------------------------------------------------------------------------
    "URL:PORT/debug-view" - script execution log output.
    ---------------------------------------------------------------------------------------------
    "URL:PORT/graph" - contain graphs based on logs statistic.

## License

This software is licensed under the [GNU General Public License, version 3](
./LICENSE).