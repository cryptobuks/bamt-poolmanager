bamt-poolmanager
================

Web based pool and miner manager for BAMT linux running CGminer.
Extended from the BAMT miner web interface, which is in perl (no php). 

- Add or Remove pools, or Switch priority, from the web GUI without stopping your miner. 
- Stop/start the miner, with password protection and version/run time display. 
- Extra stats in the header (Work Util, HW errors, Uptime, Load, Free Mem). 
- Refactored GPU stats on overview and details pages. 
- Configuration editor. 
- Farm Overview (mgpumon) is much improved with more information in less space. 
- Install script enables SSL redirection (and optional default page password) for security. 

See the wiki page for screenshots.

Reqirements: BAMT linux running cgminer/sgminer. 
API version detection should now prevent breakage on various miner build versions. 
Built and tested on litecoin-bamt 1.2, but should work with any flavor of BAMT, including SMOS. 

EASY PEASY SURE FIRE INSTALL INSTRUCTIONS: 

(Doing it this way ensures all the files will have the correct permissions.)

1. ssh into your miner, so you are at the command prompt. be root (if you are user, do: sudo su - ).
2. do: wget https://github.com/starlilyth/bamt-poolmanager/archive/master.zip
3. do: unzip master.zip
4. cd to 'bamt-poolmanager-master/bamt-pm' directory and run: ./install.sh
5. add an API line to your .conf. (please see the README). 

Absolutely NO hidden donate code! You can trust the IFMI brand to never include any kind of 
auto donate or hash theft code. 

BTC: 1JBovQ1D3P4YdBntbmsu6F1CuZJGw9gnV6

LTC: LdMJB36zEfTo7QLZyKDB55z9epgN78hhFb

Donate your hashpower directly at http://wafflepool.com/
