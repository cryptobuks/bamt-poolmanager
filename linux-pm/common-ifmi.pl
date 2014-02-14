#!/usr/bin/perl

#    This file is part of PoolManager.
#
#    PoolManager is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License
#    along with BAMT.  If not, see <http://www.gnu.org/licenses/>.
#

$SIG{__DIE__} = sub { &handleDeath(@_); };

use Data::Dumper;
use Socket;
use IO::Handle;
use YAML qw( DumpFile LoadFile );
use LWP::UserAgent;

use JSON::XS;
use JSON::RPC::Client;
use IO::Socket::INET;
use Sys::Hostname;
use Sys::Syslog qw( :DEFAULT setlogsock);
use POSIX;
use feature qw(switch);

setlogsock('unix');

# Really? right here? 

sub saveConfig 
{
 my $savefile = $_[0];
 my $conf = &getConfig;
 %conf = %{$conf};
 $savefile = "/etc/bamt/cgminer.conf" if ($savefile eq "");
  if (-e $savefile) { 
   $bkpfile = $savefile . "-bkp";
   rename $savefile, $bkpfile; 
  }
   &blog("saving config to $savefile...");
   if (${$conf}{'settings'}{'cgminer'})
   {
         my $cgport = 4028;
         if (defined(${$conf}{'settings'}{'cgminer_port'}))
         {
                 $cgport = ${$conf}{'settings'}{'cgminer_port'};
         }
         my $sock = new IO::Socket::INET (
                                  PeerAddr => '127.0.0.1',
                                  PeerPort => $cgport,
                                  Proto => 'tcp',
                                  ReuseAddr => 1,
                                  Timeout => 10,
                                 );
        if ($sock)
        {
        &blog("sending save command to cgminer api");
	print $sock "save|$savefile";
                my $res = "";
                while(<$sock>)
                {
                        $res .= $_;
                }
                close($sock);
	        &blog("success!");
        }
        else
        {
                &blog("failed to get socket for cgminer api");
        }
    }
}

sub switchPool 
{
 my $conf = &getConfig;
 %conf = %{$conf};
 my $preq = $_[0];
   &blog("switching to pool $preq ...");
   if (${$conf}{'settings'}{'cgminer'})
   {
         my $cgport = 4028;
         if (defined(${$conf}{'settings'}{'cgminer_port'}))
         {
                 $cgport = ${$conf}{'settings'}{'cgminer_port'};
         }
         my $sock = new IO::Socket::INET (
                                  PeerAddr => '127.0.0.1',
                                  PeerPort => $cgport,
                                  Proto => 'tcp',
                                  ReuseAddr => 1,
                                  Timeout => 10,
                                 );
        if ($sock)
        {
        &blog("sending switchpool command to cgminer api");
        print $sock "switchpool|$preq\n"; 
                my $res = "";
                while(<$sock>)
                {
                        $res .= $_;
                }
                close($sock);
	        &blog("success!");
        }
        else
        {
                &blog("failed to get socket for cgminer api");
        }
    }
}

sub quotaPool 
{
 my $conf = &getConfig;
 %conf = %{$conf};
 my $preq = $_[0];
 my $pqta = $_[1];
   &blog("setting quota on pool $preq to $pqta ...");
   if (${$conf}{'settings'}{'cgminer'})
   {
         my $cgport = 4028;
         if (defined(${$conf}{'settings'}{'cgminer_port'}))
         {
                 $cgport = ${$conf}{'settings'}{'cgminer_port'};
         }
         my $sock = new IO::Socket::INET (
                                  PeerAddr => '127.0.0.1',
                                  PeerPort => $cgport,
                                  Proto => 'tcp',
                                  ReuseAddr => 1,
                                  Timeout => 10,
                                 );
        if ($sock)
        {
        &blog("sending poolquota command to cgminer api");
        print $sock "poolquota|$preq,$pqta"; 
                my $res = "";
                while(<$sock>)
                {
                        $res .= $_;
                }
                close($sock);
	        &blog("success!");
        }
        else
        {
                &blog("failed to get socket for cgminer api");
        }
    }
}

sub addPool 
{
 my $conf = &getConfig;
 %conf = %{$conf};
 my $purl = $_[0];
 my $puser = $_[1];
 my $ppw = $_[2];
 $ppw = " " if ($ppw eq "");   
   &blog("adding new pool ...");
   if (${$conf}{'settings'}{'cgminer'})
   {
         my $cgport = 4028;
         if (defined(${$conf}{'settings'}{'cgminer_port'}))
         {
                 $cgport = ${$conf}{'settings'}{'cgminer_port'};
         }
         my $sock = new IO::Socket::INET (
                                  PeerAddr => '127.0.0.1',
                                  PeerPort => $cgport,
                                  Proto => 'tcp',
                                  ReuseAddr => 1,
                                  Timeout => 10,
                                 );
        if ($sock)
        {
        &blog("sending addpool command to cgminer api");
        print $sock "addpool|$purl,$puser,$ppw"; 
                my $res = "";
                while(<$sock>)
                {
                        $res .= $_;
                }
                close($sock);
	        &blog("success!");
        }
        else
        {
                &blog("failed to get socket for cgminer api");
        }
    }
}

