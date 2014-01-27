#!/usr/bin/perl
use CGI qw(:cgi-lib :standard);
print header;
&ReadParse(%in);
$hostname = `hostname`;
my $filepath = "";
my $filepath = $in{'cfilepath'};
my $savepath = "";
my $savepath = $in{'csavepath'};
my $confdata = "";
my $confdata = $in{'configtext'};
if ($confdata ne "") {
  open (MYFILE, ">", $savepath);
  print MYFILE $confdata;
  close (MYFILE); 
}
print "<style type='text/css'> body {font-family: 'Trebuchet MS', Helvetica, sans-serif; background-color:white; text-align:center; } </style>";
print "<style type='text/css'> table { border: 2px solid #cccccc; margin-left: auto; margin-right: auto; } td { padding:3px; ) </style>";
print "<br><h1>Configuation Editor</h1>";
print "<table>  ";
print "<tr><td>Hostname: $hostname</td></tr>";
print "<form name='config' action='confedit.pl' method='POST'>";
print "<tr><td><input type='text' placeholder='/path/to/cgminer.conf' size='60' name='cfilepath' required>";
print "<input type='submit' value='Open'>";
print "</form></td></tr>";
$filepath = $savepath if ($savepath ne ""); 
print "<tr><td>Current file: $filepath";
if (! -w $filepath) {
  print "<br>File is not writable!";
}
print "</td></tr>";
open (MYFILE, $filepath);
 while (<MYFILE>) {
 	chomp;
 	$filedata .= "$_\n";
 }
 close (MYFILE); 
print "<tr><td>";
print "<form name='configedit' action='confedit.pl' method='POST'>";
print "<textarea name='configtext' style='width:512px;height:256px'>$filedata</textarea>";
print "</td></tr><tr><td><input type='submit' value='Save As'>";
print "<input type='text' placeholder='/path/to/cgminer.conf' size='60' name='csavepath' required>";
print "</form></td></tr></table>";
print "<br><p>WARNING! This tool performs no validation whatsoever!";
print "<br>It will let you make stupid mistakes and overwrite files. It is not secure.";
print "<br><big>USE ENTIRELY AT YOUR OWN RISK!</big>";
print "<p>To save a file with this tool the web server process must have write permissions to it.";
print "<br>e.g. 'chmod +w /path/to/filename'";
print "<p>Pizza and praises to lily\@disorg.net <br>LTC: LdMJB36zEfTo7QLZyKDB55z9epgN78hhFb";
print "</body></html>";
