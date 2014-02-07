bamt-poolmanager
================

Web based pool and miner manager for BAMT linux running CGminer.
Extended from the BAMT miner web interface, which is in perl (no php). 

Add or Remove pools, or Switch priority, without stopping your miner. 
Stop/start the miner, with password protection and run time display. 
Extra stats in the header (Work Util, HW errors, Uptime, Load, Free Mem). 
Configuration editor. Mgpumon enhancements.
Install script enables SSL redirection (and optional default page password) for security. 

Reqirements: BAMT linux running CGminer. Built and tested on litecoin-bamt 1.2, but should 
work with any flavor of BAMT, including SMOS. 


EASY PEASY SURE FIRE INSTALL INSTRUCTIONS: 
(Doing it this way ensures all the files will have the correct permissions.)
1. ssh into your miner, so you are at the command prompt. be root (if you are user, do: sudo su - ).
2 do: wget https://github.com/starlilyth/bamt-poolmanager/archive/master.zip
3 do: unzip master.zip
Now you can cd into the bamt-pm directory and run ./install.sh
Please see the README to complete the setup. 

See the Wiki for a screenshot.

Absolutely NO hidden donate code! You can trust the IFMI brand to never include any kind of 
auto donate or hash theft code. 

BTC: 1JBovQ1D3P4YdBntbmsu6F1CuZJGw9gnV6
LTC: LdMJB36zEfTo7QLZyKDB55z9epgN78hhFb

Donate your hashpower directly at http://wafflepool.com/
