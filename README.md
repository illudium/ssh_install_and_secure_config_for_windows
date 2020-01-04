# openssh_for_windows
Installation and configuration of a secure configuration of OpenSSH for Windows 10 (1809 &amp; later) and Server 2019

Please note that the provided item is something of a quick-and-dirty script in terms of the basic powershell used.
It is not meant to be exemplary coding, the focus on this was the resulting configuration and its security,
the provided powershell script does no error-checking and is in fact quite rudimentary.

 REQUIREMENTS:
 You will need to have SSH already configured and operational client-side (on your workstation),
 and the content of your chosen & working ssh .pub keypair.
 For more info, please see https://www.ssh.com/ssh/public-key-authentication
 For the key type, ed25519 is recommended, and supported with the version of OpenSSH server that will be installed.

 IMPORTANT: YOU MUST adjust (and or add to) the desired external IPs where noted in the script ("Adjust the built-in Windows firewall" section), AND you must already have ssh installed and working, client-side (per above).

 CRITICAL: You must have an existing, available, local (typically also) admin account on each Windows endpoint you want to connect to, for use with a config management tool - be it Ansible or another such other tool of your choosing.
 It is fine and recommended in an AD environment that you manage any such accounts via LAPS,
 see https://www.microsoft.com/en-us/download/details.aspx?id=46899
 NOTE: The setup below will allow you to connect to the designated account WITHOUT needing to authenticate.
 It is incumbent on you - and URGENT, that you use a properly maintained & secured workstation from which to connect.
 
 Implementation per endpoint:
 How you implement this on existing Windows end-points is a matter of your own choosing, based on existing
 management tools and options :-)
