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
3. web/coinworm.html   coin worm for easter eggs - systemctl service
4. web/samba_cfg_modify.rc and coin_cfg_update.sh interruts the coin flow by changing ip and url of cfg.json. - crontab per 2 mins
5. postserver.py  receive post data from Coinforge after changing cfg.json - systemctl service
6. restore_cfg.sh restore the origenal ip and URL for cfg.json to make sure communication with Coin Collector works. - crontab per 3 mins

# Cron Task and Automation

Attacker (Kali) crontab

*/2 * * * * /home/dcloud/coinbank/web/coin_cfg_update.sh >> /home/dcloud/coinbank/web/coin_cfg_update.log 2>&1

Attacker (Kali)

systemctl service: coinworm-web.service

http get service on 8088  - http://198.18.14.2:8088/coinworm.html

systemctl service: postserver.service

http post service on 5000 - http://198.18.14.2:5000

Coinforge crontab

* * * * * /coin-forge/forge-script.sh >> /coin-forge/forge-script.log 2>&1
* * * * * /coin-forge/health-script-5s-cronwrapper.sh >> /coin-forge/health-script.log 2>&1
*/3 * * * * /coin-forge/restore_cfg.sh >> /coin-forge/restore.log 2>&1

# To be done

Tuning, merging and automating
