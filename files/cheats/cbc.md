# cbc server commands

- pcs status - checking cluster status
- cbc alarms list - show cbc alarms 
- cbc cells list - show cells

## encrypt & decrypt ansible-vault 

Run commands from with-in the ansible docker container

```commandline
make docker-attach
```

```commandline
echo -n 'your_secret_string' | ansible-vault encrypt_string --vault-id=nonprod@$(which vault-password-client); echo
```

```commandline
288c6a11aa15:~/em-manage-instances$ ansible-vault view /dev/stdin   --vault-id nonprod@$(which vault-password-client)
```
- Paste the $ANSIBLE_VAULT string without indentation
- CTRL+D to send
- plantext string will be output

## example

```commandline
288c6a11aa15:~/em-manage-instances$ ansible-vault view /dev/stdin   --vault-id nonprod@$(which vault-password-client)
$ANSIBLE_VAULT;1.2;AES256;nonprod
32313337653562646664633366323265613664313239316430306130333136633136336335646431
3262363632656131623234333731343733303232613131310a626434323634313762376135313239
30363262656235336333393631373838383037396232636538343666643663613966333366363661
3231353666336539380a333863613934633465343163636433303634353635363264393337373461
36346237653330613038643065343XXXXXXXXXXXXXXXXXXXX
gYcO@5YPQ2IXXXXX
```