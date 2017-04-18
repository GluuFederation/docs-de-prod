# Components

The Gluu Cluster takes advantage of some of the latest and greatest free open source components to provide a hassle-free management of the cluster system. The following components make Gluu Cluster an easy solution for the enterprise.

## Gluu Engine

Gluu Engine is a [flask](http://flask.pocoo.org/) application that publishes API's and it is combined with the Crochet project. It is  also capable of handling asynchronous events.

# Gluu Cluster UI

Gluu Cluster UI is a Python application that can be used to manage the cluster through web-based User Interface.

## Docker

[Docker](https://www.docker.com/) is a container service "that can package an application and its dependencies in a virtual container that can run on any Linux server. This helps enable flexibility and portability on where the application can run, whether on premises, public cloud, private cloud, bare metal, etc."<cite>[1]</cite>
[1]:http://www.linux.com/news/enterprise/cloud-computing/731454-docker-a-shipping-container-for-linux-code

## Docker Machine

Docker Machine is a tool that lets you install Docker Engine on virtual hosts, and manage the hosts with docker-machine commands. Please visit the [Docker Machine](https://docs.docker.com/machine/) documentation for more details.

## Weave

Weave is used to connect the docker containers through a virtual network. Weave is chosen because it provides mobility in the creation of nodes as the container can be scattered across multiple hosts/cloud providers and yet the cluster will be functional. Please visit the [Weave Website](http://weave.works/) for more information.
