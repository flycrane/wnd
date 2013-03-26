#! /usr/bin/perl 

$| = 1;
use strict;
use warnings;

use Mojo;


my $ua = Mojo::UserAgent->new;
my $json = Mojo::JSON->new;

open FH, "apk8.conf" or die $!;
while(my $line = <FH>)
{
    chomp($line);
    next if($line =~ m/^#/);
    if ($line =~ m/(\S+):(\S+)/)
    {
        print "Processing $1\n";
        my $ret = process($2);
        print "$1 Total found: $ret\n";
    }
}

close FH;


sub process
{
    my ($keyword) = @_;
    my $sum = 0;

    my $post = "http://www.apk8.com/getGame.php?key=";
    my $page = 1;

    while(1)
    {
        last if($page > 50); # in case site problem
        my $url = "$post$keyword&page=$page";

        my $dom = $ua->post($url => {Referer => 'http://www.apk8.com/'})->res->dom->find('div > a');
        last if(! @$dom);

        for my $i (@$dom)
        {
            my $apk = "http://www.apk8.com/".$i->{"href"};
            my $dom2 = $ua->max_redirects(0)->get($apk=> {Referer => 'http://www.apk8.com/'})->res->dom->at('div.game_other_down_1_left_1_1 > a');
            last if (! @$dom2);
            print $dom2->{'href'}."\n";
            $sum++;
        }
        $page++;
    }
    return $sum;
}

