use Irssi;
use Irssi::Irc;
use List::Util 'shuffle';
use vars qw($VERSION %IRSSI);

$VERSION= "1.0";
%IRSSI = (
    authors     => "munki props to vap0r and acidvegas",
    contact     => "thatfunkymunki@gmail.com",
    name        => "cspam",
    description => "irc color spam",
    license     => "BSD",
    url         => "https://github.com/thatfunkymunki",
    changed     => "05-17-2017 2352"
);

sub cspam{
  my ($data, $server, $channel) = @_;
  my @color    = (shuffle 0..15)[0..1];
  my $bullshit = substr("\x03$color[0]," . sprintf("%02d", $color[1]) . ("$data\x16$data\x16" x 100) , 0, 400);
  $channel->command("MSG $channel->{name} $bullshit");
}

Irssi::command_bind('cspam', 'cspam');
