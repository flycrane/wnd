#! /usr/bin/perl 

$| = 1;
use strict;
use warnings;

use Mojo;


my $ua = Mojo::UserAgent->new;
my $json = Mojo::JSON->new;

open FH, "mumayi.conf" or die $!;
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

    my $post = "http://s.mumayi.com/search.php";
    my $page = 1;

    while(1)
    {
        last if($page > 30); # in case site error
        my $tx = $ua->post($post => {Referer => 'http://s.mumayi.com/', 'Content-Type' => 'application/x-www-form-urlencoded'} => "q=$keyword&p=$page");
        last if (! $tx->success);

        if (defined(my $hash = $json->decode($tx->res->body)))
        {
            my $data = $hash->{'alldata'};

            for my $i (keys %$data)
            {
                # print "$data->{$i}->{'arcurl'}\n";
                if ($data->{$i}->{'showtitle'} =~ m/\x{70AE}\x{70AE}\x{5175}/) # paopaobing
                {
                    # /android-39588.html
                    if ($data->{$i}->{'arcurl'} =~ m/-(\d+)\.htm/)
                    {
                        my $down = "http://down.mumayi.com/".$1;
                        my $t = $ua->max_redirects(0)->head($down => {Referer => 'http://www.mumayi.com/'});
                        print $t->res->headers->location."\n";           
                        $sum++;
                    }
                }
            }
            last if($hash->{'nextpage'} > $hash->{'totalpage'});
        }
        $page++;
    }
    return $sum;
}

