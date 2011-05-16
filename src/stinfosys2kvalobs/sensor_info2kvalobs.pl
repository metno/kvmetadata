#!/usr/bin/perl -w
# Kvalobs_Metadata - Free Quality Control Algorithms for Meteorological Observations
#
# $Id: station_info_avg2kvalobs.pl 1 2010-03-16 16:21:15Z terjeer $
#
# Copyright (C) 2007 met.no
#
# Contact information:
# Norwegian Meteorological Institute
# Box 43 Blindern
# 0313 OSLO
# NORWAY
# email: kvalobs-dev@met.no
#
# This file is part of KVALOBS_METADATA
#
# KVALOBS_METADATA is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License as
# published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.
#
# KVALOBS_METADATA is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
# General Public License for more details.
#
# You should have received a copy of the GNU General Public License along
# with KVALOBS_METADATA; if not, write to the Free Software Foundation Inc.,
# 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA

use strict;
use DBI;
use stinfosys;
use trim;
use dbQC;

my %hfromday = fhfromday();
my %htoday   = fhtoday();

my $len = @ARGV;

my $stname   = st_name();
my $sthost   = st_host();
my $stport   = st_port();
my $stuser   = st_user();
my $stpasswd = st_passwd();

# print " $dbname,$host,$dbuser,$passwd\n";
# exit 0;

#my $checks_path=get_checks_path();
my $DUMPDIR = ".";
if ( scalar(@ARGV) > 0 ) {
    $DUMPDIR = $ARGV[0];
}

my $outfile = ">checks_QCX.out";
open( CHECKS, $outfile ) or die "Can't open $outfile: $!\n";

my $dbh = DBI->connect( "dbi:Pg:dbname=$stname;host=$sthost;port=$stport",
    "$stuser", "$stpasswd", { RaiseError => 1 } )
  or die "Cant't connect";
my $sth;

$sth =
  $dbh->prepare(
"select max(physical_height) from sensor_info_default where measurement_methodid =217701"
  );
$sth->execute;
my $default_physical_height;
if ( my $val = $sth->fetchrow() ) {
    $default_physical_height = $val;
}

$sth->finish;

# $sth=$dbh->prepare("select stationid, hlevel, sensor, physical_height,sensor_info.fromtime from sensor_info, equipment, equipmentmodel where paramid=112 and physical_height is NOT NULL and physical_height > 0 and sensor_info.equipmentid=equipment.equipmentid and equipment.modelname=equipmentmodel.modelname and equipmentmodel.equipmenttypeid=9") or die "Can't prep\n";
$sth =
  $dbh->prepare(
"select stationid, hlevel, sensor, physical_height,sensor_info.fromtime from sensor_info where measurement_methodid=217701 and paramid=112"
  ) or die "Can't prep\n";
$sth->execute;

my $paramid = 112;
while ( my @row = $sth->fetchrow() ) {
    my $stationid       = $row[0];
    my $hlevel          = $row[1];
    my $sensor          = $row[2];
    my $physical_height = $row[3];
    my $fromtime        = $row[4];

    print_station_param( $stationid, $paramid, $hlevel, $sensor,
        $physical_height, $fromtime );

    # $calc_highest,$calc_high,$calc_low,$calc_lowest);
}
$sth->finish;
$dbh->disconnect;

print_checks($paramid);

sub print_checks {
    my ($paramid) = @_;

    my $QCX = "QC1-0";
    my $qcx = "QC1-0-autosnow";
    print CHECKS
      "0~$qcx~$QCX~1~summer_snow~obs;SA;;|meta;SA_R1;;~* * * * *~1500-01-01\n";

    $QCX = "QC1-1";
    print CHECKS
"0~$QCX-$paramid~$QCX~1~RANGE_CHECK~obs;SA;;|meta;SA_max,SA_highest,SA_high,SA_low,SA_lowest,SA_min;;~* * * * *~1500-01-01\n";
}

sub print_station_param {
    my ( $stationid, $paramid, $level, $sensor, $physical_height, $fromtime ) =
      @_;

    my $desc_metadata = "\\N";
    my $fromday       = 1;
    my $today         = 365;

    my $h;
    if ( ( !defined $physical_height ) or $physical_height eq "" ) {
        $h = ( $default_physical_height - 0.5 ) * 100;
    }
    else {
        $h = ( $physical_height - 0.5 ) * 100;
    }

    my $metadata = "max;highest;high;low;lowest;min\\n$h;$h;$h;-3.0;-3.0;-3.0";
    my $QCX      = "QC1-1";
    print
"$stationid|$paramid|$level|$sensor|$fromday|$today|$QCX-$paramid|$metadata|$desc_metadata|$fromtime\n";

    $metadata = "R1\\n2";
    my $qcx = "QC1-0-autosnow";
    print
"$stationid|$paramid|$level|$sensor|$fromday|$today|$qcx|$metadata|$desc_metadata|$fromtime\n";
}

