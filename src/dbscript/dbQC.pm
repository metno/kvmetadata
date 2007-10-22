package dbQC;
require Exporter;
@ISA = qw(Exporter);
@EXPORT = qw( fhfromday fhtoday  fill_station fill_station_environment fill_param fill_obs_pgm get_fromtime get_checks_path get_checks_manual_path get_cvs_checks_manual_path get_station_param_path get_station_param_manual_path get_cvs_station_param_manual_path station_param_name get_algorithms_path get_cvs_algorithms_path get_station_path  get_param_path  get_qcx_info_path get_obs_pgm_path  get_operator_path get_types_path get_model_path get_script_path get_bin_path get_lib_path get_passwd trim default_trim default_trim_lzero trim_lzero );


use POSIX;
use strict;
use DBI;
use trim;

#trim default_trim default_trim_lzero trim_lzero

my $metadata;
my $cvs_metadata="";
my $hk;
my $dev="";

my $temp;

  $hk=$ENV{"KVALOBS"};

  if( substr($hk,-1,1) eq '/' ){
      chop($hk);
  }

  $metadata=$hk . "/share/kvalobs/metadata";

  if( defined($dev=$ENV{"METADIR"})){
      if( substr($dev,-1,1) eq '/' ){
           chop($dev);
       }
      $cvs_metadata=$dev . "/share/metadata";
  }


sub get_script_path{
    return "$hk/src/script";
}


sub get_bin_path{
    my $bin_path;
    if( defined( $bin_path=$ENV{"PATH"}) ){
	my $bin_path=trim($bin_path);
        if( length($bin_path)>0 ){
            my @sline=split /:/,$bin_path;
            my $len=@sline;
            if($len>1){
		if( defined(trim($sline[0]))){
		    return trim($sline[0]);
		}
	    }else{
		 return $bin_path;
	    }
	}
    }

    return "";
}



sub get_passwd{
    my $kvalobs;
    if( defined( $kvalobs=$ENV{"KVALOBS"}) ){
        my $kvalobs=trim($kvalobs);
	my $kvpasswd= $kvalobs . "/.kvpasswd";
	open(MYFILE,$kvpasswd ) or die "Can't open $kvpasswd: $!\n";
	my $line;
	while( defined($line=<MYFILE>) ){
            $line= trim($line);
	    if( length($line)>0 ){
		my @sline=split /\s+/,$line;
		my $len=@sline;
		if($len>1){
		    if( defined($sline[1]) ){
			return trim($sline[1]);
		    }
		}else{
		    return "";
		}
	    }
	}
	return "";
    }
}



sub get_lib_path{
    my $lib_path=$ENV{"PERL5LIB"};
    return $lib_path;
}

sub get_checks_path{
    return "$metadata/checks/checks_auto";
}


sub get_checks_manual_path{
    return "$metadata/checks/checks_manual";
}


sub get_cvs_checks_manual_path{
    return "$cvs_metadata/checks/checks_manual";
}


sub get_station_param_path{
    return "$metadata/station_param/station_param_auto";
}


sub get_station_param_manual_path{
    return "$metadata/station_param/station_param_manual";
}

sub get_cvs_station_param_manual_path{
    return "$cvs_metadata/station_param/station_param_manual";
}


sub get_algorithms_path{
    return "$metadata/algorithms";
}


sub get_cvs_algorithms_path{
    return "$cvs_metadata/algorithms";
} 


sub get_station_path{
    return "$metadata/station";
}


sub get_param_path{
    return "$metadata/param";
}


sub get_qcx_info_path{
    return "$metadata/qcx_info";
}


sub get_obs_pgm_path{  
    return "$metadata/obs_pgm";
}


sub get_operator_path{  
    return "$metadata/operator";
} 

sub get_types_path{
    return "$metadata/types";
}

sub get_model_path{
    return "$metadata/model";
}

sub station_param_name{
    my $name=shift;
    print "name= $name \n";
    my $station_param_path = get_station_param_path();
    print "station_param_path =  $station_param_path \n";
    return $station_param_path . "/$name";
}

