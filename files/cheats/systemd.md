# systemd

- list active services
  ```shell
  systemctl list-units --type=service --state=running --no-pager --no-legend | awk '{print $1}' | sort
  ```

