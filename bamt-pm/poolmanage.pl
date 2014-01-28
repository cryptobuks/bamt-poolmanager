#!/usr/bin/perl
use CGI qw(:cgi-lib :standard);
require '/opt/bamt/common.pl';
print header;
&ReadParse(%in);

print "<meta http-equiv='REFRESH' content='3;url=./status.pl?'>";
print "<style type='text/css'> body {font-family: 'Trebuchet MS', Helvetica, sans-serif; background-color:white; } </style>";
print "<style type='text/css'> table { border: 2px solid #cccccc; margin-left: auto; margin-right: auto; } td { text-align:center; padding:10px; ) </style>"; 
print "<br><br><br><table><tr>";


my $preq = $in{'swpool'};
if ($preq ne "") {
  print "<td><big>Switching Pool Priority...</big><p><b>It will take a moment for the miner to switch, please stand by.</b></td>";
  &switchPool($preq);
  $preq = "";

}

my $apooln = $in{'npoolurl'};
my $apoolu = $in{'npooluser'};
my $apoolp = $in{'npoolpw'};
if ($apooln ne "") { 
  my $pmatch = 0;
  my @pools = &getCGMinerPools(1);
  if (@pools) {
    for (my $i=0;$i<@pools;$i++) {
      $pname = ${@pools[$i]}{'url'};
      $pmatch++ if ($pname eq $apooln);
    }
  }
  if ($pmatch eq 0) {  
    print "<td><big>Adding Pool...</big></td>";
    &addPool($apooln, $apoolu, $apoolp); 
    &saveConfig();
    $apooln = "";
    $apoolu = "";
    $apoolp = "";
  } else { 
    print "<td bgcolor='yellow'><p><big>Duplicate Pool, not adding!</big></td>";
  }
}


my $dpool = $in{'delpool'};
if ($dpool ne "") { 
  print "<td><big>Removing Pool...</big></td>";
  &delPool($dpool);
  &saveConfig();
  $dpool = "";
}

my $status = ""; 
my $mstart = $in{'mstart'};
if ($mstart eq "start") { 
  if (system("echo $in{'ptext'} | sudo -S /usr/sbin/mine start")!=0) {
    $status = "Failed!";
  }
  if ($status ne "") {
    print "<td bgcolor='yellow'><p><big>$status</big>";
  } else {
    print "<td bgcolor='green'><p><big><font color='white'>STARTING MINER...</big></td>";
  }
}

my $mstop = $in{'mstop'};
if ($mstop eq "stop") { 
  if (system("echo $in{'ptext'} | sudo -S /usr/sbin/mine stop")!=0) {
    $status = "Failed!";
  }
  if ($status ne "") {
    print "<td bgcolor='yellow'><p><big>$status</big>";
  } else {
   print "<td bgcolor='red'><p><big>STOPPING MINER...</big></td>";
  }
#  my $runcheck = `ps -eo command | grep [c]gminer | wc -l`;
#  if ($runcheck > 0) {
#    print "<td bgcolor='red'><p><big>STOPPING MINER...</big></td>";
#    exec('sudo /usr/sbin/mine stop');
#  } else {
#    print "<td bgcolor='yellow'><p><big>MINER NOT RUNNING</big></td>";
#  }
}

print "</tr></table></body></html>";

