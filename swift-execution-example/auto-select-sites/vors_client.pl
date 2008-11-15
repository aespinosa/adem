#!/usr/bin/perl -w
#
# vors_client - a basic tool for accessing a list of sites found on
# either the OSG production or OSG ITB grids.
#
use strict;

use Socket;

my ($remote, $port, $iaddr, $paddr, $proto, $line);

my $grid;

if (!defined($ARGV[0])) {
  print "usage : vors_client grid_name\n";
  print "   where grid_name can be OSG or OSG-ITB\n";
  exit(0);
}

if ($ARGV[0] eq "OSG") {
  $grid = 1;
} elsif ($ARGV[0] eq "OSG-ITB") {
  $grid = 4;
} else {
  print "ERROR : either OSG or OSG-ITB must be specified.\n";
  print "usage : vors_client grid_name\n";
  print "   where grid_name can be OSG or OSG-ITB\n";
  exit(1);
}

my $cmd;
my $resp;

$cmd = "/cgi-bin/tindex.cgi" . '?' . "grid=$grid";
$resp = get_http_data("vors.grid.iu.edu", $cmd);
print $resp;

exit(0);


sub get_http_data {
  my ($rem, $instring) = @_;
  #my ($remote, $port, $iaddr, $paddr, $proto, $line);
  $remote = $rem;
  my $wholeline= "";
  #print "host = $remote, get string = $instring\n";
  $port = 80;
  $iaddr = inet_aton($remote) || die "ERROR, no host: $remote";
  $paddr = sockaddr_in($port, $iaddr);
  $proto = getprotobyname('tcp');
  socket(SOCK, PF_INET, SOCK_STREAM, $proto) || die "ERROR on socket: $!";
  connect(SOCK, $paddr) || die "ERROR on connect: $!";
  my $sendstring = "GET $instring\n";
  send SOCK, $sendstring, 0;
  while (defined($line = <SOCK>)) {
    #print $line;
    $wholeline .= $line;
  }
  close (SOCK);
  return($wholeline);
}
