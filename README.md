# GSX_Elevate_Attack

# Background

1. Challenge : The OS of Coinforge server is quite old and 32 bit.  Agent of Caldera can not be deployed on it. (Re-compiling is also a problem as go-gang doesn’t run on 32 bit). It is also too old to instal MSFC framework on it.
2. Good Chance:  This old Metasploit server has been installed a samba3.0.20 that has an available vulnerability to be leveraged for establish C&C.

# Method 

1. Kali has MSFC and works well, so we may use Kali as the control server of attack, to leverage samba vulnerability to establish the command and control tunnel.
2. Coinforge will be the target controlled by Kali.

# Attack

Run 2 attacks as a service: 
	a. Upload the coin tokens to Kali to simulate data exfiltration (Tigger SNA alerts) (1,2)
	b. Interrupting coin flow, change ip and url for cfg.json to interrupt the communication and also receive post data as stealing data  (3,4,5) 

Notes:  Need a script to recovery the cfg.ison file in cron task.

# Files & Scripts

1. samba_exfil.rc  and coin_exfil.sh  are in /home/dcloud/coinbank on Kali linux (Attack-01), they run the msfc with samba vulnerability to establish C&C and upload coin tokens to Kali.
2. gather_coins.sh (on Coinforge) is for generating coin tokens
3.web/coinworm.html   coin worm for easter eggs
4.web/samba_cfg_modify.rc  change ip and url for cfg.json
5.postserver.py  receive post data from Coinforge after changing cfg.json


To be done: 

Tuning, merging and automating
