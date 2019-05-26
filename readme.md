## Powershell Data Diving with perf counters
1. The perf_demo file shows the process of figuring out how to export system information with powershell.
2. This is to figure out what is creating data and what type of information is being produced.
3. You can take this data to configure the telegraf.conf inputs for each server/pc

## Influx 2.0 setup with UI
1. Visit https://v2.docs.influxdata.com/v2.0/get-started/
2. Download and install Influx 2.0 (My setup not running influx locally but rather on a Ubuntu VM)

```
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
```

## Start Influx 2.0
1. Run the command <b>influxd</b>
2. Visit http://{serverIP}:9999
3. Enter user name, password, organization and name the bucket <b>InfluxDB</b>
4. Ok now we have the database up now. Click the Advanced tab and create a telegraf config in InfluxDB 2.0. 
5. Select <b>system<b> and name it <b>windows_perf</b>
6. We are going to come back to this but for now lets get telegraf installed locally on our Windows server/pc

## Installing Telegraf on the Windows Machine
1. Head over to https://portal.influxdata.com/downloads/ (Making this it was version 1.10.4)
2. Open a administrator powershell prompt and make a directory (mkdir C:\users\ {your_user} \telegraf)<br />
   **I had an issue downloading it with wget, so I just opened the download link in a browser and saved it to that folder**<br />
   **Enter the download link in a browser for the windows zip file https://dl.influxdata.com/telegraf/releases/telegraf-1.10.4_windows_amd64.zip**<br />
3. Extract the files to you folder C:\users\ {your_user} \telegraf
4. Change into the telegraf directory
5. Open the file in an editor<br />
   **We are going delete what was written into this file because I kept getting 401 authorization issues with the api config call**<br />
![InfluxDB Dashboard](/assets/images/telegraf.PNG "Telegraf config")
6. Go back to you Influx 2.0 machine and go back into Settings -> Telegraf and click on your windows_perf file to open telegraf config.
7. Copy and replace this information to your telegraf.conf file locally.
![InfluxDB Dashboard](/assets/images/telegraf_settings.PNG "Telegraf settings")
8. Windows 10 kept giving me an issue with the [inputs.processes] part so I just commented that out.

## Configuration for telegraf.conf agent
```
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
##[[inputs.processes]]  <--Comment this out for now until I figure out the issue.
[[inputs.swap]]
[[inputs.system]]
```

