use v5.10; use HTTP::Tiny; use Data::Dumper;

sub rip() {
    my @r;
    my $h=HTTP::Tiny->new(); my $r=$h->get('https://www.espn.com/espn/rss/nfl/news'); die "No pull!" unless $r->{success}; my @x = split /<item>/,$r->{content};
    for (grep !/rss/,@x) { my @y=split /></,$_; $y[1]=~s/^.+\[(.+)\]{2}/$1/; $y[4]=~s/^.*\[(.+)\]{2}/$1/;my $l=(grep /\[https:/,@y)[0]; $l=~s/^.*\[(.+)\]{2}/$1/;push @r,[$y[1],$y[4],$l];}
    return @r;
}

sub serve(@j) {
    say "<!DOCTYPE html><head></head><body>";
    say "Generated " . localtime;
    for (@_) { printf "<article><h1><a href=\"%s\">%s</a></h1><p>%s</p></article>\n",$_->[2],$_->[0],$_->[1],; }
    say "</body></html>";

}

serve rip;