sub delPool 
{
 my $conf = &getConfig;
 %conf = %{$conf};
 my $delreq = $_[0];
   &blog("deleting pool $delreq ...");
   if (${$conf}{'settings'}{'cgminer'})
   {
         my $cgport = 4028;
         if (defined(${$conf}{'settings'}{'cgminer_port'}))
         {
                 $cgport = ${$conf}{'settings'}{'cgminer_port'};
         }
         my $sock = new IO::Socket::INET (
                                  PeerAddr => '127.0.0.1',
                                  PeerPort => $cgport,
                                  Proto => 'tcp',
                                  ReuseAddr => 1,
                                  Timeout => 10,
                                 );
        if ($sock)
        {
        &blog("sending removepool command to cgminer api");
        print $sock "removepool|$delreq\n"; 
                my $res = "";
                while(<$sock>)
                {
                        $res .= $_;
                }
                close($sock);
	        &blog("success!");
        }
        else
        {
                &blog("failed to get socket for cgminer api");
        }
    }
}


# Thanks~

sub getConfig
{
 my $c;

 $c = LoadFile('/etc/bamt/bamt.conf');

 return($c);
}


sub getGPUConfig
{
 my ($gpu) = @_;
 
 my $conf = &getConfig;
 %conf = %{$conf}; 

 return($conf{'gpu'.$gpu});

}


sub getMomTmp
{
 if (-e '/tmp/mother.tmp')
 {
        my $c = LoadFile('/tmp/mother.tmp');
        return($c);
 }
 return({ gendesktop => 0, lastrun => time });
}


sub putMomTmp
{	
 my (%c) = @_;

 DumpFile( "/tmp/mother.tmp" , \%c );
}


# cached data
sub getCachedGPUData
{
 my ($su) = @_;
 
 my $fn = "/tmp/gpu.tmp." . $>;
 
 if (-e $fn)
 {
 	 my $gtime = (stat($fn))[9];
 
 	 # cache for 60 seconds (ignore the future)
 	 if ((time - $gtime < 60) && ! ( $gtime > time))
 	 {
 	 	 my @c = LoadFile($fn);
 	 	 
 	 	 # seems insane, but whatevr
 	 	 my @b;
 	 	 for ($k = 0;$k < @{$c[0]}; $k++)
 	 	 {
 	 	 	 push(@b, ${$c[0]}[$k]);
 	 	 }
 	 	 
 	 	 return(@b);
 	 }
 }
 
 my @c = &getFreshGPUData($su);
 putGPUTmp(@c);
 return(@c);
}


sub putGPUTmp
{
 my (@c) = @_;

 DumpFile( "/tmp/gpu.tmp.".$> , \@c );
}


sub getGPUData
{
	my ($su) = @_;
	
	return(&getFreshGPUData($su));
}

