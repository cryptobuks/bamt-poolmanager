#!/usr/bin/perl
use CGI qw(:standard);
use Data::Dumper;

require '/opt/bamt/common.pl';

our $conf = &getConfig;
%conf = %{$conf};

$q=CGI->new();

$showgpu = -1;
$showpool = -1;

$mgpumon = $q->param('mgpumon') or $mgpumon = "";

if (defined($q->param('gpu')))
{
	$showgpu = $q->param('gpu');
}
if (defined($q->param('pool')))
{
	$showpool = $q->param('pool');
}

$refer = $q->referer();

if ($refer =~ m/.*\/mgpumon\/$/)
{
	$mgpumon = $refer;
}

my $url = "?";

if (! $mgpumon eq "")
{
	$url .= "mgpumon=$mgpumon&";
}

if ($showgpu > -1)
{
	$url .= "gpu=$showgpu&";
}
if ($showpool > -1)
{
	$url .= "pool=$showpool&";
}


print header;
if ($url eq "?")
{
	print start_html( -title=>'IFMI - ' . $conf{'settings'}{'miner_id'} . ' status', -style=>{-src=>'/bamt/status.css'},  -head=>$q->meta({-http_equiv=>'REFRESH',-content=>'30'})  );
}
else
{
	$url .= "tok=1";
	print start_html( -title=>'IFMI - ' . $conf{'settings'}{'miner_id'} . ' status', -style=>{-src=>'/bamt/status.css'},  -head=>$q->meta({-http_equiv=>'REFRESH',-content=>'30; url=' . $url })  );
}

# pull gpu info
my @gpus = &getFreshGPUData(1);

#gather totals
my $tot_mhash = 0;
my $tot_accept = 0;
my $tot_invalid = 0;

my $gput = "";
my $problems = 0;
my $okgpus = 0;
my $problemgpus = 0;
my @nodemsg;
my @gpumsg;

$g1put .= "<TR class='ghdr'><TD class='ghdr'>GPU</TD>";
$g1put .= "<TD class='ghdr'>Status</TD>";
$g1put .= "<TD class='ghdr'>Temp</TD>";

$g1put .= "<TD class='ghdr'>Fan\% (rpm)</TD>";
$g1put .= "<TD class='ghdr'>Load</TD>";
$g1put .= "<TD class='ghdr'>Rate</TD>";
$g1put .= "<TD class='ghdr' colspan=2>Accept/Reject</TD>";

$g1put .= "<TD class='ghdr'>HW Errors</TD>";
$g1put .= "<TD class='ghdr'>Core</TD>";
$g1put .= "<TD class='ghdr'>Memory</TD>";
$g1put .= "<TD class='ghdr'>Power</TD>";

my $gsput = "";

