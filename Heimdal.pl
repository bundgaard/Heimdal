#!/usr/bin/env perl
#

use strict;
use warnings;
use LWP::UserAgent;

# simple need to merge both of these files.
my $local_host = '/tmp/hosts.local'; 
my $external_host = 'http://winhelp2002.mvps.org/hosts.txt';
my $external_to_local = '/tmp/hosts.txt';

sub download_external {
	my $ua = LWP::UserAgent->new;
	$ua->agent('Heimdal guard/1.0');
	
	# will actually write out the file to disk, no need to do any real work in the is_success
	my $res = $ua->mirror($external_host, $external_to_local);

	if(!$res->is_success) {
		print $res->status_line, "\n";
		exit 0;
	}
}

sub read_file {
	my ($filename) = @_;
	local $/ = undef;
	open(my $fh, '<', $filename) or die "$filename $!.";
	my $tmp;
	while(<$fh>) {
		$tmp .= $_;
	}
	close($fh);
	return $tmp;
}
# Order 1. $local, 2. $external => $real;
sub merge_file {
	my ($local, $external, $real) = @_;
	my $fh;
	my $tmp;
	$tmp .= read_file $local;
	$tmp .= read_file $external;
	open($fh, '>', $real) or die "$real $.";
	print $fh $tmp;
	print $fh "\n";
	close($fh);

}


#download_external;
die "Please create a $local_host\n" if (!-e $local_host);
download_external; # download file, will check if the existing file is the same and abort
merge_file $local_host, $external_to_local, "/etc/hosts"; # merge with local hosts


1;

__END__

=head1 NAME
	Heimdal - the purger of evil
	- protect your computer with this script, he will fetch hosts from http://winhelp2002.mvps.org/

	put in cron, run once a week

=head1 DEPENDENCIES
	LWP::UserAgent
