use warnings;
use strict;
use Irssi;

sub greentext {
    my $sig = Irssi::signal_get_emitted();
    if ($sig eq "message public") {
        my ($server, $msg, $nick, $address, $target) = @_;
        if ($msg =~ /^\>\s*/) {
            Irssi::signal_emit("message public", $server, "\x{03}3$msg", $nick, $address, $target);
            Irssi::signal_stop();
        }
    }
    if ($sig eq "message private") {
        my ($server, $msg, $nick, $address) = @_;
        if ($msg =~ /^\>\s*/) {
            Irssi::signal_emit("message private", $server, "\x{03}3$msg", $nick, $address);
            Irssi::signal_stop();
        }
    }
    if ($sig eq "send text") {
        my ($msg, $server, $witem) = @_;
        if ($msg =~ /^\>\s*/) {
            Irssi::signal_emit('send text', "\x{03}3$msg", $server, $witem);
            Irssi::signal_stop();
        }
    }
}

Irssi::signal_add('message public', 'greentext'); Irssi::signal_add('message private', 'greentext');
Irssi::signal_add('send text', 'greentext');