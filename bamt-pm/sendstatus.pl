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

sub bcastStatus
{

 my $conf = &getConfig;
 %conf = %{$conf};

 my $ts = ${$conf}{settings}{miner_id} . '|' . ${$conf}{settings}{miner_loc};

 my @gpus = &getGPUData(false);

 for ($k = 0;$k < @gpus;$k++)
 {
  $ts .= "|$k:" . encode_json $gpus[$k];
 }

 my @pools = &getCGMinerPools(1);

 for ($p = 0;$p < @pools;$p++)
 {
  $ts .= "|$p pool:" . encode_json $pools[$p];
 }

 my $port = 54545;

 if (defined(${$conf}{settings}{status_port}))
 {
  $port = ${$conf}{settings}{status_port};
 }


 my $socket = IO::Socket::INET->new(Broadcast => 1, Blocking => 1, ReuseAddr => 1, Type => SOCK_DGRAM, Proto => 'udp', PeerPort => $port, LocalPort => 0, PeerAddr => inet_ntoa(INADDR_BROADCAST));
 
 if ($socket)
 {
 	$socket->send($ts, 0);
	 close $socket;
 }
}


sub directStatus
{
 # may someday be different mechanism, for now same as broadcast but with dest. addr
 my ($target) = @_;

 my $conf = &getConfig;
 %conf = %{$conf};

 my $ts = ${$conf}{settings}{miner_id} . '|' . ${$conf}{settings}{miner_loc};

 my @gpus = &getGPUData(false);

 for ($k = 0;$k < @gpus;$k++)
 {
  $ts .= "|$k:" . encode_json $gpus[$k];
 }

 my @pools = &getCGMinerPools(1);

 for ($p = 0;$p < @pools;$p++)
 {
  $ts .= "|$p pool:" . encode_json $pools[$p];
 }

 my $port = 54545;
 
 if (defined(${$conf}{settings}{status_port}))        
 {
  $port = ${$conf}{settings}{status_port};
 }

 my $socket = IO::Socket::INET->new(Blocking => 1, ReuseAddr => 1, Type => SOCK_DGRAM, Proto => 'udp', PeerPort => 54545, LocalPort => 0, PeerAddr => $target);
 
 if ($socket)
 {
  $socket->send($ts, 0);
  close $socket;
 }
}


1;
