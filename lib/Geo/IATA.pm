package Geo::IATA;

use warnings;
use strict;
use Carp;
use File::Spec;
use DBI;
use Sub::Install qw(install_sub);
use File::ShareDir qw( dist_dir );

# ABSTRACT: Search airports by iata, icao codes
# VERSION

our $AUTOLOAD;

sub new {
    my $self = shift;
    my $pkg = ref $self || $self;

    my $path = shift;
    unless ($path){
       my $db = $pkg; 
       $db =~s{::}{/}gxms;
       $db =~s{$}{.pm}xms;
       $path = dist_dir('Geo-IATA');
       $path = File::Spec->catfile($path, "iata_sqlite.db");

    }
    my $dbh = DBI->connect("dbi:SQLite:dbname=$path","","", {RaiseError => 1, sqlite_unicode => 1});
return bless {dbh => $dbh, dbname => $path}, $pkg;
}

sub AUTOLOAD { ## no critic qw(ClassHierarchies::ProhibitAutoloading Subroutines::RequireArgUnpacking)
    my $func = $AUTOLOAD;
    $func =~ s/.*:://xms;

    if ( grep { $func eq $_ } qw( iata icao airport location ) ) {

        no strict 'refs';    ## no critic 'TestingAndDebugging::ProhibitNoStrict'

        install_sub(
            {   code => sub {
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
            }
        );
    goto &$func;
    }
    elsif ( $func =~ m/^(iata|icao|airport|location)2(iata|icao|airport|location)$/xms ) {
        my $from = $1;
        my $to   = $2;
        no strict 'refs';    ## no critic 'TestingAndDebugging::ProhibitNoStrict'

        install_sub(
            {   code => sub {
                    my $self = shift;
                    my $arg  = shift;
                    return $self->$from($arg)->[0]{$to};
                },
                into => ref $_[0],
                as   => $func,
            }
        );
    goto &$func;    
    }
    else {
        croak "unknown subroutine $func";
    }
    return;
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

=encoding UTF-8

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

L<Geo::IATA> is a pure oo module.

=head2 new

Constructor. A connection to internal SQLite DB is opened.
You can optional specify the path to the sqlite database.
The sqlite db default is to user the database in the distribution
share directory which is bundled with this distribution.

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

=head2 (iata|icao|airport|location)2(iata|icao|airport|location)

Simple from2to mapping methods. On multiple matches the first one is taken.
Warning some iata codes have no mapping to icao code in wikipedia.

=cut

=head2 AUTOLOAD

The module uses AUTOLOAD to call above queries.

=cut

=head2 DESTROY

Closes internal dbi connection to sqlite db.

=cut

=head1 UPDATE AIRPORT CODES

You can manually update the airport codes from wikipedia with the script

create/iata_wikipedia.pl

=head1 SEE ALSO

L<http://www.nagilum.net/irssi-iata/> # embedded in irssi

=cut
