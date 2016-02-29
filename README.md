# Geo::IATA [![Build Status](https://secure.travis-ci.org/plicease/Geo-IATA.png)](http://travis-ci.org/plicease/Geo-IATA)

Search airports by iata, icao codes

# SYNOPSIS

    use Geo::IATA;
    $g = Geo::IATA->new;
    
    print $g->icao2iata("EDDB");          # SXF
    print $g->iata2icao("SXF");           # EDDB
    print $g->iata2airport("SXF");        # Berlin-Schönefeld International Airport
    print $g->iata("SXF")->[0]{airport};  # same but with full resultset

    print map{$_->{airport}} @{$g->airport("A%")}; # all airport names starting with A

    print $g->icao("EDDB")->[0]{iata};    # SXF

    print map {$_->{iata} } @{$g->location("%France")};  # iata code for french airports

# DESCRIPTION

This module provides a SQLite DB for airport data. Searchable information are IATA,ICAO
data airport name and location.

# INTERFACE

[Geo::IATA](https://metacpan.org/pod/Geo::IATA) is a pure oo module.

## new

Constructor. A connection to internal SQLite DB is opened.
You can optional specify the path to the sqlite database.
The sqlite db default is to user the database in the distribution
share directory which is bundled with this distribution.

## dbh

Gets the dbh to internal sqlite database.

## iata

## icao

## airport

## location

Input: iata, icao code, airport name or location. May use SQL wildcards.

Returns an arrayref of hashrefs of all matched rows for the query 

    select * from table where <field> like <arg>

    [{iata => IATA,icao => ICAO, airport => AIRPORT,location => LOCATION}]

## (iata|icao|airport|location)2(iata|icao|airport|location)

Simple from2to mapping methods. On multiple matches the first one is taken.
Warning some iata codes have no mapping to icao code in wikipedia.

## AUTOLOAD

The module uses AUTOLOAD to call above queries.

## DESTROY

Closes internal dbi connection to sqlite db.

# UPDATE AIRPORT CODES

You can manually update the airport codes from wikipedia with the script

create/iata\_wikipedia.pl

# SEE ALSO

[http://www.nagilum.net/irssi-iata/](http://www.nagilum.net/irssi-iata/) # embedded in irssi

# AUTHOR

Graham Ollis &lt;plicease@cpan.org>

# COPYRIGHT AND LICENSE

This software is copyright (c) 2016 by Joerg Meltzer.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.
