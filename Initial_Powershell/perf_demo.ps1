#Getting started to find out what a counter was in powershell.
Get-Help Counter
Get-Help Counter -examples

#Examples pulled up a lot of good ideas see the CounterExamples file.
#This pull up a huge list of paths.
$cpu = (Get-Counter -ListSet *).Paths
$cpu

#Starting to drill down on what path might be have the information I wanted.
$p = Get-Counter -Counter "\Processor(_Total)\% Processor Time"
$q = Get-Counter -Counter "\Process(idle)\% processor time"
$r = Get-Counter -Counter "\logicaldisk(_total)\% free space"
$p.CounterSamples
$q.CounterSamples
$r.CounterSamples

#Testing out a divverent counter path I found to see what type of data returned. 
$z = Get-Counter -Counter "\Memory\Available MBytes"
$z

#Ok lets but this together so I can look them up all at once.
$Counters = @(
    '\network adapter(hyper-v virtual ethernet adapter _2)\packets sent/sec'
    '\network adapter(hyper-v virtual ethernet adapter _2)\packets received/sec'
    '\network adapter(killer e2500 gigabit ethernet controller _3)\packets sent/sec'
    '\network adapter(killer e2500 gigabit ethernet controller _3)\packets received/sec'
    '\Memory\Available MBytes'
    '\Memory\% Committed Bytes In Use'
    '\logicaldisk(c:)\free megabytes'
    '\logicaldisk(d:)\free megabytes'
    '\Processor(*)\% Processor Time'
    '\process(idle)\% processor time'
    '\process(system)\% processor time'
    '\processor(_total)\% idle time'
)

Get-Counter -Counter $Counters -MaxSamples 5 | ForEach {
    $_.CounterSamples | ForEach {
        [pscustomobject]@{
            TimeStamp = $_.TimeStamp
            Path = $_.Path
            Value = $_.CookedValue
        }
    }
} | Export-Csv -Path Perf.csv -NoTypeInformation
#This will export it to its current path.