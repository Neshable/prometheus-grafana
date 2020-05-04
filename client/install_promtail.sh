#!/bin/bash
wget https://github.com/grafana/loki/releases/download/v1.4.1/promtail-linux-amd64.zip
unzip promtail-linux-amd64.zip
cp promtail-linux-amd64 /usr/local/bin/promtail_loki

# copy conf and position files

# create user
useradd --no-create-home --shell /bin/false promtail

# set permissions
chown promtail:promtail /usr/local/bin/promtail_loki
chown promtail:promtail /home/promtail/config.yaml
chown promtail:promtail /home/promtail/positions.yaml

# add promtail to usergroup adm
sudo usermod -a -G adm promtail

echo '[Unit]
Description=Promtail Loki
Wants=network-online.target
After=network-online.target

[Service]
User=promtail
Group=promtail
Type=simple
ExecStart=/usr/local/bin/promtail_loki \
    -config.file=/home/promtail/config.yaml \
    -positions.file=/home/promtail/positions.yaml

[Install]
WantedBy=multi-user.target' > /etc/systemd/system/promtail_loki.service

# enable promtail-linux-amd64 in systemctl
systemctl daemon-reload
systemctl start promtail_loki
systemctl enable promtail_loki