for (my $i=0;$i<@gpus;$i++)
{
	my $gput = "";
	
	$tot_mhash += ${@gpus[$i]}{hashrate};	
	$tot_accept += ${@gpus[$i]}{shares_accepted};	
	$tot_invalid += ${@gpus[$i]}{shares_invalid};	

    $gput .= '</TR></TABLE></TD>';

	if (defined($conf{'gpu'. $i}{monitor_temp_hi}) && ($gpus[$i]{'current_temp_0'} > $conf{'gpu'. $i}{monitor_temp_hi}))
	{
			$problems++;
			push(@nodemsg, "GPU $i is over maximum temp");
			
			if ($i == $showgpu)
			{
				push(@gpumsg, "Over maximum temp");
				$gsput .= "<tr><td>Temp:</td><td class='error'>" . sprintf("%.1f", $gpus[$i]{'current_temp_0'}) . ' c</td></tr>';	
			}
			
			$gput .= "<td class='error'>";
	}
	elsif (defined( $conf{'gpu'. $i}{monitor_temp_lo}) && ($gpus[$i]{'current_temp_0'} < $conf{'gpu'. $i}{monitor_temp_lo}))
	{
			$problems++;
			push(@nodemsg, "GPU $i is below minimum temp");

			if ($i == $showgpu)
			{
				push(@gpumsg, "Below minimum temp");
				$gsput .= "<tr><td>Temp:</td><td class='error'>" . sprintf("%.1f", $gpus[$i]{'current_temp_0'}) . ' c</td></tr>';	
			}
			
			$gput .= "<td class='error'>";
	}
	else
	{
		if ($i == $showgpu)
		{
			$gsput .= "<tr><td>Temp:</td><td>" . sprintf("%.1f", $gpus[$i]{'current_temp_0'}) . ' c</td></tr>';	
		}
		$gput .= '<td>';
	}
	
	
	
	$gput .= sprintf("%.1f", $gpus[$i]{'current_temp_0'}) . ' c';

	$gput .= '</TD>';
	
	if (defined($conf{'gpu'. $i}{monitor_fan_lo}) && ($gpus[$i]{'fan_rpm'} < $conf{'gpu'. $i}{monitor_fan_lo}) && (! $gpus[$i]{'fan_rpm'} eq 'na'))
	{
		$problems++;
		push(@nodemsg, "GPU $i is below minimum fan rpm");
		
		if ($i == $showgpu)
		{
			push(@gpumsg, "Below minimum fan rpm");
			$gsput .= "<tr><td>Fan speed:</td><td class='error'>" .  $gpus[$i]{'fan_speed'} . '% (' . $gpus[$i]{'fan_rpm'}  . " rpm)</td></tr>";
		}
		
		$gput .= "<td class='error'>";
	}
	else
	{
		if ($i == $showgpu)
		{
				$gsput .= "<tr><td>Fan speed:</td><td>" .  $gpus[$i]{'fan_speed'} . '% (' . $gpus[$i]{'fan_rpm'}  . " rpm)</td></tr>";
		}
		
		$gput .= '<td>';
	}
		
	$gput .= $gpus[$i]{'fan_speed'} . '% (' . $gpus[$i]{'fan_rpm'} . ')';

	$gput .= '</TD>';


	if (defined($conf{'gpu'. $i}{monitor_hash_lo}) && ($gpus[$i]{'current_load'} < $conf{'gpu'. $i}{monitor_load_lo}))
	{
		$problems++;
		push(@nodemsg, "GPU $i is below minimum load");
		
		if ($i == $showgpu)
		{
			push(@gpumsg, "Below minimum load");
			$gsput .= "<tr><td>Load:</td><td class='error'>" . $gpus[$i]{'current_load'}  ."%</td></tr>";	
		}
		
		$gput .= "<td class='error'>";
	}
	else
	{
		if ($i == $showgpu)
		{
			$gsput .= "<tr><td>Load:</td><td>" . $gpus[$i]{'current_load'}  ."%</td></tr>";	
		}
		
		$gput .= '<td>';
	}
	
	$gput .= $gpus[$i]{'current_load'} . '%</TD>';
		
	if (defined($conf{'gpu'. $i}{monitor_hash_lo}) && ($gpus[$i]{'hashrate'} < $conf{'gpu'. $i}{monitor_hash_lo}))
	{
		$problems++;
		push(@nodemsg, "GPU $i is below minimum hash rate");
		
		if ($i == $showgpu)
		{
			push(@gpumsg, "Below minimum hash rate");
			
		}

		
		$gput .= "<td class='error'>";
	}
	else
	{
		$gput .= '<td>';
	}
	
	$gput .= sprintf("%d", $gpus[$i]{'hashrate'}) . " Kh/s";
		
	$gput .= "</TD><TD>";
	$gput .= $gpus[$i]{'shares_accepted'} . " / " . $gpus[$i]{'shares_invalid'};
	
	$gput .= '</TD>';
	
	
	
	if ($gpus[$i]{'shares_accepted'} > 0)
	{
		my $rr = $gpus[$i]{'shares_invalid'}/($gpus[$i]{'shares_accepted'} + $gpus[$i]{'shares_invalid'})*100 ;
		
		if (defined(${$config}{monitor_reject_hi}) && ($rr > ${$config}{monitor_reject_hi}))
		{
			$problems++;
			push(@nodemsg, "GPU $i is above maximum reject rate");
			
			if ($i == $showgpu)
			{
				push(@gpumsg, "Above maximum reject rate");
				$gsput .= "<tr><td>Shares A/R:</td><td class='error'>" .  $gpus[$i]{'shares_accepted'} . ' / ' . $gpus[$i]{'shares_invalid'} . ' (' . sprintf("%-2.2f%", $rr) . ")</td></tr>";
			}
			
			$gput .= "<td class='error'>";
		}
		else
		{
			if ($i == $showgpu)
			{
				$gsput .= "<tr><td>Shares A/R:</td><td>" .  $gpus[$i]{'shares_accepted'} . ' / ' . $gpus[$i]{'shares_invalid'} . ' (' . sprintf("%-2.2f%", $rr) . ")</td></tr>";
			}
			
			$gput .= '<td>';
		}
		
		$gput .= sprintf("%-2.2f%", $rr);
	}
	else
	{
		if ($i == $showgpu)
		{
				$gsput .= "<tr><td>Shares A/R:</td><td>" .  $gpus[$i]{'shares_accepted'} . ' / ' . $gpus[$i]{'shares_invalid'} . "</td></tr>";
		}
		
		$gput .= '<td>n/a';
	}
	
	$gput .= "</TD>";
	
        my $ghwe = $gpus[$i]{'hardware_errors'};	
	if ($ghwe > 0) { 
	  $gpuhwe = "<td class='error'>" . $ghwe . "</td>";
	} else { 
	  $gpuhwe = "<td>" . $ghwe . "</td>";
	}
        $gput .= $gpuhwe;
		
	$gput .= "<TD>";

	$gput .= $gpus[$i]{'current_core_clock'} . ' Mhz';
	
	$gput .= "</TD><TD>";
	
	$gput .= $gpus[$i]{'current_mem_clock'} . ' Mhz';
	
	$gput .= "</TD><TD>";
	
	$gput .= $gpus[$i]{'current_core_voltage'} . 'v';

	$gput .= "</TD></TR>";

	if ($i == $showgpu)
	{
                push(@gpumsg, "GPU $i has Hardware Errors") if ($ghwe > 0);		
		$gsput .= "<tr><td>HW Errors:</td>" . $gpuhwe . "</tr>"; 
                $gsput .= "<tr><td>Powertune:</td><td>" . $gpus[$i]{'current_powertune'} . "%</td></tr>";
		$gsput .= "<tr><td>Core clock:</td><td>" . $gpus[$i]{'current_core_clock'} . ' Mhz</td></tr>'; 
		$gsput .= "<tr><td>Mem clock:</td><td>" . $gpus[$i]{'current_mem_clock'} . ' Mhz</td></tr>';
		$gsput .= "<tr><td>Core power:</td><td>" . $gpus[$i]{'current_core_voltage'} . "v</td></tr>";
		$gsput .= "<tr><td>GPU model:</td><td>" . $gpus[$i]{'desc'}  . "</td></tr>";
	}
	
	$gput .= "</TD></TR>";
	
	my $gpuurl = "?";
	
	if (! $mgpumon eq "")
	{
		$gpuurl .= "mgpumon=$mgpumon&";
	}
	
	$gpuurl .= "gpu=$i";
	
	
	if ($problems)
	{
		$gput = '<TR><TD><font size=5><A href="' . $gpuurl . '">' . $i . '</TD><TD><table><tr><td style="border: 0px; padding: 5px;"><img src=/bamt/error24.png></td>' . $gput;
		$problemgpus++;
	}
	else
	{
		$gput = '<TR><TD><font size=5><A href="' . $gpuurl . '">' . $i . '</TD><TD><table><tr><td style="border: 0px; padding: 5px;"><img src=/bamt/ok24.png></td>' . $gput;
		$okgpus++;
	}
	
	$g1put .= $gput;
	$problems = 0;
}


