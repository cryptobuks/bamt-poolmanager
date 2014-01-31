bamt-poolmanager
================

Web based pool and miner manager for BAMT linux running CGminer.
Extended from the BAMT miner web interface, which is in perl (no php). 

Add or Remove pools, or Switch priority, without stopping your miner. 
Stop/start the miner, with password protection and run time display. 
Extra system stats in the header (uptime, load, free mem). 
Configuration editor.
Install script enables SSL redirection (and optional default page password) for security. 

Reqirements: BAMT linux running CGminer. Built and tested on litecoin-bamt 1.2, but should 
work with any flavor of BAMT, including SMOS. 

TO INSTALL: wget the repo zipfile to your miner and unzip it, then cd to the bamt-pm directory
and run the ./install-pm.sh  
Please see the README to complete the setup. 

See the Wiki for a screenshot
