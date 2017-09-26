use strict;
use Irssi;
use Irssi::Irc;
use String::Multibyte; # Requires the String::Multibyte CPAN perl module.

my $utf8 = String::Multibyte->new('UTF8');
my @colors = ('4', '8', '9', '11', '12', '13');
my @colors100 = ( 1 .. 100 );
my $last_color = 0;

sub make_colors {
    my ($string) = @_;
    my $newstr = "";
    my $last = $last_color;
    my $color = 0;
    my $colorrep = 2;
    my $l = $utf8->length($string);
    for (my $c = 0; $c < $l; $c++) {
        my $char = $utf8->substr($string, $c, 1);
        $last++;
        $color =  ($last / $colorrep)  % scalar(@colors);
        $newstr .= "\003";
        $newstr .= sprintf("%02d", $colors[$color]);
        $newstr .= $char;
    }
    $last_color += 2;
    return $newstr;
}

sub rsay {
    my ($text, $server, $dest) = @_;
    if (!$server || !$server->{connected}) {
        Irssi::print("Not connected to server");
        return;
    }
    return unless $dest;
    if ($dest->{type} eq "CHANNEL" || $dest->{type} eq "QUERY") {
        $dest->command("/msg " . $dest->{name} . " " . make_colors($text));
    }
}

Irssi::command_bind("rsay", "rsay");