# Kvalobs_Metadata - Free Quality Control Algorithms for Meteorological Observations 
#
# $Id$ 
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


#checkname:	snowcover_warmground
#signature: obs;EM,TGN_12;;
# Konsistenskontroll_Check
# gj�r noen tester og returner en ny verdi for flag
# Siva Navaratnam  Wed Jun 11 11:28:28 2003

sub check {
#tolererer ingen manglende observasjoner:
	if ($obs_missing > 0) {
		# aborter..
		return 0;
	}

	my $flag = 1;

	if (($EM[0] >= 5 && $EM[0] <= 8) && $TGN_12[0] > 0) {
		$flag = 3;
	}

	my @retvector;
	push(@retvector, "EM_0_0_flag");
	push(@retvector, $flag);
	push(@retvector, "TGN_12_0_0_flag");
	push(@retvector, $flag);
	my $numout = @retvector; # antall returverdier

	return (@retvector, $numout);
}
