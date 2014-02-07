#!/usr/bin/perl

#    This file is part of BAMT.
#
#    BAMT is free software: you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation, either version 3 of the License, or
#    (at your option) any later version.
#
#    BAMT is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License
#    along with BAMT.  If not, see <http://www.gnu.org/licenses/>.

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
			elsif (${$gc}{'phoenix2'})
			{
				# Phoenix2 gather
				${$gpus[$gpu]}{miner} = 'phoenix2';
				
				&getPhoenix2Stats($gpu, \%{$gpus[$gpu]} );
				
			}
			else
			{
				# Phoenix gather 
				${$gpus[$gpu]}{miner} = 'phoenix';
				${$gpus[$gpu]}{status} = 'enabled';
				
				if (defined(${$gc}{'kernel'}))
				{
					${$gpus[$gpu]}{kernel} = ${$gc}{'kernel'}
				}
				else
				{
					${$gpus[$gpu]}{kernel} = 'phatk2';
				}
				
				if (defined(${$gc}{'kernel_params'}))
				{
					${$gpus[$gpu]}{kernel_params} = ${$gc}{'kernel_params'}
				}
				else
				{
					${$gpus[$gpu]}{kernel_params} = '';
				}
				
				
				if ($su)
				{
				 (${$gpus[$gpu]}{hashrate}, ${$gpus[$gpu]}{shares_accepted}, ${$gpus[$gpu]}{shares_invalid}, ${$gpus[$gpu]}{pool_url}) = &getPhoenixStatsSU($gpu);
				}
				else
				{
				 (${$gpus[$gpu]}{hashrate}, ${$gpus[$gpu]}{shares_accepted}, ${$gpus[$gpu]}{shares_invalid}, ${$gpus[$gpu]}{pool_url}) = &getPhoenixStats($gpu);
				}
				
				${$gpus[$gpu]}{shares_stale} = 0;
				${$gpus[$gpu]}{shares_other} = 0;
				${$gpus[$gpu]}{hashrate_avg} = ${$gpus[$gpu]}{hashrate};
				${$gpus[$gpu]}{gpu_uptime} = 0;
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




sub getPhoenix2Stats
  {
    my ($gpu, $data) = @_;


    
    my $conf = &getConfig;
    %conf = %{$conf}; 
   
     my $p2port = 7780;
 	 if (defined(${$conf}{'settings'}{'phoenix2_port'}))
 	 {
 	 	 $p2port = ${$conf}{'settings'}{'phoenix2_port'};
 	 }
 	 
 	 my $p2pass = 'bamt';
 	 
 	 if (defined(${$conf}{'settings'}{'phoenix2_pass'}))
 	 {
 	 	 $p2pass = ${$conf}{'settings'}{'phoenix2_pass'};
 	 }
    
    
    my $fname = "/tmp/p2cache.gpu$gpu.". $>;
    
    if (-e $fname)
    {
    	my $mtime = (stat($fname))[9];
    	
    	if (time - $mtime < 10)
    	{
    		# cached data..
    		 my $c = LoadFile($fname);
    		 
    		 $data->{'hashrate'} = ($c->{'rate'} / 1000);
    		 $data->{'shares_accepted'} = $c->{'accepted'};
    		 $data->{'shares_invalid'} = $c->{'results'} - $c->{'accepted'} - $c->{'stale'};  # ???
    		 $data->{'shares_stale'} = $c->{'stale'};
    		 $data->{'shares_other'} = $c->{'nothardenough'};
    		 $data->{'pool_url'} = $c->{'url'};
    		 $data->{'kernel'} = $c->{'meta'}->{'kernel'};
    		 $data->{'clid'} = $c->{'id'};
    		 $data->{'family'} = $c->{'meta'}->{'device'};
    		 $data->{'cores'} = $c->{'meta'}->{'cores'};
    		 $data->{'gpu_uptime'} = $c->{'uptime'};
    		 $data->{'status'} = $c->{'status'};
    		 
    		 return;
    	}
    }
    
    # otherwise grab new data
    
    my $client = new JSON::RPC::Client;
 
    $client->ua->credentials( 'localhost:' . $p2port , 'Phoenix RPC', 'user' => $p2pass );
 
    my $uri = 'http://localhost:' . $p2port. '/';
    my $obj = 
    {
      id => '1',
      jsonrpc => '1.0',          
      method  => 'getstatus',
      params  => [] ,
    };
 
    my $res = $client->call( $uri, $obj );
 
    if ($res) 
    {
    	my $r = $res->result();
    	
    	if ($r->{'connection'}->{'connected'}  == 1 )
    	{
    		$data->{'pool_url'} = $r->{'connection'}->{'url'} ;
    	}
    	else
    	{
    		$data->{'pool_url'} = "Not connected";
    	}
    	
    }

    
    $obj =
    {
      id => '1',
      jsonrpc => '1.0',
      method  => 'listdevices',
      params  => [] ,
    };
 
    $res = $client->call( $uri, $obj );
 
    if ($res) 
    { 
    	my $g = 0;
    	foreach $c (@{$res->result()})
    	{
    		
    		if ($g == $gpu)
    		{
				$data->{'hashrate'} = ($c->{'rate'} / 1000);
				$data->{'shares_accepted'} = $c->{'accepted'};
				$data->{'shares_invalid'} = $c->{'results'} - $c->{'accepted'} - $c->{'stale'};  # ???
				$data->{'shares_stale'} = $c->{'stale'};
				$data->{'shares_other'} = $c->{'nothardenough'};
				$data->{'kernel'} = $c->{'meta'}->{'kernel'};
				$data->{'clid'} = $c->{'id'};
				$data->{'family'} = $c->{'meta'}->{'device'};
				$data->{'cores'} = $c->{'meta'}->{'cores'};
				$data->{'gpu_uptime'} = $c->{'uptime'};
				$data->{'status'} = $c->{'status'};
    		}
    		
    		$fname  =  '/tmp/p2cache.gpu' . $g . "." . $> ;
    		
    		$c->{'url'} = $data->{'pool_url'}; 
    		
    		DumpFile( $fname, $c );
    		
    		$g++;
    	}
    }
   
  
  }




sub getPhoenixStats
  {
    my ($gpu) = @_;

    my $hash = 0;
    my $accept = 0;
    my $invalid = 0;
    my $url = 'No connection';

    if (-e "/tmp/phoenix-$gpu.sock")
    {
        socket(TSOCK, PF_UNIX, SOCK_STREAM,0);
        connect(TSOCK, sockaddr_un("/tmp/phoenix-$gpu.sock")) or return(0,0,0);
        my $dat = <TSOCK>;

        if ($dat =~ m/(\d+)\s(\d+)\s(\d+)\s(.*)$/)
        {
                $hash = $1 / 1000;
                $accept = $2;
                $invalid = $3;
                $url = $4;
                chomp($url);

        }

    }

    return($hash, $accept, $invalid, $url);
  }


sub getPhoenixStatsSU
{
    my ($gpu) = @_;

    my $hash = 0;
    my $accept = 0;
    my $invalid = 0;
    my $url = 'No connection';

    if (-e "/tmp/phoenix-$gpu.sock")
    {
        my $dat = `socat /tmp/phoenix-$gpu.sock -`;

        if ($dat =~ m/(\d+)\s(\d+)\s(\d+)\s(.*)/)
        {
                $hash = $1 / 1000;
                $accept = $2;
                $invalid = $3;
		$url = $4;
                chomp($url);

                if ($url =~ m/.+\@(.+)/)
                {
                  $url = $1;
		  if ($url =~ m/(.+):.*/)
		  {
 			$url = $1;
                  }	
                }
        }

    }

    return($hash, $accept, $invalid, $url);
}


sub getCGMinerPools
{
	 
	my @pools;
	
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
    	print $sock "pools|\n";
    
		my $res = "";
		
		while(<$sock>) 
		{
			$res .= $_;
		}
		
		close($sock);
	
		
while ($res =~ m/\|POOL=(\d+),URL=(.+?),Status=(.+?),Priority=(\d+),Quota=(\d+),Long Poll=(.+?),Getworks=(\d+),Accepted=(\d+),Rejected=(\d+),Works=(\d+),Discarded=(\d+),Stale=(\d+),Get Failures=(\d+),Remote Failures=(\d+),User=(.+?),/g)
{
	push(@pools, ({ poolid=>$1, url=>$2, status=>$3, priority=>$4, quota=>$5, lp=>$6, getworks=>$7, accepted=>$8, rejected=>$9, works=>$10, discarded=>$11, stale=>$12, getfails=>$13, remotefailures=>$14, user=>$15 }) );
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
sub getCGMinerSummary
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
    	print $sock "summary|\n";
    
		my $res = "";
		
		while(<$sock>) 
		{
			$res .= $_;
		}
		
		close($sock);


	while ($res =~ m/.*,Elapsed=(\d+),MHS\sav=(\d+\.\d+),MHS\s\ds=(\d+\.\d+),Found\sBlocks=(\d+),Getworks=(\d+),Accepted=(\d+),Rejected=(\d+),Hardware\sErrors=(\d+),Utility=(.+?),Discarded=(\d+),Stale=(\d+),Get\sFailures=(\d+),Local\sWork=(\d+),Remote\sFailures=(\d+),Network\sBlocks=(\d+),Total\sMH=(.*?),Work\sUtility=(\d+\.\d+),Difficulty\sAccepted=(\d+\.\d+),Difficulty\sRejected=(\d+\.\d+),Difficulty\sStale=(\d+\.\d+),Best\sShare=(\d+),/g)
	{
	  push(@summary,({ elapsed=>$1, hashavg=>$2, hashrate=>$3, found_blocks=>$4, getworks=>$5, shares_accepted=>$6, shares_invalid=>$7, hardware_errors=>$8, utility=>$9, discarded=>$10, stale=>$11, get_failures=>$12, local_work=>$13, remote_failures=>$14, network_blocks=>$15, total_mh=>$16, work_utility=>$17, diff_accepted=>$18, diff_rejected=>$19, diff_stale=>$20, best_share=>$21 }) );
	}
		
	return(@summary);

    }
    else
    {
	$url = "cgminer socket failed";
    }
	
}
# taa taa

sub stopMining
{
 	
	
 my $conf = &getConfig;
 %conf = %{$conf};  
 
 &blog("stopping mining processes...");
 
 print "..";
 
 # if cgminer, ask nicely
 if (${$conf}{'settings'}{'cgminer'})
 {
 	 my $cgport = 4028;
 	 if (defined(${$conf}{'settings'}{'cgminer_port'}))
 	 {
 	 	 $cgport = ${$conf}{'settings'}{'cgminer_port'};
 	 }
 	 
 	 print "cgminer api ";
 	 
 	 my $sock = new IO::Socket::INET (
                                  PeerAddr => '127.0.0.1',
                                  PeerPort => $cgport,
                                  Proto => 'tcp',
                                  ReuseAddr => 1,
                                  Timeout => 10,
                                 );
    
    if ($sock)
    {
    	&blog("send quit command to cgminer api");
 	 
    	print $sock "quit|\n";
    
		my $res = "";
		
		while(<$sock>) 
		{
			$res .= $_;
		}
		
		close($sock);
		print "closed..";
	}
	else
	{
		&blog("failed to get socket for cgminer api");
 	 
		print "failed..";
	}
    	
 }
 
 
 # if phoenix2, ask nicely
 if (${$conf}{'settings'}{'phoenix2'})
 {
 	 my $p2port = 7780;
 	 if (defined(${$conf}{'settings'}{'phoenix2_port'}))
 	 {
 	 	 $cgport = ${$conf}{'settings'}{'phoenix2_port'};
 	 }
 	 
 	 my $p2pass = 'bamt';
 	 
 	 if (defined(${$conf}{'settings'}{'phoenix2_pass'}))
 	 {
 	 	 $cgport = ${$conf}{'settings'}{'phoenix2_pass'};
 	 }
 	 
 	 
 	 print "phoenix2 api ";
 	 
 	 my $client = new JSON::RPC::Client;
 
 	 $client->ua->credentials( 'localhost:' . $p2port , 'Phoenix RPC', 'user' => $p2pass );
 
 	 my $uri = 'http://localhost:' . $p2port. '/';
 	 my $obj = 
 	 {
      id => '1',
      jsonrpc => '1.0',          
      method  => 'shutdown',
      params  => [] ,
     };
 
    my $res = $client->call( $uri, $obj );
 
    if (!$res) 
    {
    	print "failed..";
    }
 	
    	
 }
 
	
 # find and kill our mining screens
 if (opendir(DIR, '/var/run/screen/S-root'))  
 {
	 while (defined($file = readdir(DIR))) 
	 {
	  next if $file =~ /^\.\.?$/;
	 
	  if ($file =~ m/(\d+)\.gpu?+/)
	  {
	     &blog("stop mining wrapper for gpu $1");
 	 
		 print "$file.."; 
		`kill $1`;
		sleep(1);
	  }
	  elsif ($file =~ m/(\d+)\.cgminer/)
	  {
	  	 &blog("kill cgminer"); 
		 print "$file.."; 
		`kill $1`;
		sleep(1);
	  }
	  elsif ($file =~ m/(\d+)\.phoenix2/)
	  {
	  	 &blog("kill phoenix2"); 
		 print "$file.."; 
		`kill $1`;
		sleep(1);
	  }
	 }
	 
	 closedir(DIR);
 }
 
 # kill any straggler wrappers 
 if (opendir(DIR, '/tmp'))  
 {
	 while (defined($file = readdir(DIR))) 
	 {
	  next if $file =~ /^\.\.?$/;
	 
	  if ($file =~ m/^wrapper-(\d+)\.pid/)
	  {
         &blog("kill straggler wrapper for gpu $1");
		 print "$file..";
		`cat /tmp/$file | xargs kill -9 2>&1`;
	  }
	 } 
	 closedir(DIR);
 }
 
 sleep(1);
 
 # kill any straggler phoenixes
 my @pps = `ps a`;
 
 foreach(@pps)
 {
 	 if ($_ =~ m/^\s*(\d+)\spts.*phoenix\.py.*/)
 	 {
 	 	 print "pid $1..";
 	 	 `kill -9 $1`;
 	 }	 	 
 }
 
 # tell mother we're done
 my $momtmp = &getMomTmp;

 %momtmp = %{$momtmp};
 
 $momtmp{'mining'} = 0;
 $momtmp{'stopped_mining_time'} = time;
 $momtmp{"gendesktop"} = 0;
 
 &putMomTmp(%momtmp);

}


sub startMining
{
 my $conf = &getConfig;
 %conf = %{$conf};  
  
 my (@gpus) = &getFreshGPUData;

 # always check/sync offline	
 &syncOfflineConfig;

 # check our hostname
 &setHostname;
 
 # coordinate munin plugins
 `/etc/init.d/munin-node stop`;
 &makeMuninPlugins(@gpus);
 `/etc/init.d/munin-node start`;
 
 # if we aren't forbidden..
 if (! -e '/live/image/BAMT/CONTROL/ACTIVE/noMine')
 {

  for (my $k = 0;$k < @gpus;$k++)
  {
   print "..GPU $k";  
	  
   unless ((${$conf{'gpu' . $k}}{'disabled'}) || ( -e '/live/image/BAMT/CONTROL/ACTIVE/noGPU'.$k))
   {
    my $pid = fork(); 

    if (not defined $pid)
    {
      die "out of resources? forking failed while starting mining for GPU $k";
    }
    elsif ($pid == 0)
    {
     #$ENV{DISPLAY} = ":0.$k";
     $ENV{DISPLAY} = ":0.0";
     $ENV{LD_LIBRARY_PATH} = "/opt/AMD-APP-SDK-v2.4-lnx32/lib/x86/:";
     
     &doFAN($k);
     &doOC($k);
     
     # no phoenix wrapper on cgminer gpus
     if ((! ${$conf{'gpu' . $k}}{'cgminer'}) && (! ${$conf{'gpu' . $k}}{'phoenix2'}))
     {
     	&blog("starting phoenix wrapper for gpu $k");
     	exec("/usr/bin/screen -d -m -S gpu$k /opt/bamt/wrapper $k");
     }
     
     exit(0);
    }
    else
    {
     if (defined(${$conf}{'settings'}{'start_mining_miner_delay'}))
     {
     	sleep ${$conf}{'settings'}{'start_mining_miner_delay'};
     }
     else
     {
      	sleep 3;
     }
    }
   }
   else
   {
   	print " is disabled";
   }
  }
  
  
  if ( defined(${$conf}{'settings'}{'cgminer'}) && (${$conf}{'settings'}{'cgminer'} == 1) && defined(${$conf}{'settings'}{'cgminer_opts'}) )
  {
  	  # startup a cgminer session
  	  print "..cgminer..";
  	  
  	  # wait for overclocking to settle down.. maybe not needed but cgminer sometimes bitches and wont start gpu
  	  sleep(3);
  	  
  	  &startCGMiner( ${$conf}{'settings'}{'cgminer_opts'} );
  }
  
  if ( defined(${$conf}{'settings'}{'phoenix2'}) && (${$conf}{'settings'}{'phoenix2'} == 1) && defined(${$conf}{'settings'}{'phoenix2_config'}) )
  {
  	  # startup a cgminer session
  	  print "..phoenix2..";
  	  
  	  # wait for overclocking to settle down.. maybe not needed but cgminer sometimes bitches and wont start gpu
  	  sleep(3);
  	  
  	  &startPhoenix2( ${$conf}{'settings'}{'phoenix2_config'} );
  }

  

  # tell mother what we've done
  my $momtmp = &getMomTmp;

  %momtmp = %{$momtmp};

  $momtmp{'mining'} = 1;
  $momtmp{'started_mining_time'} = time;
  $momtmp{"gendesktop"} = 0;

  &putMomTmp(%momtmp);

  
 }
 else
 {
 	 &blog("mining is disabled, nothing started");
 	 print " (mining is disabled, so nothing started)";
 }
}


sub startCGMiner
{
	my ($args) = @_;
	
	my $pid = fork(); 

	
	
    if (not defined $pid)
    {
      die "out of resources? forking failed for cgminer process";
    }
    elsif ($pid == 0)
    {
    	$ENV{DISPLAY} = ":0";
    	$ENV{LD_LIBRARY_PATH} = "/opt/AMD-APP-SDK-v2.4-lnx32/lib/x86/:";
        $ENV{GPU_USE_SYNC_OBJECTS} = "1";
    	
    	my $cmd = "cd /opt/miners/cgminer;/usr/bin/screen -d -m -S cgminer /opt/miners/cgminer/cgminer $args"; 
    	
    	&blog("starting cgminer with cmd: $cmd");
    	
		exec($cmd);
		exit(0);
	}
	
}


sub startPhoenix2
{
	my ($args) = @_;
	
	my $pid = fork(); 

	
	
    if (not defined $pid)
    {
      die "out of resources? forking failed for phoenix2 process";
    }
    elsif ($pid == 0)
    {
    	$ENV{DISPLAY} = ":0.0";
    	$ENV{LD_LIBRARY_PATH} = "/opt/AMD-APP-SDK-v2.4-lnx32/lib/x86/:";
    	
    	my $cmd = "cd /opt/miners/phoenix2;/usr/bin/screen -d -m -S phoenix2 /opt/miners/phoenix2/phoenix.py $args"; 
    	
    	&blog("starting phoenix2 with cmd: $cmd");
    	
		exec($cmd);
		exit(0);
	}
	
}



sub doFAN
{
 my ($gpu) = @_;

 my $gc = &getGPUConfig($gpu);

 
 if (! ${$gc}{'disabled'})
 {
 	  
   # set fan
   if (defined(${$gc}{'fan_speed'}))
   {
   	    print "..fan $gpu";	  

   	    my $cmd = 'DISPLAY=:0.0 /usr/local/bin/atitweak -A ' . $gpu;

   	    $cmd .= ' -f ' . ${$gc}{'fan_speed'};
   	    
   	    &blog("fan cmd for gpu $gpu: " . $cmd);
   	    
   	    my $res = `$cmd`;
   }
 }
}


# do overclocking
sub doOC
{
	my ($gpu) = @_;
 
 	my $gc = &getGPUConfig($gpu);

 	my $debug = 0;

	 if (defined(${$gc}{'debug_oc'}) && (${$gc}{'debug_oc'} == 1))
	 {
	 	 print "\n\n";
	 	 print "--[";
	 	 print " Debug info for O/C on GPU $gpu ";
	 	 print "]------------------------------------------------\n\n";
	 	 $debug = 1;
	 }

 	if (-e '/live/image/BAMT/CONTROL/ACTIVE/noOC')
 	{
		 if ($debug)
		 {
			 print "Overclocking for all GPUs is disabled due to BAMT/CONTROL/ACTIVE/noOC\n";
		 }
		 &blog("Overclocking for all GPUs is disabled due to BAMT/CONTROL/ACTIVE/noOC");
 	}
 	elsif (-e '/live/image/BAMT/CONTROL/ACTIVE/noOCGPU'.$gpu)
 	{
		 if ($debug)
		 {
			 print "Overclocking for this GPU is disabled due to BAMT/CONTROL/ACTIVE/noOC$gpu\n";
		 }
		 &blog("Overclocking is disabled on GPU $gpu due to BAMT/CONTROL/ACTIVE/noOC$gpu");
	}
	elsif (defined(${$gc}{'disabled'}) && (${$gc}{'disabled'} == 1))
	{
 		 if ($debug)
 		 {
 		 	 print "This GPU is not enabled in the configuration\n";
 		 	 &blog("GPU $gpu not enabled in bamt.conf");
 		 }
 	}
 	else
 	{
		if ($debug)
		{
		  print "GPU is enabled, overclocking is enabled\n\n";
		}
		else
		{
			print "..OC $gpu";	  
		}
		
		if (defined(${$gc}{'pre_oc_cmd'}))
		{
			 &blog("preOC cmd for gpu $gpu: " . ${$gc}{'pre_oc_cmd'});
		
			 if ($debug)
			 {
				 print "PreOC command: " . ${$gc}{'pre_oc_cmd'} . "\n\n";
			 }	  
			  
			 system(${$gc}{'pre_oc_cmd'});
		
			 if ($debug)
			 {
				 print "\n\n";
			 }
		}
		 
		#old style
		
		if (defined(${$gc}{'mem_speed'}) || defined(${$gc}{'core_speed'}) || defined(${$gc}{'core_voltage'})) 
		{	 
			my $cmd = 'DISPLAY=:0.0 /usr/local/bin/atitweak -P 2 -A ' . $gpu;
			  
			# set fan
			if (defined(${$gc}{'fan_speed'}))
			{
				$cmd .= ' -f ' . ${$gc}{'fan_speed'};
			}
			
			if (defined(${$gc}{'core_speed'}))
			{
			# set core clock
				$cmd .= ' -e ' . ${$gc}{'core_speed'};
			}
			
			if (defined(${$gc}{'mem_speed'}))
			{
				$cmd .= ' -m ' . ${$gc}{'mem_speed'};
			}
			
			if (defined(${$gc}{'core_voltage'}))
			{
			# set core clock 
				$cmd .= ' -v ' . ${$gc}{'core_voltage'};
			}
			
			if ($debug)
			{
				 print "OC command - all profiles: " . $cmd . "\n\n";
			}	  
			
			&blog("OC cmd for gpu $gpu all profiles: " . $cmd);
			
			my $res = `$cmd`;
			
			if ($debug)
			{
			 print "Results:\n$res\n\n";
			}
		
		}
		
		# new style
		
		for (my $prof = 0;$prof < 3;$prof++)
		{
			if (defined(${$gc}{'mem_speed_' . $prof}) || defined(${$gc}{'core_speed_' . $prof}) || defined(${$gc}{'core_voltage_' . $prof})) 
			{	 
				my $cmd = "DISPLAY=:0.0 /usr/local/bin/atitweak -P $prof -A $gpu";
				
				if (defined(${$gc}{'core_speed_' . $prof}))
				{
					 # set core clock, profile $prof
					 $cmd .= ' -e ' . ${$gc}{'core_speed_' . $prof};
				}
				
				if (defined(${$gc}{'mem_speed_' . $prof}))
				{
					# set mem clock, profile $prof
					$cmd .= ' -m ' . ${$gc}{'mem_speed_' . $prof};
				}
				
				if (defined(${$gc}{'core_voltage_' . $prof}))
				{
					# set core clock, profile $prof 
					$cmd .= ' -v ' . ${$gc}{'core_voltage_' . $prof};
				}
				
				if ($debug)
				{
					 print "OC command - profile $prof: " . $cmd . "\n\n";
				}	  
    			&blog("OC cmd for gpu $gpu profile $prof: " . $cmd);
				
				my $res = `$cmd`;
				
				if ($debug)
				{
				 print "Results:\n$res\n\n";
				}
			} 
		}
		
		if (defined(${$gc}{'post_oc_cmd'}))
		{
		 	
			&blog("postOC cmd for gpu $gpu: " . ${$gc}{'pre_oc_cmd'});
			
			if ($debug)
			 {
				 print "PostOC command: " . ${$gc}{'post_oc_cmd'} . "\n\n";
			 }	  
			  
			 system(${$gc}{'post_oc_cmd'});
			
			 if ($debug)
			 {
				 print "\n\n";
			 }
		
		}
		
		if ($debug)
		{
			print "-------------------------------------------------------------------------------\n\n";
		}
	 
	}
}



sub loadPoolURLs
{
 my ($fn) = @_;

 my @res;

 open(UF,"<$fn") or die "ERROR: Cannot open worker url file '$fn'";

 while(my $line = <UF>)
 {
  chomp;

  if ($line =~ m/^\w+?\:\/\/.+?\:.+?\@.*/ )
  {
    push(@res,$line);
  }
 }

 close(FN);

 if (@res < 1)
 {
 	 &blog("warning - pools file returned 0 usable URLs");
 }
 
 return(@res);
}


sub getTimestamp
{
 @months = qw(Jan Feb Mar Apr May Jun Jul Aug Sep Oct Nov Dec);
 @weekDays = qw(Sun Mon Tue Wed Thu Fri Sat Sun);
 ($second, $minute, $hour, $dayOfMonth, $month, $yearOffset, $dayOfWeek, $dayOfYear, $daylightSavings) = gmtime();
 $year = 1900 + $yearOffset;
 return("$hour:$minute:$second, $weekDays[$dayOfWeek] $months[$month] $dayOfMonth, $year");
 
}



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



sub gatherOfflineStatusPre
{
 # X has just init, pre mining

 if (-e '/live/image/BAMT/STATUS')
 {
 	 &blog("gathering pre-mine stats for offline mode");
 	 
	 # pci devices
	 `lspci -k -v > /live/image/BAMT/STATUS/lspci.txt`;
	
	 # aticonfig list
	 `aticonfig --list-adapters > /live/image/BAMT/STATUS/aticonfig.txt`;
	 
	 # working xorg.conf
	 `cp /etc/X11/xorg.conf /live/image/BAMT/STATUS/xorgconf.txt`;
	
	 # xorg log
	 `cp /var/log/Xorg.0.log /live/image/BAMT/STATUS/xorg0log.txt`;
	
	 #dmesg
	 `cp /var/log/dmesg /live/image/BAMT/STATUS/dmesg.txt`;
 }
}



sub gatherOfflineStatusPost
{
 # now that mining is started.. 
 
 
 if (-e '/live/image/BAMT/STATUS')
 {
 	 &blog("gathering post-mine stats for offline mode");
 	 
	 # atitweak
	 `atitweak -s > /live/image/BAMT/STATUS/atitwk-s.txt`;
	 `atitweak -l > /live/image/BAMT/STATUS/atitwk-l.txt`;
 }
 
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


 
sub syncOfflineConfig
{
	
	# check for disable, and also nop if no offline config dir	 
	if  ( (! -e '/live/image/BAMT/CONTROL/ACTIVE/noSync') && (-e '/live/image/BAMT/CONFIG') )
	{
		# bring in any files that dont exist in live
		if (opendir(DIR, '/live/image/BAMT/CONFIG/TO'))
		{
			while (defined($file = readdir(DIR))) 
			{
				next if $file =~ /^\.\.?$/;
	 
				my $off_atime = (stat("/live/image/BAMT/CONFIG/TO/$file"))[8];
				my $off_mtime = (stat("/live/image/BAMT/CONFIG/TO/$file"))[9];
				 
				if (! -e "/etc/bamt/$file")
				{
				 # copy new file into live
				 &blog("config sync: '$file' in offline dir is new, copying to live");
				 
				 `cp /live/image/BAMT/CONFIG/TO/$file /etc/bamt/$file`;
				 utime $off_atime,$off_mtime, "/etc/bamt/$file";
				}
				else
				{
					my $live_atime = (stat("/etc/bamt/$file"))[8];
					my $live_mtime = (stat("/etc/bamt/$file"))[9];
					
					if ($off_mtime > $live_mtime)
					{
						&blog("config sync: '$file' in offline dir is updated, copying to live");
				
						# off is newer, replace live
						`cp /live/image/BAMT/CONFIG/TO/$file /etc/bamt/$file`;
						utime $off_atime,$off_mtime, "/etc/bamt/$file";
					}
				}
				
			}
	 
			closedir(DIR);
		}
 
 
		# sync files in live against off
		opendir(DIR, '/etc/bamt') or die "can't open /etc/bamt: $!"; 
 
		while (defined($file = readdir(DIR))) 
		{
			next if $file =~ /^\.\.?$/;
	 
			my $live_atime = (stat("/etc/bamt/$file"))[8];
			my $live_mtime = (stat("/etc/bamt/$file"))[9];
			 
			if (-e "/live/image/BAMT/CONFIG/FROM/$file")
			{

				my $off_atime = (stat("/live/image/BAMT/CONFIG/FROM/$file"))[8];
				my $off_mtime = (stat("/live/image/BAMT/CONFIG/FROM/$file"))[9];
		 
				if ($live_mtime > $off_mtime)
				{
					 # live is newer
					 &blog("config sync: '$file' in live dir is updated, copying to offline");
					 
					 `cp /etc/bamt/$file /live/image/BAMT/CONFIG/FROM/$file`;
					 utime $live_atime,$live_mtime, "/live/image/BAMT/CONFIG/FROM/$file";
					 
				}
				
			}
			else
			{
				#file doesnt exist offline, copy live
				&blog("config sync: '$file' in live dir is new, copying to offline");
		 
				`cp /etc/bamt/$file /live/image/BAMT/CONFIG/FROM/$file`;
		 
				#make its times == live file
				utime $live_atime,$live_mtime, "/live/image/BAMT/CONFIG/FROM/$file";
			}
	 
		}
		closedir(DIR);
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




sub rotateConfigBackups
{
	&blog("rotating config backups");
	
	for ($i = 3;$i >= 0;$i--)
	{
		if (-e "/etc/bamt/bamt.conf.$i")
		{
			rename "/etc/bamt/bamt.conf.$i", "/etc/bamt/bamt.conf." . ($i + 1);
		}
		
	}
	
	use File::Copy;
	copy('/etc/bamt/bamt.conf', '/etc/bamt/bamt.conf.0');
	
}

sub rotatePoolsBackups
{
	&blog("rotating pool backups");
	
	for ($i = 3;$i >= 0;$i--)
	{
		if (-e "/etc/bamt/pools.$i")
		{
			rename "/etc/bamt/pools.$i", "/etc/bamt/pools." . ($i + 1);
		}
		
	}
	
	use File::Copy;
	copy('/etc/bamt/pools', '/etc/bamt/pools.0');
}


sub blog
{
	my ($msg) = @_;

	my @parts = split(/\//, $0);
	my $task = $parts[@parts-1];
	
    openlog($task,'nofatal,pid','local5');
    syslog('info', $msg);
    closelog;
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
