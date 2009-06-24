package Geo::IATA;

use warnings;
use strict;
use Carp;
use File::Spec;
use DBI;
use Sub::Install qw(install_sub);

use version;
use vars '$VERSION';
$VERSION = qv('0.0.2');
our $AUTOLOAD;

sub new {
    my $self = shift;
    my $pkg = ref $self || $self;

    my $path = shift;
    unless ($path){
       my $db = $pkg; 
       $db =~s{::}{/}gxms;
       $db =~s{$}{.pm}xms;
       ($path = $INC{$db}) =~ s{.pm$}{}xms;
       $path=File::Spec->catfile($path, "iata_sqlite.db");

    }
    my $dbh = DBI->connect("dbi:SQLite:dbname=$path","","", {RaiseError => 1, unicode=> 1});
return bless {dbh => $dbh}, $pkg;
}

sub AUTOLOAD { ## no critic qw(ClassHierarchies::ProhibitAutoloading Subroutines::RequireArgUnpacking)
    my $func = $AUTOLOAD;
    $func =~ s/.*:://xms;

return unless grep {$func eq $_} qw( iata icao airport location );
    no strict 'refs'; ## no critic 'TestingAndDebugging::ProhibitNoStrict'

    install_sub({
        code => sub {
             my $self = shift;
             my $arg  = shift;
             my $sth  = $self->dbh->prepare("select * from iata where $func like ?");
             $sth->execute($arg);
             my $result = $sth->fetchall_arrayref( {} );
             $sth->finish;
         return $result;
         }, 
        into => ref $_[0],
        as   => $func,
    });
    goto &$func;
}

sub iata2icao {
return shift->iata(shift)->[0]{icao};
}

sub icao2iata {
return shift->icao(shift)->[0]{iata};
}

sub iata2airport {
return shift->iata(shift)->[0]{airport};
}

sub icao2airport {
return shift->icao(shift)->[0]{airport};
}

sub icao2location {
return shift->icao(shift)->[0]{airport};
}

sub iata2location {
return shift->iata(shift)->[0]{location};
}

sub DESTROY {
    my $self = shift;
    my $dbh = $self->dbh;
    if ($dbh){
        $dbh->disconnect;
    }
    undef $self;
return;
}

sub dbh {
return shift->{dbh};
}

1; # Magic true value required at end of module
__END__

=head1 NAME

Geo::IATA - Search airports by iata, icao codes

=head1 VERSION

This document describes Geo::IATA version 0.0.2


=head1 SYNOPSIS

    use Geo::IATA;
    $g = Geo::IATA->new;
    
    print $g->icao2iata("EDDB");          # SXF
    print $g->iata2icao("SXF");           # EDDB
    print $g->iata2airport("SXF");        # Berlin-Schönefeld International Airport
    print $g->iata("SXF")->[0]{airport};  # same but with full resultset

    print map{$_->{airport}} @{$g->airport("A%")}; # all airport names starting with A

    print $g->icao("EDDB")->[0]{iata};    # SXF

    print map {$_->{iata} } @{$g->location("%France")};  # iata code for french airports
  
  
=head1 DESCRIPTION

This module provides a SQLite DB for airport data. Searchable information are IATA,ICAO
data airport name and location.

=head1 INTERFACE

Geo::IATA is a pure oo module.

=head2 new

Constructor. A connection to internal SQLite DB is opened.
You can optional specify the path to the sqlite database.
The sqlite db default location is dirname($INC{Geo/IATA.pm})/IATA/iata_sqlite.db

=cut

=head2 dbh

Gets the dbh to internal sqlite database.

=head2 iata

=head2 icao

=head2 airport

=head2 location

Input: iata, icao code, airport name or location. May use SQL wildcards.

Returns an arrayref of hashrefs of all matched rows for the query 

select * from table where <field> like <arg>

[{iata => IATA,icao => ICAO, airport => AIRPORT,location => LOCATION}]

=head2 iata2icao

=head2 icao2iata

=head2 iata2airport

=head2 icao2airport

=head2 iata2location

=head2 icao2location

Simple mapping methods. Warning some iata codes have no mapping to icao code in wikipedia.


=cut

=head2 AUTOLOAD

The module uses AUTOLOAD to call above queries.

=cut

=head2 DESTROY

Closes internal dbi connection to sqlite db.

=cut

=head1 BUGS AND LIMITATIONS

Please report any bugs or feature requests to
C<bug-geo-iata@rt.cpan.org>, or through the web interface at
L<http://rt.cpan.org>.


=head1 SEE ALSO

GEO::ICOA # somehow slow, handles only icoa codes
L<http://www.nagilum.net/irssi-iata/> # embedded in irssi


=head1 AUTHOR

Joerg Meltzer  C<< <joerg <at> joergmeltzer.de> >>


=head1 LICENCE AND COPYRIGHT

Copyright (c) 2009, Joerg Meltzer C<< <joerg <at> joergmeltzer.de> >>. All rights reserved.

This module is free software; you can redistribute it and/or
modify it under the same terms as Perl itself. See L<perlartistic>.


=head1 DISCLAIMER OF WARRANTY

BECAUSE THIS SOFTWARE IS LICENSED FREE OF CHARGE, THERE IS NO WARRANTY
FOR THE SOFTWARE, TO THE EXTENT PERMITTED BY APPLICABLE LAW. EXCEPT WHEN
OTHERWISE STATED IN WRITING THE COPYRIGHT HOLDERS AND/OR OTHER PARTIES
PROVIDE THE SOFTWARE "AS IS" WITHOUT WARRANTY OF ANY KIND, EITHER
EXPRESSED OR IMPLIED, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE. THE
ENTIRE RISK AS TO THE QUALITY AND PERFORMANCE OF THE SOFTWARE IS WITH
YOU. SHOULD THE SOFTWARE PROVE DEFECTIVE, YOU ASSUME THE COST OF ALL
NECESSARY SERVICING, REPAIR, OR CORRECTION.

IN NO EVENT UNLESS REQUIRED BY APPLICABLE LAW OR AGREED TO IN WRITING
WILL ANY COPYRIGHT HOLDER, OR ANY OTHER PARTY WHO MAY MODIFY AND/OR
REDISTRIBUTE THE SOFTWARE AS PERMITTED BY THE ABOVE LICENCE, BE
LIABLE TO YOU FOR DAMAGES, INCLUDING ANY GENERAL, SPECIAL, INCIDENTAL,
OR CONSEQUENTIAL DAMAGES ARISING OUT OF THE USE OR INABILITY TO USE
THE SOFTWARE (INCLUDING BUT NOT LIMITED TO LOSS OF DATA OR DATA BEING
RENDERED INACCURATE OR LOSSES SUSTAINED BY YOU OR THIRD PARTIES OR A
FAILURE OF THE SOFTWARE TO OPERATE WITH ANY OTHER SOFTWARE), EVEN IF
SUCH HOLDER OR OTHER PARTY HAS BEEN ADVISED OF THE POSSIBILITY OF
SUCH DAMAGES.