sub getFreshGPUData
{
	my ($su) = @_;

	my @gpus;

	my $uptime = `uptime`;
	chomp($uptime);
	
	my $res = `DISPLAY=:0.0 /usr/local/bin/atitweak -s`;

	my $conf = &getConfig;
    %conf = %{$conf}; 
	
	my @cgpools;
    
	if (${$conf}{settings}{cgminer})
	{
		# cgminer gather pools
		@cgpools = getCGMinerPools();			
	}

	#monster regex for atitweak        
	while ($res =~ m/(\d)\.\s(.*?)\s+\(:(.*?)\)\n.*?engine\sclock\s(\d+)MHz,\smemory\sclock\s(\d+)MHz,\score\svoltage\s([\d\.]+)VDC,\sperformance\slevel\s(\d+?),\sutilization\s(\d+)\%\n(.*?)\n.*temperature\s([\d\.]+)\sC\n.*?powertune\s(\d+)\%/gm) 
	{
		my $gpu = $1;
		$gpus[$gpu] = ({ desc => $2, display => $3, current_core_clock => $4, current_mem_clock=>$5, current_core_voltage=>$6, current_performance_level => $7, current_load=>$8, current_temp_0=>$10, current_powertune=>$11 });


		if ($9 =~ m/.*fan\sspeed\s(\d+)\%\s\((\d+)\sRPM\)/)
		{
		  $gpus[$gpu]{fan_speed} = $1;
		  $gpus[$gpu]{fan_rpm} = $2;
		}
		else
		{
		 $gpus[$gpu]{fan_speed} = "na";
		 $gpus[$gpu]{fan_rpm} = "na";
		}

		# mining data
		
		my $gc = &getGPUConfig($gpu);
		
		if (! ${$gc}{'disabled'})
		{
			
			if (${$gc}{'cgminer'})
			{
				# cgminer gather
				${$gpus[$gpu]}{miner} = 'cgminer';
				&getCGMinerStats($gpu, \%{$gpus[$gpu]}, @cgpools );
				
			}
			
		}
		else
		{
			${$gpus[$gpu]}{pool_url} = 'GPU is disabled in config';
			${$gpus[$gpu]}{status} = 'disabled';
		}
		
		# system info
		${$gpus[$gpu]}{uptime} = $uptime;

		# monitoring
	
		if (!defined(${$gc}{'disabled'}) || (${$gc}{'disabled'} == 0))
		{		
                
			if (defined(${$gc}{'monitor_fan_lo'}))
			{
				if (isdigit($gpus[$gpu]{fan_rpm}))
				{
					if ($gpus[$gpu]{fan_rpm} <  ${$gc}{'monitor_fan_lo'})
					{
						$gpus[$gpu]{fault_fan_lo} = ${$gc}{'monitor_fan_lo'} . '|' . $gpus[$gpu]{fan_rpm};
					}
				}
			}               
			
			if (defined(${$gc}{'monitor_load_lo'}))
			{
				if ($gpus[$gpu]{current_load} <  ${$gc}{'monitor_load_lo'})
				{
					$gpus[$gpu]{fault_load_lo} = ${$gc}{'monitor_load_lo'} . '|' . $gpus[$gpu]{current_load};
				}
			}
		
			if (defined(${$gc}{'monitor_hash_lo'}) && defined($gpus[$gpu]{hashrate}))
			{
				if ($gpus[$gpu]{hashrate} < ${$gc}{'monitor_hash_lo'})
				{
					$gpus[$gpu]{fault_hash_lo} = ${$gc}{'monitor_hash_lo'} . '|' . $gpus[$gpu]{hashrate};
				}
			}
			
			if (defined(${$gc}{'monitor_reject_hi'}))
			{
				if ($gpus[$gpu]{'shares_accepted'})
				{
					my $rr = $gpus[$gpu]{'shares_invalid'}/($gpus[$gpu]{'shares_accepted'} + $gpus[$gpu]{'shares_invalid'}) * 100;		
			
					if ($rr > ${$gc}{'monitor_reject_hi'})
					{
						$gpus[$gpu]{fault_reject_hi} = ${$gc}{'monitor_reject_hi'} . '|' . $rr;
					}
				}
			}
		
			if (defined(${$gc}{'monitor_temp_lo'}))
			{
				if ($gpus[$gpu]{current_temp_0} < ${$gc}{'monitor_temp_lo'})
				{
					$gpus[$gpu]{fault_temp_lo} = ${$gc}{'monitor_temp_lo'} . '|' . $gpus[$gpu]{current_temp_0};
				}
			}
		
			if (defined(${$gc}{'monitor_temp_hi'}))
			{
				if ($gpus[$gpu]{current_temp_0} > ${$gc}{'monitor_temp_hi'})
				{
					$gpus[$gpu]{fault_temp_hi} = ${$gc}{'monitor_temp_hi'} . '|' . $gpus[$gpu]{current_temp_0};
				}
			
			}
		
        }
                
        
    }
        
       	
 
    return(@gpus);
}