# EXTRA CONTROLS
my $runtime = `ps -eo etime,command | grep [c]gminer`;
if ($runtime =~ /^\s+(.*?):\d+\s+\S+/) {
  $cgrt = $1;
  $cgrt =~ s/[\-]/ days, /;  
  $cgrt =~ s/$cgrt/$cgrt min/ if (length $cgrt < 3);
  $cgrun = "<td>$cgrt</td>";
} else { 
  $cgrun = "<td class='error'>Stopped</td>";
}
$mcontrol .= "<table>";
$mcontrol .= "<tr><td>Miner control:</td>"; 
$mcontrol .= "<td><form name='mstop' action='poolmanage.pl' method='text'><input type='hidden' name='mstop' value='stop'><input type='submit' value='Stop' onclick='this.disabled=true;this.form.submit();' ></form></td>";
$mcontrol .= "<td><form name='mstart' action='poolmanage.pl' method='text'><input type='hidden' name='mstart' value='start'><input type='submit' value='Start' onclick='this.disabled=true;this.form.submit();' ></form></td>";
$mcontrol .= "<td>Miner run time:</td>$cgrun";
$mcontrol .= "</tr></table><br>";
$p1sum .= "<table id='pcontent'>";
$p1sum .= "<TR class='ghdr'><TD class='ghdr'>Pool</TD>";
$p1sum .= "<TD class='ghdr'>Active</TD>";
$p1sum .= "<TD class='ghdr'>Prio</TD>";
$p1sum .= "<TD class='ghdr'>Pool URL</TD>";
$p1sum .= "<TD class='ghdr'>Worker</TD>";
$p1sum .= "<TD class='ghdr'>Status</TD>";
$p1sum .= "<TD class='ghdr' colspan=2>Accept/Reject</TD>";
$p1sum .= "</TR>";

