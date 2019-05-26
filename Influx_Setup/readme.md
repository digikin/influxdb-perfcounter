## Influx 2.0 setup with UI
1. Visit https://v2.docs.influxdata.com/v2.0/get-started/
2. Download and install Influx 2.0 (My setup not running influx locally but rather on a Ubuntu VM)

<pre>
eric@influx:~$ wget https://dl.influxdata.com/influxdb/releases/influxdb_2.0.0-alpha.9_linux_amd64.tar.gz
--2019-05-26 14:44:41--  https://dl.influxdata.com/influxdb/releases/influxdb_2.0.0-alpha.9_linux_amd64.tar.gz
Resolving dl.influxdata.com (dl.influxdata.com)... 13.35.115.123, 13.35.115.21, 13.35.115.13, ...
Connecting to dl.influxdata.com (dl.influxdata.com)|13.35.115.123|:443... connected.
HTTP request sent, awaiting response... 200 OK
Length: 24339213 (23M) [binary/octet-stream]
Saving to: ‘influxdb_2.0.0-alpha.9_linux_amd64.tar.gz’

influxdb_2.0.0-alpha.9_linux_ 100%[=================================================>]  23.21M  10.2MB/s    in 2.3s

2019-05-26 14:44:44 (10.2 MB/s) - ‘influxdb_2.0.0-alpha.9_linux_amd64.tar.gz’ saved [24339213/24339213]

eric@influx:~$ tar xvzf influxdb_2.0.0-alpha.9_linux_amd64.tar.gz
influxdb_2.0.0-alpha.9_linux_amd64/LICENSE
influxdb_2.0.0-alpha.9_linux_amd64/README.md
influxdb_2.0.0-alpha.9_linux_amd64/influx
influxdb_2.0.0-alpha.9_linux_amd64/influxd
eric@influx:~$ sudo cp influxdb_2.0.0-alpha.9_linux_amd64/{influx,influxd} /usr/local/bin/
</pre>

## Start Influx 2.0
1. Run the command <b>influxd</b>
2. Visit {serverIP}:9999
3. Enter user name, password, organization and name the bucket <b>InfluxDB</b>
4. Ok now we have the database up now the best part of InfluxDB 2.0. Click the Advanced tab and create a telegraf config. 
5. Select system and name it <b>windows_perf</b>

## Installing Telegraf on the Windows Machine
1. Head over to https://portal.influxdata.com/downloads/ (Making this it was version 1.10.4)
2. Open a administrator powershell prompt and make a directory (mkdir C:\users\{your_user}\telegraf)<br />
   **I had an issue downloading it with wget, so I just opened the download link in a browser and saved it to that folder**<br />
   **Enter the download link in a browser for the windows zip file https://dl.influxdata.com/telegraf/releases/telegraf-1.10.4_windows_amd64.zip**<br />
3. Extract the files to you folder C:\users\{your_user}\telegraf
4. Change into the telegraf directory
5. Issue the command <b>code telegraf.conf</b><br />
   **We are going delete what was written into this file because I kept getting 401 authorization issues with the api config call**<br />
6. Go back to you Influx 2.0 machine and go back into Settings -> Telegraf and click on your windows_perf file to open telegraf config.
7. Copy and replace this information to your telegraf.conf file locally.
8. Windows 10 kept giving me an issue with the [inputs.processes] part so I just commented that out.
   <code>
   # Configuration for telegraf agent
[agent]
  ## Default data collection interval for all inputs
  interval = "10s"
  ## Rounds collection interval to 'interval'
  ## ie, if interval="10s" then always collect on :00, :10, :20, etc.
  round_interval = true

  ## Telegraf will send metrics to outputs in batches of at most
  ## metric_batch_size metrics.
  ## This controls the size of writes that Telegraf sends to output plugins.
  metric_batch_size = 1000

  ## For failed writes, telegraf will cache metric_buffer_limit metrics for each
  ## output, and will flush this buffer on a successful write. Oldest metrics
  ## are dropped first when this buffer fills.
  ## This buffer only fills when writes fail to output plugin(s).
  metric_buffer_limit = 10000

  ## Collection jitter is used to jitter the collection by a random amount.
  ## Each plugin will sleep for a random time within jitter before collecting.
  ## This can be used to avoid many plugins querying things like sysfs at the
  ## same time, which can have a measurable effect on the system.
  collection_jitter = "0s"

  ## Default flushing interval for all outputs. Maximum flush_interval will be
  ## flush_interval + flush_jitter
  flush_interval = "10s"
  ## Jitter the flush interval by a random amount. This is primarily to avoid
  ## large write spikes for users running a large number of telegraf instances.
  ## ie, a jitter of 5s and interval 10s means flushes will happen every 10-15s
  flush_jitter = "0s"

  ## By default or when set to "0s", precision will be set to the same
  ## timestamp order as the collection interval, with the maximum being 1s.
  ##   ie, when interval = "10s", precision will be "1s"
  ##       when interval = "250ms", precision will be "1ms"
  ## Precision will NOT be used for service inputs. It is up to each individual
  ## service input to set the timestamp at the appropriate precision.
  ## Valid time units are "ns", "us" (or "µs"), "ms", "s".
  precision = ""

  ## Logging configuration:
  ## Run telegraf with debug log messages.
  debug = false
  ## Run telegraf in quiet mode (error log messages only).
  quiet = false
  ## Specify the log file name. The empty string means to log to stderr.
  logfile = ""

  ## Override default hostname, if empty use os.Hostname()
  hostname = ""
  ## If set to true, do no set the "host" tag in the telegraf agent.
  omit_hostname = false
[[outputs.influxdb_v2]]	
  ## The URLs of the InfluxDB cluster nodes.
  ##
  ## Multiple URLs can be specified for a single cluster, only ONE of the
  ## urls will be written to each interval.
  ## urls exp: http://127.0.0.1:9999
  urls = ["http://192.168.1.15:9999"]  <-- Your server URL will be different

  ## Token for authentication.
  token = "$INFLUX_TOKEN"  <-- Influx token that we will have to set in powershell

  ## Organization is the name of the organization you wish to write to; must exist.
  organization = "local"

  ## Destination bucket to write into.
  bucket = "InfluxDB"
[[inputs.cpu]]
  ## Whether to report per-cpu stats or not
  percpu = true
  ## Whether to report total system cpu stats or not
  totalcpu = true
  ## If true, collect raw CPU time metrics.
  collect_cpu_time = false
  ## If true, compute and report the sum of all non-idle CPU states.
  report_active = false
[[inputs.disk]]
  ## By default stats will be gathered for all mount points.
  ## Set mount_points will restrict the stats to only the specified mount points.
  # mount_points = ["/"]
  ## Ignore mount points by filesystem type.
  ignore_fs = ["tmpfs", "devtmpfs", "devfs", "overlay", "aufs", "squashfs"]
[[inputs.diskio]]
[[inputs.mem]]
[[inputs.net]]
##[[inputs.processes]]  <--Comment this out for now untill I figure out the issue.
[[inputs.swap]]
[[inputs.system]]
</code>

9. Once you save the file we are going to export the INFLUX
   