sub getCGMinerPools
{	 
	my @pools;
	
	my $conf = &getConfig;
    	%conf = %{$conf}; 
    
	my @version = &getCGMinerVersion;
	if (@version) {
  	  for (my $i=0;$i<@version;$i++) {
	    $avers = ${$version[$i]}{'api'};
  	  }
	} else { 
	  $avers = "0";
	}

  my $cgport = 4028;
 	if (defined(${$conf}{'settings'}{'cgminer_port'}))
 	{
 	  $cgport = ${$conf}{'settings'}{'cgminer_port'};
 	}
    
	my $sock = new IO::Socket::INET (
                                  PeerAddr => '127.0.0.1',
                                  PeerPort => $cgport,
                                  Proto => 'tcp',
                                  ReuseAddr => 1,
                                  Timeout => 10,
                                 );
    
    if ($sock)
    {
    	print $sock "pools|\n";
    
		my $res = "";
		
		while(<$sock>) 
		{
			$res .= $_;
		}
		
		close($sock);
	
      # Per https://github.com/ckolivas/cgminer/blob/master/API-README		
    	if ($avers > 7) {
    	  while ($res =~ m/\|POOL=(\d+),URL=(.+?),Status=(.+?),Priority=(\d+),Quota=(\d+),Long Poll=(.+?),Getworks=(\d+),Accepted=(\d+),Rejected=(\d+),Works=(\d+),Discarded=(\d+),Stale=(\d+),Get Failures=(\d+),Remote Failures=(\d+),User=(.+?),/g)
    	  {
    	  push(@pools, ({ poolid=>$1, url=>$2, status=>$3, priority=>$4, quota=>$5, lp=>$6, getworks=>$7, accepted=>$8, rejected=>$9, works=>$10, discarded=>$11, stale=>$12, getfails=>$13, remotefailures=>$14, user=>$15 }) );
    	  }
    	} else { 
    	  while ($res =~ m/\|POOL=(\d+),URL=(.+?),Status=(.+?),Priority=(\d+),Quota=(\d+),Long Poll=(.+?),Getworks=(\d+),Accepted=(\d+),Rejected=(\d+),Works=(\d+),Discarded=(\d+),Stale=(\d+),Get Failures=(\d+),Remote Failures=(\d+),/g)
    	  {
    	  push(@pools, ({ poolid=>$1, url=>$2, status=>$3, priority=>$4, quota=>$5, lp=>$6, getworks=>$7, accepted=>$8, rejected=>$9, works=>$10, discarded=>$11, stale=>$12, getfails=>$13, remotefailures=>$14 }) );
    	  }

    	}

    }
	
	return(@pools);
		
}

sub getCGMinerStats
{
	my ($gpu, $data, @pools) = @_;
    
    my $conf = &getConfig;
    %conf = %{$conf}; 
    
    my $cgport = 4028;
 	if (defined(${$conf}{'settings'}{'cgminer_port'}))
 	{
 	  $cgport = ${$conf}{'settings'}{'cgminer_port'};
 	}
    
	my $sock = new IO::Socket::INET (
                                  PeerAddr => '127.0.0.1',
                                  PeerPort => $cgport,
                                  Proto => 'tcp',
                                  ReuseAddr => 1,
                                  Timeout => 10,
                                 );
    
    if ($sock)
    {
    	print $sock "gpu|$gpu\n";
    
		my $res = "";
		
		while(<$sock>) 
		{
			$res .= $_;
		}
		
		close($sock);
	
		if ($res =~ m/.*,MHS\sav=(\d+\.\d+),*/)
		{
			$data->{'hashrate'} = $1 * 1000;
		}
		
		if ($res =~ m/.*,Accepted=(\d+),.*/)
		{
			$data->{'shares_accepted'} = $1;
		}
		
		if ($res =~ m/.*,Rejected=(\d+),.*/)
		{
			$data->{'shares_invalid'} = $1;
		}
		
		if ($res =~ m/.*,Status=(.+?),.*/)
		{
			$data->{'status'} = $1;
		}
		
		if ($res =~ m/.*,Hardware\sErrors=(\d+),.*/)
		{
			$data->{'hardware_errors'} =$1;
		}

		if ($res =~ m/.*,Intensity=(\d+),.*/)
		{
			$data->{'intensity'} =$1;
		}
		
		if ($res =~ m/.*,Last\sShare\sPool=(\d+),.*/)
		{
			
			foreach $p (@pools)
			{
				
				if (${$p}{poolid} == $1)
				{
					$data->{'pool_url'} =${$p}{url};
				}
			}
			
		}
		
		if ($res =~ m/.*,Last\sShare\sTime=(\d+),.*/)
		{
			$data->{'last_share_time'} =$1;
		}
		
		
	}
	else
	{
		$url = "cgminer socket failed";
	}
	
}


# Oh hi! I cant believe this didnt exist yet..
sub getCGMinerVersion
{
    my $conf = &getConfig;
    %conf = %{$conf};

    my $cgport = 4028;
        if (defined(${$conf}{'settings'}{'cgminer_port'}))
        {
          $cgport = ${$conf}{'settings'}{'cgminer_port'};
        }

        my $sock = new IO::Socket::INET (
                                  PeerAddr => '127.0.0.1',
                                  PeerPort => $cgport,
                                  Proto => 'tcp',
                                  ReuseAddr => 1,
                                  Timeout => 10,
                                 );

    if ($sock)
    {

        print $sock "version|\n";

                my $res = "";

                while(<$sock>)
                {
                        $res .= $_;
                }

                close($sock);

#This will need to be changed if the API is ever changed to v2.x v0.7 should return null 
        while ($res =~ m/CGMiner=(\d+\.\d+\.\d+),API=1\.(\d+)/g) 
        {
          push(@version,({ miner=>$1, api=>$2 }) );
        }

        return(@version);

    }
    else
    {
        $url = "cgminer socket failed";
    }

}

