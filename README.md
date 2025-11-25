
### This project provides a fully automated multi-machine development environment using Vagrant and VirtualBox, provisioning a complete backend ecosystem that includes:

- Nginx – Web Server

- Tomcat – Application Server

- MariaDB/MySQL – Database

- Memcached – Caching Layer

- RabbitMQ – Message Broker

### All components are deployed automatically through shell provisioning scripts, ensuring a consistent and reproducible environment for development or testing.

## 📦 Project Structure


.
├── Vagrantfile
├── nginx.sh
├── tomcat.sh
├── mysql.sh
├── memcache.sh
└── rabbitmq.sh



 Each script is responsible for installing, configuring, and enabling its respective service.

## ⚙ Requirements

Make sure the following tools are installed:

- Vagrant ≥ 2.2

- VirtualBox ≥ 6.x

- javajdk v11

- tomcat v9

- A stable internet connection during provisioning

## ▶ Getting Started

### ⿡ Clone the Repository

git clone https://github.com/moaaz-abdelkarim/-automation-multi-tier-app-

cd automation-multi-tier-app



### ⿢ Launch the Environment

vagrant up


#### Vagrant will automatically:
✔ Create all virtual machines

✔ Run the provisioning scripts

✔ Install all required services

✔ Configure and start each service

### ⿣ Access a Machine

vagrant ssh <vm-name>


## 🔧 Useful Commands

### Restart a machine:

vagrant reload <vm>

### Force re-provisioning:

vagrant up --provision

### Shut down all VMs:

vagrant halt

### Destroy the environment:

vagrant destroy -f

## 📝 Provisioning Script Overview

#### nginx.sh

- Installs Nginx

- Applies basic configuration

- Restarts & enables service

#### tomcat.sh
- Installs Java

- Downloads & deploys Tomcat

- Configures permissions & service

#### mysql.sh
- Installs MariaDB

- Runs secure installation steps

- Enables DB service

#### memcache.sh

- Installs Memcached

- Configures memory and connections

- Starts and enables service

#### rabbitmq.sh
- Installs Erlang & RabbitMQ

- Enables management interface

- Starts broker service

## 🧱 Architecture Overview
This environment follows a modular, layered approach:

                 ┌──────────────┐
                 │    Nginx     │
                 └──────┬───────┘
                        │
                 ┌──────┴───────┐
                 │   Tomcat     │
                 └──────┬───────┘
            ┌───────────┼───────────┐
            │           │           │
   ┌────────┴───┐ ┌─────┴────┐ ┌────┴─────┐
   │   MySQL    │ │ Memcached │ │ RabbitMQ │
   └────────────┘ └───────────┘ └──────────┘

