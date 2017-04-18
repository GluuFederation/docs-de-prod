# Getting Started

This document will show you how to get up and running with the Gluu Cluster Server. It is broken down into the following sections:

[TOC]

## Overview

The Gluu Cluster is divided into various components; cluster API, discovery, master, and worker.
The cluster API is independent to function, but discovery, master, and worker are dependent to each other.
The deployment section will cover some basics of installation; for a detailed installation guide please see the [Installation Doc](../installation/)

## Preparing VM
Cluster installation requires some ports to be accessible by the services and components required.

### External Ports
External ports can alse be called 'internet-facing' ports that are open to the world or internet.


|	Port Protocol	|	Port Number	|	Service		|
|-----------------------|-----------------------|-----------------------|
|	TCP		|	80		|	Web Frontend	|
|	TCP		|	443		|	Web Frontend	|


*Note:* These ports only need to be open when you are downloading new packages. Most often your upgrade process will be tightly controlled, so you can plan for these changes and re-open the ports as needed.

### Internal Ports
Internal ports are the specific port requirements for the different components of the Cluster setup.


|	Port Protocol	|	Port Number	|	Service		            |
|-------------------|---------------|---------------------------|
|	TCP		        |	8800		|	gluu-cluster-webui	    |
|	TCP		        |	8080		|	gluu-engine             |
|	TCP		        |	2376		|	Docker Daemon	        |
|	TCP		        |	3376		|	Docker Swarm Daemon	    |
|	TCP		        |	8443		|	oxTrust GUI	            |
|	TCP		        |	8500		|	Consul	                |
|	TCP & UDP	    |	6783		|	Weave		            |
|	TCP & UDP	    |	53		    |	Weave DNS(Amazon AWS)	|

Notes:

* Port 8080 and 8800 needed by control machine.
* Port 8443 needed by master node (VM).
* Port 8500 needed by discovery node (VM).


## Deployment

[TBA]