my @poolmsg;
my $g0url = $gpus[0]{'pool_url'}; 
my @pools = &getCGMinerPools(1);
if (@pools) { 
  for (my $i=0;$i<@pools;$i++) {
    $pimg = "<form name='pselect' action='poolmanage.pl' method='text'><input type='hidden' name='swpool' value='$i'><input type='submit' value='Switch'> </form>";
    $pnum = ${@pools[$i]}{'poolid'};
    $pname = ${@pools[$i]}{'url'};
    $pimg = "<img src='/bamt/ok24.png'>" if ($g0url eq $pname);
    $pusr = ${@pools[$i]}{'user'};
    $pstat = ${@pools[$i]}{'status'};
    if ($pstat eq "Dead") {
      $pstatus = "<td class='error'>" . $pstat . "</td>" 
    } else {
      $pstatus = "<td>" . $pstat . "</td>";
    }
    $pimg = "<img src='/bamt/error24.png'>" if ($pstat ne "Alive");
    $ppri = ${@pools[$i]}{'priority'};
    $pimg = "<img src='/bamt/timeout32.png'>" if (($g0url ne $pname)&&(($ppri eq 0)&&($pstat eq "Alive")));
    $pacc = ${@pools[$i]}{'accepted'};
    $prej = ${@pools[$i]}{'rejected'};
    if ($prej ne "0") {
        $prr = sprintf("%.2f", $prej / ($pacc + $prej)*100);
    } else { 
	$prr = "0.0";
    }
    if ($prr >= 5) { 
	$prat = "<td class='error'>" . $prr . "%</td>";
      } else { 
        $prat = "<td>" . $prr . "%</td>";
      }

    if ($showpool == $i) { 
      push(@poolmsg, "Reject ratio is too high") if ($prr >= 5); 
      push(@poolmsg, "Pool is dead") if ($pstat eq "Dead");
      $psgw = ${@pools[$i]}{'getworks'};
      $psw = ${@pools[$i]}{'works'}; 
      $psd = ${@pools[$i]}{'discarded'}; 
      $pss = ${@pools[$i]}{'stale'}; 
      $psgf = ${@pools[$i]}{'getfails'}; 
      $psrf = ${@pools[$i]}{'remotefailures'};
      if ($g0url eq $pname) {
	$current = "<font size=4>Active</font>";
      } else { 
	$current = "<font size=4>Not Active</font>";
      }
      $psput .= "<tr><td>$current</td>";
      if ($g0url ne $pname) {
      $psput .= "<td><form name='pdelete' action='poolmanage.pl' method='text'><input type='hidden' name='delpool' value='$i'><input type='submit' value='Remove this pool'> </form></td></tr>";
      }
      $psput .= "<tr><td>Mining URL:</td><td>" . $pname . "</td></tr>";
      $psput .= "<tr><td>Worker:</td><td>" . $pusr . "</td></tr>";
      $psput .= "<tr><td>Priority:</td><td>" . $ppri . "</td></tr>";
      $psput .= "<tr><td>Status:</td>" . $pstatus . "</tr>";
      $psput .= "<tr><td>Shares A/R:</td><td>" . $pacc . " / " . $prej . "</td></tr>";
      $psput .= "<tr><td>Getworks:</td><td>" . $psgw . "</td></tr>";
      $psput .= "<tr><td>Works:</td><td>" . $psw . "</td></tr>";
      $psput .= "<tr><td>Discarded:</td><td>" . $psd . "</td></tr>";
      $psput .= "<tr><td>Stale:</td><td>" . $pss . "</td></tr>";
      $psput .= "<tr><td>Get Failures:</td><td>" . $psgf . "</td></tr>";
      $psput .= "<tr><td>Remote Failures:</td><td>" . $psrf . "</td></tr>";
    } else {
      my $purl = "?";
      $purl .= "pool=$i";
      $psum .= '<TR><TD><font size=5><A href="' . $purl . '">' . $i . '</TD>';
      $psum .= "<td>" . $pimg . "</td>";
      $psum .= "<td>" . $ppri . "</td>";
      $psum .= "<td>" . $pname . "</td>";
      $psum .= "<td>" . $pusr . "</td>";
      $psum .= $pstatus;
      $psum .= "<td>" . $pacc . " / " . $prej . "</td>";
      $psum .= $prat;
    }
  }
} else { 
    $psum .= "<TR><TD colspan='7'><big>Active Pool Information Unavailable</big></td></tr>";
}
$p1sum .= $psum;
$p1add .= "<tr>";
$p1add .= "<form name='padd' action='poolmanage.pl' method='text'>";
$p1add .= "</td><td colspan='2'><input type='submit' value='Add'>"; 
$p1add .= "</td><td colspan='2'><input type='text' size='45' placeholder='MiningURL:portnumber' name='npoolurl' required>";
$p1add .= "</td><td colspan='2'><input type='text' placeholder='username.worker' name='npooluser' required>";
$p1add .= "</td><td colspan='2'><input type='text' size='15' placeholder='worker password' name='npoolpw'>";
$p1add .= "</td></form></tr>";
$p1add .= "</table><br>";
$p1sum .= $p1add;
# END EXTRA CONTROLS

