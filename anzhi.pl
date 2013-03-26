#! /usr/bin/perl 

$| = 1;
use strict;
use warnings;

use Mojo;


my $ua = Mojo::UserAgent->new;
my $json = Mojo::JSON->new;

open FH, "anzhi.conf" or die $!;
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

    my $get = "http://www.anzhi.com/search.php?keyword=";
    my $page = 1;

    while(1)
    {
        last if($page > 120); # in case site problem
        my $url = $get.$keyword."&page=$page";

        my $dom = $ua->get($url => {Referer => 'http://www.anzhi.com/'})->res->dom->find('div.app_down > a');       
        last if(! @$dom);

        for my $i (@$dom)
        {
            if($i->{'onclick'} =~ m/(\d+)/)
            {
                my $apk = "http://www.anzhi.com/dl_app.php?s=$1&n=5";
                my $t= $ua->max_redirects(5)->head($apk=> {Referer => 'http://www.anzhi.com/'});
                print $t->req->url->to_string."\n";
                $sum++;
            }
        }
        $page++;
    }
    return $sum;
}

