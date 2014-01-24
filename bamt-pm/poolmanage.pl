#!/usr/bin/perl
use CGI qw(:cgi-lib :standard);
require '/opt/bamt/common.pl';
print header;
my $start_page = "<meta http-equiv='REFRESH' content='1;url=./status.pl?'>";
print $start_page;
&ReadParse(%in);

my $preq = $in{'rpool'};
if ($preq ne "") {
  &switchPool($preq);
  print "<center><h1>Switching Pool Priority...</h1><br><h2>It may take a moment for the miner to switch</h2>";
  &saveConfig();
  $preq = "";
}

my $apooln = $in{'npoolurl'};
my $apoolu = $in{'npooluser'};
my $apoolp = $in{'npoolpw'};
if ($apooln ne "") { 
  &addPool($apooln, $apoolu, $apoolp); 
  print "<center><h1>Adding Pool...</h1>";
  &saveConfig();
  $apooln = "";
  $apoolu = "";
  $apoolp = "";
}

my $dpool = $in{'delpool'};
if ($dpool ne "") { 
  &delPool($dpool);
  print "<center><h1>Deleting Pool...</h1>";
  &saveConfig();
  $dpool = "";
}
