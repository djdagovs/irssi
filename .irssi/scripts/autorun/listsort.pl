use strict;
use warnings;
use Irssi;

Irssi::signal_add_last('event 322', \&list_event);
Irssi::signal_add_last('event 323', \&list_end);

my %list;

sub list_event {
    my ($server, $data, $server_name) = @_;
    my ($meta, $more) = split (/ :/, $data, 2);
    my ($nick, $name, $size) = split (/ /, $meta, 3);
    $list{$name}{'size'} = $size;
    my $modes = '';
    $list{$name}{'desc'} = '';
    if ($more =~ /^[^[]*\[([^]]*)\][^ ]* *([^ ].*)$/) {
        $modes = $1;
        $list{$name}{'desc'} = $2;
    }
    $modes =~ s/ +$//;
    $list{$name}{'modes'} = $modes;
}

sub list_end {
    for my $name (sort {$list{$a}{'size'} <=> $list{$b}{'size'}} keys %list) {
        my $mode = $list{$name}{'modes'};
        $mode = " ($mode)" if ($mode);
        my $msg = sprintf (
            "%d %s: %s%s",
            $list{$name}{'size'},
            $name,
            $list{$name}{'desc'},
            $mode
        );
        Irssi::print($msg, MSGLEVEL_CRAP);
    }
    %list = ();
}