sub getCGMinerSummary
{    
    my $conf = &getConfig;
    %conf = %{$conf}; 

    my @version = &getCGMinerVersion;
    if (@version) {
        for (my $i=0;$i<@version;$i++) {
        $avers = ${$version[$i]}{'api'};
        }
    } else { 
      $avers = "0";
    }
 
    my $cgport = 4028;
 	if (defined(${$conf}{'settings'}{'cgminer_port'}))
 	{
 	  $cgport = ${$conf}{'settings'}{'cgminer_port'};
 	}
    
	my $sock = new IO::Socket::INET (
                                  PeerAddr => '127.0.0.1',
                                  PeerPort => $cgport,
                                  Proto => 'tcp',
                                  ReuseAddr => 1,
                                  Timeout => 10,
                                 );
    
    if ($sock)
    {
    	print $sock "summary|\n";
    
		my $res = "";
		
		while(<$sock>) 
		{
			$res .= $_;
		}
		
		close($sock);

    # Per https://github.com/ckolivas/cgminer/blob/master/API-README
    # Not pulling any data added in 1.28, so not testing for it.  
    given ($x) {
      when ($avers >= 31) {
        while ($res =~ m/.*,Elapsed=(\d+),MHS\sav=(\d+\.\d+),MHS\s\ds=(\d+\.\d+),Found\sBlocks=(\d+),Getworks=(\d+),Accepted=(\d+),Rejected=(\d+),Hardware\sErrors=(\d+),Utility=(.+?),Discarded=(\d+),Stale=(\d+),Get\sFailures=(\d+),Local\sWork=(\d+),Remote\sFailures=(\d+),Network\sBlocks=(\d+),Total\sMH=(.*?),Work\sUtility=(\d+\.\d+),Difficulty\sAccepted=(\d+\.\d+),Difficulty\sRejected=(\d+\.\d+),Difficulty\sStale=(\d+\.\d+),Best\sShare=(\d+),/g)
        {
          push(@summary,({ elapsed=>$1, hashavg=>$2, hashrate=>$3, found_blocks=>$4, getworks=>$5, shares_accepted=>$6, shares_invalid=>$7, hardware_errors=>$8, utility=>$9, discarded=>$10, stale=>$11, get_failures=>$12, local_work=>$13, remote_failures=>$14, network_blocks=>$15, total_mh=>$16, work_utility=>$17, diff_accepted=>$18, diff_rejected=>$19, diff_stale=>$20, best_share=>$21 }) );
        }
      }
      when ($avers >= 21) {
        while ($res =~ m/.*,Elapsed=(\d+),MHS\sav=(\d+\.\d+),Found\sBlocks=(\d+),Getworks=(\d+),Accepted=(\d+),Rejected=(\d+),Hardware\sErrors=(\d+),Utility=(.+?),Discarded=(\d+),Stale=(\d+),Get\sFailures=(\d+),Local\sWork=(\d+),Remote\sFailures=(\d+),Network\sBlocks=(\d+),Total\sMH=(.*?),Work\sUtility=(\d+\.\d+),Difficulty\sAccepted=(\d+\.\d+),Difficulty\sRejected=(\d+\.\d+),Difficulty\sStale=(\d+\.\d+),Best\sShare=(\d+),/g)
        {
          push(@summary,({ elapsed=>$1, hashavg=>$2, found_blocks=>$3, getworks=>$4, shares_accepted=>$5, shares_invalid=>$6, hardware_errors=>$7, utility=>$8, discarded=>$9, stale=>$10, get_failures=>$11, local_work=>$12, remote_failures=>$13, network_blocks=>$14, total_mh=>$15, work_utility=>$16, diff_accepted=>$17, diff_rejected=>$18, diff_stale=>$19, best_share=>$20 }) );
        }
      }
      when ($avers >= 17) {
        while ($res =~ m/.*,Elapsed=(\d+),MHS\sav=(\d+\.\d+),Found\sBlocks=(\d+),Getworks=(\d+),Accepted=(\d+),Rejected=(\d+),Hardware\sErrors=(\d+),Utility=(.+?),Discarded=(\d+),Stale=(\d+),Get\sFailures=(\d+),Local\sWork=(\d+),Remote\sFailures=(\d+),Network\sBlocks=(\d+),Total\sMH=(.*?),Work\sUtility=(\d+\.\d+),Difficulty\sAccepted=(\d+\.\d+),Difficulty\sRejected=(\d+\.\d+),Difficulty\sStale=(\d+\.\d+),/g)
        {
          push(@summary,({ elapsed=>$1, hashavg=>$2, found_blocks=>$3, getworks=>$4, shares_accepted=>$5, shares_invalid=>$6, hardware_errors=>$7, utility=>$8, discarded=>$9, stale=>$10, get_failures=>$11, local_work=>$12, remote_failures=>$13, network_blocks=>$14, total_mh=>$15, work_utility=>$16, diff_accepted=>$17, diff_rejected=>$18, diff_stale=>$19 }) );
        }
      }
      when ($avers >= 3) {
        while ($res =~ m/.*,Elapsed=(\d+),MHS\sav=(\d+\.\d+),Found\sBlocks=(\d+),Getworks=(\d+),Accepted=(\d+),Rejected=(\d+),Hardware\sErrors=(\d+),Utility=(.+?),Discarded=(\d+),Stale=(\d+),Get\sFailures=(\d+),Local\sWork=(\d+),Remote\sFailures=(\d+),Network\sBlocks=(\d+),Total\sMH=(.*?),Difficulty\sAccepted=(\d+\.\d+),Difficulty\sRejected=(\d+\.\d+),Difficulty\sStale=(\d+\.\d+),/g)
        {
          push(@summary,({ elapsed=>$1, hashavg=>$2, found_blocks=>$3, getworks=>$4, shares_accepted=>$5, shares_invalid=>$6, hardware_errors=>$7, utility=>$8, discarded=>$9, stale=>$10, get_failures=>$11, local_work=>$12, remote_failures=>$13, network_blocks=>$14, total_mh=>$15, diff_accepted=>$16, diff_rejected=>$17, diff_stale=>$18 }) );
        }
      }
      default {
        while ($res =~ m/.*,Elapsed=(\d+),MHS\sav=(\d+\.\d+),Found\sBlocks=(\d+),Getworks=(\d+),Accepted=(\d+),Rejected=(\d+),Hardware\sErrors=(\d+),Utility=(.+?),Discarded=(\d+),Stale=(\d+),Get\sFailures=(\d+),Local\sWork=(\d+),Remote\sFailures=(\d+),Network\sBlocks=(\d+),Difficulty\sAccepted=(\d+\.\d+),Difficulty\sRejected=(\d+\.\d+),Difficulty\sStale=(\d+\.\d+),/g)
        {
          push(@summary,({ elapsed=>$1, hashavg=>$2, found_blocks=>$3, getworks=>$4, shares_accepted=>$5, shares_invalid=>$6, hardware_errors=>$7, utility=>$8, discarded=>$9, stale=>$10, get_failures=>$11, local_work=>$12, remote_failures=>$13, network_blocks=>$14, diff_accepted=>$15, diff_rejected=>$16, diff_stale=>$17 }) );
        }
      }
    }
    return(@summary);
    } else {
    	$url = "cgminer socket failed";
    }
	
}
# taa taa

