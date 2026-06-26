# Hashicorp Vault

## troubleshooting commands

    docker exec -it vault sh -c 'export VAULT_ADDR=https://127.0.0.1:8200 && export VAULT_SKIP_VERIFY=true && vault status'
    docker exec -it vault sh -c 'export VAULT_ADDR=https://127.0.0.1:8200 && export VAULT_SKIP_VERIFY=true && vault operator raft list-peers'
    journalctl -u vault -n 100
    docker inspect vault | grep -A100 Mounts

## testing from cbc

    su - vaspadm
    cbe.ksh

```commandline
[vaspadm@pny9-cbc1-cbc-0001 ~]$ cbe.ksh
  __  __                                  _____         _
 |  \/  | ___  ___ ___  __ _  __ _  ___  |_   _|__  ___| |_ ___ _ __
 | |\/| |/ _ \/ __/ __|/ _' |/ _' |/ _ \   | |/ _ \/ __| __/ _ \ '__|
 | |  | |  __/\__ \__ \ (_| | (_| |  __/   | |  __/\__ \ ||  __/ |
 |_|  |_|\___||___/___/\__,_|\__, |\___|   |_|\___||___/\__\___|_|
                             |___/
 -= Unsupported Test Tool =-

Checking availability of XML Gateway... ok.

 1) Login the CBC                                                                                      13) Kill all messages in cell(s)
 2) Send message to area                                                                               14) Create predefined area
 3) Send message to predefined area(s)                                                                 15) Remove predefined area
 4) Send message to cell(s)                                                                            16) Info on message
 5) Send message to cc(s)                                                                              17) Info on area
 6) Send message to polygon(s) and/or circle(s)                                                        18) Info on command
 7) Send message to complex polygons (using WKT)                                                       19) Info on network
 8) Send message to shape(s)                                                                           20) Info on cells per message
 9) Send message to PLMN                                                                               21) Change password
10) Change contents                                                                                    22) Logout CBC
11) Kill a message                                                                                     23) Show or change configuration
12) Kill a message in cell(s)                                                                          24) Exit
Select action... 1
Get "https://127.0.0.1:8200/v1/sys/internal/ui/mounts/cbc": EOF
Get "https://127.0.0.1:8200/v1/sys/internal/ui/mounts/cbc": EOF
Get "https://127.0.0.1:8200/v1/sys/internal/ui/mounts/cbc": EOF
Login result: 1030 - Login failed
```
