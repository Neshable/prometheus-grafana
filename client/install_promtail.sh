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


echo "Setup complete.
Add the following lines to /etc/prometheus/prometheus.yml:

 - job_name: 'job_name'

    scrape_interval: 15s
    scrape_timeout: 5s

    metrics_path: /9100
    static_configs:
      - targets: ['your.client.ip']
        labels:
         group: 'somegrou'p
"

echo "
Add the following to sites-enabled/default

        location /9100 {
                allow <prometheus server ip>;
                allow 127.0.0.1;
                deny  all;

                proxy_pass http://127.0.0.1:9100/metrics;
        }
"