sub handleDeath
{
 my ($msg) = @_;
 
 my $pad = "    ";

 print "\n\n\n";
 print $pad . "                 __.....__  \n";
 print $pad . "               .'         ':, \n";
 print $pad . "              /  __  _  __  \\" . "\\ \n";
 print $pad . "              | |_)) || |_))|| \n";
 print $pad . "              | | \\" . "\\ || |   || \n";
 print $pad . "              |             ||   _, \n";
 
 print $pad . "              | ";
 
 my $sn = substr($0, 1 + rindex($0, '/'));
 
 while (length($sn)<11)
 {
 	 if (length($sn) % 2)
 	 {
 	 	 $sn .= " ";
 	 }
 	 else
 	 {
 	 	 $sn = " " . $sn;
 	 }
 }
 
 print $sn;
 
 
 print " ||.-(_{} \n";
 
 print $pad . "              |             |/    `\n";
 print $pad . "              |        ,_ (\;|/) \n";
 print $pad . "            \\" . "\\|       {}_)-,||` \n";
 print $pad . "            \\" . "\\;/,,;;;;;;;,\\". "\\|//, \n";
 print $pad . "           .;;;;;;;;;;;;;;;;,    \n";
 print $pad . "          \,;;;;;;;;;;;;;;;;,//  \n";
 print $pad . "         \\" . "\\;;;;;;;;;;;;;;;;,//  \n";
 print $pad . "        ,\';;;;;;;;;;;;;;;;'   \n";
 print "\n\n";

 print explainError($msg);


 print "\n\n";

 &blog("fatal error: $msg");

 if (! -e '/live/image/BAMT/CONTROL/ACTIVE/noStatus') 
 {
   if (open(FF,">>/live/image/BAMT/STATUS/death.log"))
   {
        print FF  "\n\r" . &getTimestamp . " : A BAMT process was pronounced dead for the following reason:\n\r\n\r$msg\r\n";

 	close(FF);  
   }
   else
   {
 	print "\nDefiled:  Unable to record this travesty in the deathlog!  Why?: " . $! . "\n\n";
   }
 }
 else
 {
   print "(saving autopsy to deathlog is currently disabled)\n";


 }
 

 exit(1);
}




