# Monitoring System

# How it is works...

1. Vagrant deploy **3 SFTP servers** with basic setups for SFTP and user management, and doing **RKhunter audit**. Then run **send-logs.sh** script, that generate and put file to neighbour's servers. This script runs every 5 minutes.
2. We run python script that deploy python application. Python app receive logs by **HTTP** on one of endpoint and put to **MongoDB**. From this moment we can operate, visualize and display data's in needed view.

## Setup

1. Open your terminal and paste next command:
```
git clone https://github.com/Andriy29k/Milestone_1.git
cd Task2
```
2. On this step need to configure **IP-addresses** and **Environment Variables**. **IP Adresses** located at: **"Keys/peers.conf"**, also in this file placed and commendet **URL to python app**. This **URL** must be commented, in script we give value by grep with regex. VM_COUNT
: It is variable that determine VM's count in infrasctructure. How add Environment Variable at Windows look this: [Environment Variables in Windows] (https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_environment_variables?view=powershell-7.5)

3. Paste next command: `Vagrant up`
4. Run python script via command:
```
.venv/Scripts/python.exe app/app.py
```
5. Go to **"localhost:(Your port or 5000(by default))"** and you will see main page.