## Testing and config
1. Once you save the file we are going to export the $INFLUX_TOKEN
2. To test if telefraf can connect issue the command inside the folder telegraf is located: 
```
.\telegraf --config telegraf.conf --test
```
**If you get something like this in the terminal your config is recording data**
```
2019-05-26T16:10:00Z I! Starting Telegraf 1.10.4
> mem,host=area51-pc active=0i,available=20491501568i,available_percent=59.860932559757934,buffered=0i,cached=0i,commit_limit=0i,committed_as=0i,dirty=0i,free=0i,high_free=0i,high_total=0i,huge_page_size=0i,huge_pages_free=0i,huge_pages_total=0i,inactive=0i,low_free=0i,low_total=0i,mapped=0i,page_tables=0i,shared=0i,slab=0i,swap_cached=0i,swap_free=0i,swap_total=0i,total=34231844864i,used=13740343296i,used_percent=40.139067440242066,vmalloc_chunk=0i,vmalloc_total=0i,vmalloc_used=0i,wired=0i,write_back=0i,write_back_tmp=0i 1558887000000000000
> net,host=area51-pc,interface=vEthernet\ (DockerNAT) bytes_recv=2198i,bytes_sent=1611138i,drop_in=0i,drop_out=0i,err_in=0i,err_out=0i,packets_recv=0i,packets_sent=0i 1558887000000000000
> net,host=area51-pc,interface=Ethernet\ 3 bytes_recv=3666599292i,bytes_sent=265306730i,drop_in=0i,drop_out=0i,err_in=0i,err_out=0i,packets_recv=2936593i,packets_sent=1632414i 1558887000000000000
> net,host=area51-pc,interface=vEthernet\ (New\ Virtual\ Switch) bytes_recv=3665010835i,bytes_sent=173100142i,drop_in=0i,drop_out=0i,err_in=0i,err_out=0i,packets_recv=2936556i,packets_sent=1361302i 1558887000000000000
> net,host=area51-pc,interface=vEthernet\ (Default\ Switch) bytes_recv=0i,bytes_sent=1166763i,drop_in=0i,drop_out=0i,err_in=0i,err_out=0i,packets_recv=0i,packets_sent=0i 1558887001000000000
> swap,host=area51-pc free=20739211264i,total=39600553984i,used=18861342720i,used_percent=0.4762898702785986 1558887001000000000
> swap,host=area51-pc in=0i,out=0i 1558887001000000000
> system,host=area51-pc load1=0,load15=0,load5=0,n_cpus=36i,n_users=0i 1558887001000000000
> system,host=area51-pc uptime=94124i 1558887001000000000
> system,host=area51-pc uptime_format="1 day,  2:08" 1558887001000000000
> cpu,cpu=0\,35,host=area51-pc usage_guest=0,usage_guest_nice=0,usage_idle=95.65217391304348,usage_iowait=0,usage_irq=0,usage_nice=0,usage_softirq=0,usage_steal=0,usage_system=2.1739130434782608,usage_user=2.1739130434782608 1558887001000000000
> cpu,cpu=0\,34,host=area51-pc usage_guest=0,usage_guest_nice=0,usage_idle=100,usage_iowait=0,usage_irq=0,usage_nice=0,usage_softirq=0,usage_steal=0,usage_system=0,usage_user=0 1558887001000000000
> cpu,cpu=0\,33,host=area51-pc usage_guest=0,usage_guest_nice=0,usage_idle=100,usage_iowait=0,usage_irq=0,usage_nice=0,usage_softirq=0,usage_steal=0,usage_system=0,usage_user=0 1558887001000000000
> cpu,cpu=0\,32,host=area51-pc usage_guest=0,usage_guest_nice=0,usage_idle=100,usage_iowait=0,usage_irq=0,usage_nice=0,usage_softirq=0,usage_steal=0,usage_system=0,usage_user=0 1558887001000000000
> cpu,cpu=0\,31,host=area51-pc usage_guest=0,usage_guest_nice=0,usage_idle=100,usage_iowait=0,usage_irq=0,usage_nice=0,usage_softirq=0,usage_steal=0,usage_system=0,usage_user=0 1558887001000000000
> cpu,cpu=0\,30,host=area51-pc usage_guest=0,usage_guest_nice=0,usage_idle=89.1304347826087,usage_iowait=0,usage_irq=0,usage_nice=0,usage_softirq=0,usage_steal=0,usage_system=0,usage_user=10.869565217391305 1558887001000000000
> cpu,cpu=0\,29,host=area51-pc usage_guest=0,usage_guest_nice=0,usage_idle=100,usage_iowait=0,usage_irq=0,usage_nice=0,usage_softirq=0,usage_steal=0,usage_system=0,usage_user=0 1558887001000000000
> cpu,cpu=0\,28,host=area51-pc usage_guest=0,usage_guest_nice=0,usage_idle=100,usage_iowait=0,usage_irq=0,usage_nice=0,usage_softirq=0,usage_steal=0,usage_system=0,usage_user=0 1558887001000000000
> cpu,cpu=0\,27,host=area51-pc usage_guest=0,usage_guest_nice=0,usage_idle=97.82608695652173,usage_iowait=0,usage_irq=0,usage_nice=0,usage_softirq=0,usage_steal=0,usage_system=2.1739130434782608,usage_user=0 1558887001000000000
> cpu,cpu=0\,26,host=area51-pc usage_guest=0,usage_guest_nice=0,usage_idle=100,usage_iowait=0,usage_irq=0,usage_nice=0,usage_softirq=0,usage_steal=0,usage_system=0,usage_user=0 1558887001000000000
> cpu,cpu=0\,25,host=area51-pc usage_guest=0,usage_guest_nice=0,usage_idle=100,usage_iowait=0,usage_irq=0,usage_nice=0,usage_softirq=0,usage_steal=0,usage_system=0,usage_user=0 1558887001000000000
> cpu,cpu=0\,24,host=area51-pc usage_guest=0,usage_guest_nice=0,usage_idle=95.74468085106383,usage_iowait=0,usage_irq=2.127659574468085,usage_nice=0,usage_softirq=0,usage_steal=0,usage_system=2.127659574468085,usage_user=0 1558887001000000000
> cpu,cpu=0\,23,host=area51-pc usage_guest=0,usage_guest_nice=0,usage_idle=100,usage_iowait=0,usage_irq=0,usage_nice=0,usage_softirq=0,usage_steal=0,usage_system=0,usage_user=0 1558887001000000000
> cpu,cpu=0\,22,host=area51-pc usage_guest=0,usage_guest_nice=0,usage_idle=56.52173913043478,usage_iowait=0,usage_irq=0,usage_nice=0,usage_softirq=0,usage_steal=0,usage_system=32.608695652173914,usage_user=10.869565217391305 1558887001000000000
> cpu,cpu=0\,21,host=area51-pc usage_guest=0,usage_guest_nice=0,usage_idle=97.82608695652173,usage_iowait=0,usage_irq=0,usage_nice=0,usage_softirq=0,usage_steal=0,usage_system=0,usage_user=2.1739130434782608 1558887001000000000
> cpu,cpu=0\,20,host=area51-pc usage_guest=0,usage_guest_nice=0,usage_idle=100,usage_iowait=0,usage_irq=0,usage_nice=0,usage_softirq=0,usage_steal=0,usage_system=0,usage_user=0 1558887001000000000
> cpu,cpu=0\,19,host=area51-pc usage_guest=0,usage_guest_nice=0,usage_idle=100,usage_iowait=0,usage_irq=0,usage_nice=0,usage_softirq=0,usage_steal=0,usage_system=0,usage_user=0 1558887001000000000
> cpu,cpu=0\,18,host=area51-pc usage_guest=0,usage_guest_nice=0,usage_idle=95.65217391304348,usage_iowait=0,usage_irq=0,usage_nice=0,usage_softirq=0,usage_steal=0,usage_system=0,usage_user=4.3478260869565215 1558887001000000000
> cpu,cpu=0\,17,host=area51-pc usage_guest=0,usage_guest_nice=0,usage_idle=100,usage_iowait=0,usage_irq=0,usage_nice=0,usage_softirq=0,usage_steal=0,usage_system=0,usage_user=0 1558887001000000000
> cpu,cpu=0\,16,host=area51-pc usage_guest=0,usage_guest_nice=0,usage_idle=93.47826086956522,usage_iowait=0,usage_irq=0,usage_nice=0,usage_softirq=0,usage_steal=0,usage_system=2.1739130434782608,usage_user=4.3478260869565215 1558887001000000000
> cpu,cpu=0\,15,host=area51-pc usage_guest=0,usage_guest_nice=0,usage_idle=100,usage_iowait=0,usage_irq=0,usage_nice=0,usage_softirq=0,usage_steal=0,usage_system=0,usage_user=0 1558887001000000000
> cpu,cpu=0\,14,host=area51-pc usage_guest=0,usage_guest_nice=0,usage_idle=71.73913043478261,usage_iowait=0,usage_irq=0,usage_nice=0,usage_softirq=0,usage_steal=0,usage_system=23.91304347826087,usage_user=4.3478260869565215 1558887001000000000
> cpu,cpu=0\,13,host=area51-pc usage_guest=0,usage_guest_nice=0,usage_idle=100,usage_iowait=0,usage_irq=0,usage_nice=0,usage_softirq=0,usage_steal=0,usage_system=0,usage_user=0 1558887001000000000
> cpu,cpu=0\,12,host=area51-pc usage_guest=0,usage_guest_nice=0,usage_idle=67.3913043478261,usage_iowait=0,usage_irq=0,usage_nice=0,usage_softirq=0,usage_steal=0,usage_system=28.26086956521739,usage_user=4.3478260869565215 1558887001000000000
> cpu,cpu=0\,11,host=area51-pc usage_guest=0,usage_guest_nice=0,usage_idle=100,usage_iowait=0,usage_irq=0,usage_nice=0,usage_softirq=0,usage_steal=0,usage_system=0,usage_user=0 1558887001000000000
> cpu,cpu=0\,10,host=area51-pc usage_guest=0,usage_guest_nice=0,usage_idle=100,usage_iowait=0,usage_irq=0,usage_nice=0,usage_softirq=0,usage_steal=0,usage_system=0,usage_user=0 1558887001000000000
> cpu,cpu=0\,9,host=area51-pc usage_guest=0,usage_guest_nice=0,usage_idle=100,usage_iowait=0,usage_irq=0,usage_nice=0,usage_softirq=0,usage_steal=0,usage_system=0,usage_user=0 1558887001000000000
> cpu,cpu=0\,8,host=area51-pc usage_guest=0,usage_guest_nice=0,usage_idle=95.65217391304348,usage_iowait=0,usage_irq=0,usage_nice=0,usage_softirq=0,usage_steal=0,usage_system=4.3478260869565215,usage_user=0 1558887001000000000
> cpu,cpu=0\,7,host=area51-pc usage_guest=0,usage_guest_nice=0,usage_idle=97.82608695652173,usage_iowait=0,usage_irq=0,usage_nice=0,usage_softirq=0,usage_steal=0,usage_system=0,usage_user=2.1739130434782608 1558887001000000000
> cpu,cpu=0\,6,host=area51-pc usage_guest=0,usage_guest_nice=0,usage_idle=100,usage_iowait=0,usage_irq=0,usage_nice=0,usage_softirq=0,usage_steal=0,usage_system=0,usage_user=0 1558887001000000000
> cpu,cpu=0\,5,host=area51-pc usage_guest=0,usage_guest_nice=0,usage_idle=97.82608695652173,usage_iowait=0,usage_irq=0,usage_nice=0,usage_softirq=0,usage_steal=0,usage_system=2.1739130434782608,usage_user=0 1558887001000000000
> cpu,cpu=0\,4,host=area51-pc usage_guest=0,usage_guest_nice=0,usage_idle=95.65217391304348,usage_iowait=0,usage_irq=0,usage_nice=0,usage_softirq=0,usage_steal=0,usage_system=2.1739130434782608,usage_user=2.1739130434782608 1558887001000000000
> cpu,cpu=0\,3,host=area51-pc usage_guest=0,usage_guest_nice=0,usage_idle=100,usage_iowait=0,usage_irq=0,usage_nice=0,usage_softirq=0,usage_steal=0,usage_system=0,usage_user=0 1558887001000000000
> cpu,cpu=0\,2,host=area51-pc usage_guest=0,usage_guest_nice=0,usage_idle=91.30434782608695,usage_iowait=0,usage_irq=0,usage_nice=0,usage_softirq=0,usage_steal=0,usage_system=2.1739130434782608,usage_user=6.521739130434782 1558887001000000000
> cpu,cpu=0\,1,host=area51-pc usage_guest=0,usage_guest_nice=0,usage_idle=91.30434782608695,usage_iowait=0,usage_irq=0,usage_nice=0,usage_softirq=0,usage_steal=0,usage_system=0,usage_user=8.695652173913043 1558887001000000000
> cpu,cpu=0\,0,host=area51-pc usage_guest=0,usage_guest_nice=0,usage_idle=97.82608695652173,usage_iowait=0,usage_irq=0,usage_nice=0,usage_softirq=0,usage_steal=0,usage_system=2.1739130434782608,usage_user=0 1558887001000000000
> cpu,cpu=cpu-total,host=area51-pc usage_guest=0,usage_guest_nice=0,usage_idle=94.05405405405405,usage_iowait=0,usage_irq=0,usage_nice=0,usage_softirq=0,usage_steal=0,usage_system=3.123123123123123,usage_user=2.8228228228228227 1558887001000000000
> disk,device=C:,fstype=NTFS,host=area51-pc,mode=unknown,path=\C: free=357504237568i,inodes_free=0i,inodes_total=0i,inodes_used=0i,total=497839763456i,used=140335525888i,used_percent=28.18889453783117 1558887002000000000
> disk,device=D:,fstype=NTFS,host=area51-pc,mode=unknown,path=\D: free=1783933190144i,inodes_free=0i,inodes_total=0i,inodes_used=0i,total=2000263573504i,used=216330383360i,used_percent=10.81509388190473 1558887002000000000
> diskio,host=area51-pc,name=C: io_time=0i,iops_in_progress=0i,read_bytes=0i,read_time=0i,reads=0i,weighted_io_time=0i,write_bytes=0i,write_time=0i,writes=0i 1558887002000000000
> diskio,host=area51-pc,name=D: io_time=0i,iops_in_progress=0i,read_bytes=0i,read_time=0i,reads=0i,weighted_io_time=0i,write_bytes=0i,write_time=0i,writes=0i 1558887002000000000
```