sub get_fromtime{
    return '1500-01-01 00:00:00+00';
    # my $fromtime0file="$metadata/fromtime/fromtime_stationid_0";
    # open(MYFILE, $fromtime0file) or die "Can't open $fromtime0file: $!\n";
    # my $fromtime0 = <MYFILE>;
    # chomp($fromtime0);
    # close(MYFILE);
}


sub fhfromday{
    my %hfromday;
    $hfromday{"1"}=1;
    $hfromday{"2"}=32;
    $hfromday{"3"}=60;
    $hfromday{"4"}=91;
    $hfromday{"5"}=121;
    $hfromday{"6"}=152;
    $hfromday{"7"}=182;
    $hfromday{"8"}=213;
    $hfromday{"9"}=244;
    $hfromday{"10"}=274;
    $hfromday{"11"}=305;
    $hfromday{"12"}=335;
    return  %hfromday;
}


sub fhtoday{
    my %htoday;
    $htoday{"1"}=31;
    $htoday{"2"}=59;
    $htoday{"3"}=90;
    $htoday{"4"}=120;
    $htoday{"5"}=151;
    $htoday{"6"}=181;
    $htoday{"7"}=212;
    $htoday{"8"}=243;
    $htoday{"9"}=273;
    $htoday{"10"}=304;
    $htoday{"11"}=334;
    $htoday{"12"}=365;
return %htoday;
}




sub fill_station{
  use DBI;

  #my @driver_names = DBI->available_drivers;
  #print @driver_names;

  my $kvpasswd=get_passwd(); 
  my $dbh = DBI->connect('dbi:Pg:dbname=kvalobs',"kvalobs", $kvpasswd,{RaiseError => 1}) ||
          die "Connect failed: $DBI::errstr";

  my $sth = $dbh->prepare('select stationid from station');

  $sth->execute;

  my @row;
  my %station;

  while (@row = $sth->fetchrow_array) {
      $station{"$row[0]"}=1;
  }

  $sth->finish;
  $dbh->disconnect;

  return %station;
}


sub fill_station_environment{
  use DBI;

  #my @driver_names = DBI->available_drivers;
  #print @driver_names;

  my $kvpasswd=get_passwd(); 
  my $dbh = DBI->connect('dbi:Pg:dbname=kvalobs',"kvalobs", $kvpasswd,{RaiseError => 1}) ||
          die "Connect failed: $DBI::errstr";

  my $sth = $dbh->prepare('select stationid, environmentid from station');

  $sth->execute;

  my @row;
  my %station;

  while (@row = $sth->fetchrow_array) {
      $station{"$row[0]"}=$row[11];
  }

  $sth->finish;
  $dbh->disconnect;

  return %station;
}


sub fill_param{
    use DBI;

  #my @driver_names = DBI->available_drivers;
  #print @driver_names;

    my $kvpasswd=get_passwd();
    my $dbh = DBI->connect('dbi:Pg:dbname=kvalobs',"kvalobs", $kvpasswd,{RaiseError => 1}) ||
	die "Connect failed: $DBI::errstr";

    my $sth = $dbh->prepare('select paramid from param');

    $sth->execute;

    my @row;
    my %param;

    while (@row = $sth->fetchrow_array) {
	$param{"$row[0]"}=1;
    }

    $sth->finish;
    $dbh->disconnect;

    return %param;
}


sub fill_obs_pgm{
    use DBI;

    my $kvpasswd=get_passwd();
    my $dbh = DBI->connect('dbi:Pg:dbname=kvalobs',"kvalobs", $kvpasswd,{RaiseError => 1}) ||
	die "Connect failed: $DBI::errstr";

    my $sth = $dbh->prepare('select stationid, paramid from obs_pgm');
    $sth->execute;

    my @row;
    my %obs_pgm;

    while (@row = $sth->fetchrow_array) {
	$obs_pgm{"$row[0],$row[1]"}=1;
    }

    $sth->finish;
    $dbh->disconnect;

    return %obs_pgm;
}


1;