print "<div id='overview'>";

print "<table><TR><TD id='overviewlogo'><IMG src='/IFMI/IFMI-logo-small.png'></TD>";

print "<TD id='overviewhash'><b>" . $conf{'settings'}{'miner_id'} . "</b><br><font size=6>";
print sprintf("%.2f", $tot_mhash / 1000);
print " Mh/s</font></TD>";
print "<TD id='overviewshares'> $tot_accept total accepted shares<br>";
print" $tot_invalid total rejected shares<br>";
if ($tot_accept)
{
 print sprintf("%.3f%%", $tot_invalid / ($tot_accept + $tot_invalid)*100);
 print " reject ratio";
}

print "<TD id='overviewgpus'>";

print @gpus . "";
if (@gpus == 1)
{
	print " GPU configured<br>";
}
else
{
	print " GPUs configured<br>";
}

print $okgpus;
if ($okgpus == 1)
{
	print " GPU is OK<br>";
}
else
{
	print " GPUs are OK<br>";
}

print $problemgpus;
if ($problemgpus == 1)
{
	print " GPU has problems";
}
else
{
	print " GPUs have problems";
}

print "</td>";

if (! $mgpumon eq "")
{
	print "<td><A href=$mgpumon>Back to mgpumon..</A></td>";
}

# EXTRA HEADER STATS
print "<TD id='overviewsys'>";
my $uptime = `uptime`;
$rigup = $1 if ($uptime =~ /up\s+(.*?),\s+\d+\s+users,/);
$rigload = $1 if ($uptime =~ /average:\s+(.*?),/);
my $memfree = `cat /proc/meminfo | grep MemFree`; 
$rmem = $1 if ($memfree =~ /^MemFree:\s+(.*?)\s+kB$/);
$rigmem = sprintf("%.3f", $rmem / 1000000);  
print "System Uptime: $rigup<br>";
print "CPU Load: $rigload<br>";
print "Mem free: $rigmem GB<br>";
# END EXTRA STATS

print "</TR></table></div>";

print "<div id=content>";

