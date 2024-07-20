use HTTP::Tiny;

sub rip() {
    my @r;
    my $h=HTTP::Tiny->new(); my $r=$h->get('https://www.espn.com/espn/rss/nfl/news'); die "No pull!" unless $r->{success}; my @x = split /<item>/,$r->{content};
    for (grep !/rss/,@x) { my @y=split /></,$_; $y[1]=~s/^.+\[(.+)\]{2}/$1/; $y[4]=~s/^.*\[(.+)\]{2}/$1/;my $l=(grep /https:/,@y)[1]; $l=~s/^.*\[(.+)\]{2}/$1/;push @r,[$y[1],$y[4],$l];}
    return @r;
}

map { printf "Title: %s\nDescription: %s\nLink: %s\n",$_->[0],$_->[1],$_->[2] } rip;