## Issues with setting variable
1. Influx2.0 asks to set the variable by exporting it but powershell does not recognize this command.
2. Until I figure out how to pass this through with powershell you will need to replace $INFLUX_TOKEN in the telegraf.conf file with yours from the influx UI.  
3. You can find it by selecting the settings tab and clicking setup instructions.  You will only need what is after the equal sign.
4. Replace the token, save the file and issue the command: .\telegraf --config telegraf.conf
   
```
PS C:\Users\digikin\telegraf\telegraf-1.10.4_windows_amd64\telegraf> .\telegraf --config telegraf.conf
2019-05-26T17:04:56Z I! Starting Telegraf 1.10.4
2019-05-26T17:04:56Z I! Loaded inputs: diskio mem net swap system cpu disk
2019-05-26T17:04:56Z I! Loaded aggregators:
2019-05-26T17:04:56Z I! Loaded processors:
2019-05-26T17:04:56Z I! Loaded outputs: influxdb_v2
2019-05-26T17:04:56Z I! Tags enabled: host=area51-pc
2019-05-26T17:04:56Z I! [agent] Config: Interval:10s, Quiet:false, Hostname:"area51-pc", Flush Interval:10s
2019-05-26T17:07:03Z E! [inputs.diskio]: Error in plugin: error getting disk io info: context deadline exceeded
2019-05-26T17:07:03Z E! [inputs.cpu]: Error in plugin: error getting CPU info: context deadline exceeded
2019-05-26T17:23:13Z E! [inputs.diskio]: Error in plugin: error getting disk io info: context deadline exceeded
2019-05-26T17:23:13Z E! [inputs.cpu]: Error in plugin: error getting CPU info: context deadline exceeded
2019-05-26T17:33:32Z E! [outputs.influxdb_v2] when writing to [http://192.168.1.15:9999]: Post http://192.168.1.15:9999/
```
**Again I am still trying to work out issues with the data collection with telegraf so it is reporting errors for now**

## Influx Dashboard
1. Log back into your influxdb UI.
2. Select the Dashboard tab and select system. 
   


**There is more to come.  I have also added the docker plugin to the .conf file.**
## Dashboard preview with Docker plugin configured
![InfluxDB Dashboard](/assets/images/Dashboard.PNG "InfluxDB Dashboard with Docker plugin")