if ($showgpu > -1)
	{
	print "<div id='showgpu'>";

	print "<A HREF=?";
	
	if (! $mgpumon eq "")
	{
		$gpuurl .= "mgpumon=$mgpumon&";
	}
	
	print "tok=1> << Back to overview</A>";
	
	print "<P>";
	
	print "<table>";
	
	print "<tr><td id='showgpustats'>";
	
	print "<table><tr><td width=200px>";
	
	print "<font size=5>GPU $showgpu<br>";
	
	print sprintf("%d", $gpus[$showgpu]{'hashrate'}) . " Kh/s";	
	
	print "</font><P>";
	
	if (@gpumsg)
	{
		print "<img src='/bamt/error.png'><p>";
		
		foreach my $l (@gpumsg)
		{
			print "$l<br>";
		}
	}
	else
	{
		print "<img src='/bamt/ok.png'><p>";
		print "All parameters OK";
	}
	
	print "</td><td><table>$gsput</table></td></tr></table>";
	print "</td>";
	
	print "<td><img src='/munin/" .  $conf{'settings'}{'miner_id'} .'/'. $conf{'settings'}{'miner_id'} . "/gpuhash$showgpu-day.png'></td></tr>";
	
	print "<tr><td style='vertical-align: bottom;'><img src='/munin/" .  $conf{'settings'}{'miner_id'} .'/'. $conf{'settings'}{'miner_id'} . "/gputemp$showgpu-day.png'></td>";
	
	print "<td><img src='/munin/" .  $conf{'settings'}{'miner_id'} .'/'. $conf{'settings'}{'miner_id'} . "/gpushares$showgpu-day.png'></td></tr></table>";
	
	print "</div>";
}
elsif ($showpool > -1)  
{
        print "<div id='showgpu'>";
        print "<A HREF=?";
        print "tok=1> << Back to overview</A>";
        print "<P><table>";
        print "<tr><td id='showgpustats'>";
        print "<table><tr><td width=200px>";
        print "<font size=5>Pool $showpool<br>";
        my $psacc = ${@pools[$showpool]}{'accepted'};
        my $psrej = ${@pools[$showpool]}{'rejected'};
	if ($psacc ne "0") { 
 	  print sprintf("%.2f%%", $psrej / ($psacc + $psrej)*100);
          print "</font><br> reject ratio";
	} else {
	  print "0</font><br>Shares submitted";
	}
        if (@poolmsg)
        {
                print "<p><img src='/bamt/error.png'><p>";
                foreach my $l (@poolmsg)
                {
                        print "$l<br>";
                }
        }
        else
        {
                print "<p><img src='/bamt/ok.png'><p>";
                print "All parameters OK";
        }
        print "</td><td><table>$psput</table></td></tr></table>";
        print "</td></table></div>";

}
else 
{
	print "<div class='gpudata'>";
	
        print $mcontrol;	

        print $p1sum;
	
	print "<table>";

        print $g1put;
	
	print "</table>";
	
	print "</div>";
	
	print "<div id=gpugraphs>";
	
	print "<table id=graphs>";
	print "<tr><td>";
	
	my $img = $conf{'settings'}{'miner_id'} . '/' . $conf{'settings'}{'miner_id'} . '/gpuhash_all-day.png';
	
	if (-e '/tmp/munin/html/' . $img)
	{
		print "<img src='/munin/" . $img . "'>";
	}
	else
	{
		print "<font style='color: #999999; font-size: 10px;'>Hash summary graph not available yet.<br>It can take up to 10 minutes for graphs to be created<br>after a restart or node name change.";
	}
	
	print "</td><td>";
	
	my $img = $conf{'settings'}{'miner_id'} . '/' . $conf{'settings'}{'miner_id'} . '/gputemp_all-day.png';
	
	if (-e '/tmp/munin/html/' . $img)
	{
		print "<img src='/munin/" . $img . "'>";
	}
	else
	{
		print "<font style='color: #999999; font-size: 10px;'>Temperature summary graph not available yet.<br>It can take up to 10 minutes for graphs to be created<br>after a restart or node name change.";
	}
	
	print "</td></tr></table>";
	print "</div>";
	
	print "<P><A href='/munin/" . $conf{'settings'}{'miner_id'} . "/index.html'>More system stats (munin)...</A>";
}



print "<p>Powered by <br><a href='http://guiminer.net/bamt' target=_blank><img src='/bamt/bamt_small.png'></a>";

print "</body></html>";