sub explainError
{
 my ($e) = @_;

 my $msg = "   One of the BAMT tools has suffered a fatal error.\n\n\n";

 # things we can explain...
 
 if ($e =~ /^YAML Error\:\s(.+?)\n.*Code\:\s(.+?)\n.*Line:\s(\d+).*/m)
 { 
	$msg .= "There seems to be a formatting problem in your bamt.conf file.\n";
	$msg .= "YAML is picky.  The specific complaint about your file is:\n\n ";
 	$msg .= $1 . " on line " . $3 . "\n";
 }
 elsif ($e=~m/YAML Error: Couldn't open \/etc\/bamt\/bamt\.conf for input\:\\nBad file descriptor\n/m)
 {

   $msg .= "Looks like we can't even find your bamt.conf...  it should be at /etc/bamt/bamt.conf\n\n";
   $msg .= "You will need to find this file and return it to the proper place, or create a new one.";

 }
 else
 {
 	 $msg .= $e;
 }
 
 return($msg);
}


sub setHostname
{
  # set our hostname
  my $conf = &getConfig;
  %conf = %{$conf};

  my $mname = 'bamt-miner';
  
  if ( defined(${$conf{'settings'}}{'miner_id'}))
  {
    $mname = lc(${$conf{'settings'}}{'miner_id'});
  }

  unless (hostname eq $mname)
  {
  	  &blog("setting hostname to $mname");
  	  
     `echo $mname > /etc/hostname`;
     `hostname $mname`;

     #fixup /etcs/hosts... overkill or cause trouble? whatevr.. fail silently for now

     if (open( H, "</etc/hosts"))
     {
       my @hosts = <H>;

       close(H);

       if (open( H, ">/etc/hosts"))
       {
        foreach(@hosts)
        {
          chomp;

          my $line = $_;

          if (!$line eq "")
          {

           if ($line=~ m/^127\.0\.0\.1.+localhost.*/)
           {
             print H "127.0.0.1\t$mname localhost\n";
           }
           else
           {
             print H $line . "\n";
           }
         }
        }

        close(H);

      }
    }
  }
}


sub makeMuninPlugins
{
	my @colors = ("043A6B", "105DAA", "408DD2", "69A4DA", "35D699" ,"00AC6B", "007046", "AAAAAA");
	
	&blog("generating munin config, stopping munin-node");
	
	print "..munin";
	`/etc/init.d/munin-node stop`;
	
	 my $conf = &getConfig;
	 %conf = %{$conf};
	
	 my $mname = lc(${$conf}{settings}{miner_id});
	 
	 # munin config files
    
	 &blog("replace hostname in munin.conf");
	 
     if (open( H, "</etc/munin/munin.conf"))
     {
       my @lines = <H>;

       close(H);

       if (open( H, ">/etc/munin/munin.conf"))
       {
        foreach(@lines)
        {
          chomp;

          my $line = $_;

          if (!$line eq "")
          {

           if ($line=~ m/^\[.*\]$/)
           {
             print H "[$mname]\n";
           }
           else
           {
             print H $line . "\n";
           }
         }
        }
        close(H);
       }
     }
     
     
	 if (open( H, "</etc/munin/munin-node.conf"))
     {
       my @lines = <H>;

       close(H);

       if (open( H, ">/etc/munin/munin-node.conf"))
       {
        foreach(@lines)
        {
          chomp;

          my $line = $_;

          if (!$line eq "")
          {
           if ($line=~ m/^host_name.*/)
           {
             print H "host_name $mname\n";
           }
           else
           {
             print H $line . "\n";
           }
         }
        }
        close(H);
       }
     }     
	
	
	
	&blog("generating munin summary plugins...");
	
	# summary
	if (-e '/etc/munin/plugins/gpuhash_all')
	{
		`rm -f /etc/munin/plugins/gpuhash_all`;
	}
	
	if (-e '/etc/munin/plugins/gputemp_all')
	{
		`rm -f /etc/munin/plugins/gputemp_all`;
	}
	
	if (open( H, ">/etc/munin/plugins/gpuhash_all"))
	{
		print H q^#!/bin/sh
# -*- sh -*-

: << =cut

=head1 NAME

gpuhashall - Plugin to measure hashrate on all gpus

=head1 NOTES

=head1 AUTHOR

=head1 LICENSE

Unknown license

=head1 MAGIC MARKERS

 #%# family=auto
 #%# capabilities=autoconf

=cut

. $MUNIN_LIBDIR/plugins/plugin.sh

if [ "$1" = "autoconf" ]; then
        echo yes 
        exit 0
fi

if [ "$1" = "config" ]; then

        echo 'graph_title GPU Hash Rate Summary'
        echo 'graph_args --base 1000 -l 0 '
        echo 'graph_scale no'
        echo 'graph_vlabel Mhash/sec'
        echo 'graph_category gpu_summary'
^;

		
		for (my $k = 0;$k < 8;$k++)
		{
			if ( defined( ${$conf}{"gpu$k"} ) && ( ! ${$conf}{"gpu$k"}{disabled} == 1))
			{	
				print H "echo 'hashrate" . $k . ".label GPU $k Mhash/sec'\n";
				print H "echo 'hashrate" . $k . ".draw ";
				if ($k == 0)
				{
					print H "AREA'\n";
				}
				else
				{
					print H "STACK'\n";
				}
				print H "echo 'hashrate" . $k . ".colour " . $colors[$k] . "'\n";
			}
		}


print H q^exit 0
fi

/opt/bamt/getgpustat all hashrate 
		^;
		
		close(H);
		
		chmod 0777, '/etc/munin/plugins/gpuhash_all'; 
	}
	
	
		if (open( H, ">/etc/munin/plugins/gputemp_all"))
		{
			print H q|#!/bin/sh
# -*- sh -*-

: << =cut

=head1 NAME

gputempall - Plugin to measure tempon all gpus

=head1 NOTES

=head1 AUTHOR

=head1 LICENSE

Unknown license

=head1 MAGIC MARKERS

 #%# family=auto
 #%# capabilities=autoconf

=cut

. $MUNIN_LIBDIR/plugins/plugin.sh

if [ "$1" = "autoconf" ]; then
        echo yes 
        exit 0
fi

if [ "$1" = "config" ]; then

        echo 'graph_title GPU Temperature Summary'
        echo 'graph_args --base 1000 -l 0 '
        echo 'graph_scale no'
        echo 'graph_vlabel Degrees Celsius'
        echo 'graph_category gpu_summary'
|;

		
		for (my $k = 0;$k < 8;$k++)
		{
			if ( defined( ${$conf}{"gpu$k"} ) && ( ! ${$conf}{"gpu$k"}{disabled} == 1))
			{
				print H "echo 'current_temp_0" . $k . ".label GPU $k Temperature'\n";
				print H "echo 'current_temp_0" . $k . ".draw LINE2'\n";
				print H "echo 'current_temp_0" . $k . ".colour " . $colors[$k] . "'\n";
			}
		}


print H q|
        exit 0
fi

/opt/bamt/getgpustat all current_temp_0 
		|;
		
		close(H);
		
		chmod 0777, '/etc/munin/plugins/gputemp_all'; 
	}
	
	
	
	
	# individual
	if (opendir(DIR, '/opt/bamt/munin'))
	{
		
		while (defined($file = readdir(DIR))) 
		{
			next if $file =~ /^\.\.?$/;
	
			if (open( H, "</opt/bamt/munin/$file"))
			{
				&blog("generating per gpu munin plugins for template $file...");
				
				my @lines = <H>;
				close(H);
				
				`rm -f /etc/munin/plugins/$file?`;
				
				for (my $k = 0;$k < 8;$k++)
				{
					if ( defined( ${$conf}{"gpu$k"} ) && ( ! ${$conf}{"gpu$k"}{disabled} == 1))
					{
						if (open( H, ">/etc/munin/plugins/$file" . $k))
						{
							foreach(@lines)
							{
								chomp;
	
								my $line = $_;
	
								$line =~ s/\$GPU\$/$k/g;
								
								print H $line . "\n";
							}
							
							close(H);
							chmod 0777, "/etc/munin/plugins/$file" . $k;
							
						}
					}
				}
			}	
		}
	}
	
	&blog("done generating munin config, starting munin-node");
	`/etc/init.d/munin-node start`;
}


sub getPCIGPUdata
{
	my @pci = `lspci -mm`;
	
	my @gpus;
	
	foreach $l (@pci)
	{
		if ($l =~ /(..\:..\..)\s\"VGA\scompatible\scontroller\"\s\"(.+?)\"\s\"(.+?)\"\s\"(.+?)\"\s\"(.+?)\"/)
		{
			push (@gpus, ({ pciid => $1, vendor => $2, device=> $3, svendor => $4, sdevice => $5, }) );
		}
	}

	return(@gpus);	

}


1;
