#!/usr/bin/env perl
use strict;
use warnings;
use Text::Ampita;

my $source = <<'HTML';
<table class="calendar">
 <caption id="mark:caltitle"></caption>
 <tr><th id="mark:calweeklabel">mo tu we th fr st su</th></tr>
 <tr id="mark:calweek"><td id="mark:calday">&nbsp;</td></tr>
</table>
HTML

my $binding = sub{
    my($cal) = @_;
    my $wmonth = $cal->wmonth;
    my $msize= $cal->msize;
    my $week;
    return {
        '#mark:caltitle' => sub{
            shift->(sprintf "%04d-%02d", $cal->year, $cal->month);
        },
        '#mark:calweeklabel' => sub{
            my($yield, $attr, $data) = @_;
            my @wlabel = split /\s+/, $data;
            my $wdoffset = $cal->wdoffset;
            for (map { $wlabel[($_ - $wdoffset) % 7] } 0 .. 6) {
                $yield->($_);
            }
        },
        '#mark:calweek' => sub{
            my($yield) = @_;
            for (0 .. 5) {
                $week = $_;
                $yield->();
            }
        },
        '#mark:calday' => sub{
            my($yield) = @_;
            for my $wday (0 .. 6) {
                my $day = $week * 7 + $wday - $wmonth + 1;
                if ($day >= 1 && $day <= $msize) {
                    $yield->($day);
                }
                else {
                    $yield->();
                }
            }
        },
    };
}->(Calendar->new);
my $template = eval Text::Ampita->generate($source, $binding);
print $template->($binding);

package Calendar;

# Calendar->new(2010, 5)
# Calendar->new is Calendar->new(localtime)
# Calendar->new(time) is Calendar->new(localtime)
sub new {
    my($class, @arg) = @_;
    my $self = bless {}, $class;
    $self->initialize(@arg);
    return $self;
}

sub year    { return shift->{'year'} }
sub month   { return shift->{'month'} }
sub wdoffset { return shift->{'wdoffset'} }
sub wmonth  { return shift->{'wmonth'} }
sub msize   { return shift->{'msize'} }

sub initialize {
    my($self, @arg) = @_;
    $self->{'wdoffset'} = 0; # 0: mo tu..., 1: su mo tu...
    @{$self}{qw(year month)} = $self->_year_month(@arg);
    use integer;
    my @yday = (
        [-31, 0, 31, 59, 90, 120, 151, 181, 212, 243, 273, 304, 334, 365],
        [-31, 0, 31, 60, 91, 121, 152, 182, 213, 244, 274, 305, 335, 366],
    );
    my @msize = (
        [31, 31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31],
        [31, 31, 29, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31],
    );
    my($year, $month) = @{$self}{'year', 'month'};
    my $leap = ($year % 4 == 0
        && $year % 100 != 0 || $year % 400 == 0) ? 1 : 0;
    my $y = $year - 1;
    $self->{'wmonth'} = ($y + $y / 4 - $y / 100 + $y / 400
        + $yday[$leap][$month] + $self->{'wdoffset'}) % 7;
    $self->{'msize'} = $msize[$leap][$month];
    return;
}

sub _year_month {
    my($self, @arg) = @_;
    my($year, $month);
    if (@arg == 2) {
        ($year, $month) = @arg;
    }
    else {
        ($year, $month) = (
              @arg > 5 ? @arg
            : @arg == 1 ? (localtime($arg[0]))
            : localtime
        )[5, 4];
        $year += 1900;
        $month++;
    }
    $year > 0 or die "year > 0\n";
    $month >= 1 and $month <= 12 or die "1 <= month <= 12\n";
    return ($year, $month);
}

__END__
<table class="calendar">
 <caption>2010-05</caption>
 <tr><th>mo</th><th>tu</th><th>we</th><th>th</th><th>fr</th><th>st</th><th>su</th></tr>
 <tr><td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td><td>1</td><td>2</td></tr>
 <tr><td>3</td><td>4</td><td>5</td><td>6</td><td>7</td><td>8</td><td>9</td></tr>
 <tr><td>10</td><td>11</td><td>12</td><td>13</td><td>14</td><td>15</td><td>16</td></tr>
 <tr><td>17</td><td>18</td><td>19</td><td>20</td><td>21</td><td>22</td><td>23</td></tr>
 <tr><td>24</td><td>25</td><td>26</td><td>27</td><td>28</td><td>29</td><td>30</td></tr>
 <tr><td>31</td><td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td></tr>
</table>

