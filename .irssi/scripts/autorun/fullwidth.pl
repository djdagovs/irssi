use strict;
use Irssi qw(command_bind active_win signal_stop);

sub fullwidth {
    my $msg = $_[0];
    my $say = "";
    foreach my $char (split //, $msg) {
        if ($char =~ /\s/) {
            $say = "$say" . " ";
        }
        else {
            my $nchar = ord($char);
            if ($nchar >= 32 && $nchar <= 126) {
                $say = "$say" . chr($nchar+65248);
            }
        }
    }
    return $say;
}

command_bind(fullwidth => sub {
    my ($text, $server, $dest) = @_;
    my $arg = $_[0];
    my $say = '';
    if ($arg =~ /\*[^*]*\*/) {
        $say = $_[0] =~ s/\*([^*]*)\*/fullwidth($1)/reg;
    }
    else {
        $say = fullwidth($arg);
    }
    active_win->command("/msg " . $dest->{name} . " $say");
});