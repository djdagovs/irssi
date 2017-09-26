use strict;
use Irssi;
use Irssi::Irc;

our $VERSION = '1.0';
our %IRSSI = (
    authors     => 'acidvegas (help from mr_vile/munki)',
    contact     => 'acidvegas@supernets.org',
    name        => 'Greet',
    description => 'A greeting script to send greet_message to any channel you join delayed by greet_delay.',
    license     => 'ISC',
    url         => 'http://github.coM/acidvegas/irssi',
);

sub send_greet {
    my ($channel) = @_;
    my $msg = Irssi::settings_get_str('greet_message');
    $channel->command("/msg ".$channel->{name}." ".$msg);
}

sub event_channel_sync {
    my ($channel) = @_;
    my $delay = Irssi::settings_get_int('greet_delay');
    Irssi::timeout_add_once( $delay * 1000, \&send_greet, $channel, );
}

Irssi::settings_add_int('misc', 'greet_delay', 3);
Irssi::settings_add_str('misc', 'greet_message', "The greatest chatter in the world has just arrived.");
Irssi::signal_add_last('channel sync', 'event_channel_sync');