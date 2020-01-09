use strict;
use warnings;

our %configuration;

# Assign paramters to local variables
my $NUM_LAYERS = 6;
my $NUM_BARS   = 18;                 #
my $NUM_FEUS   = 3;

my $band_xpos  = 0;
my $band_ypos  = 900;
my $band_zpos  = 655; # 700-36 "36"

my $bcolor = 'aaaaaa';
my $mbar_length = 1637;  # mm  1640
my $lbar_length = 2019;  # mm  2020
my $sbar_length = 512;   # mm  510
my $vframe_x  = 3;       # inches (previously 4)
my $vframe_y  = 1541.33; # mm
my $vframe_z  = 6;       # inches
my @vframe    = ($vframe_x/2, $vframe_y/2, $vframe_z/2);
my @vinframe  = ($vframe_x/2-0.25, $vframe_y/2, $vframe_z/2-0.25);
my @vframepos = ($band_xpos - 1078.9, $band_xpos - 448.3, $band_xpos + 448.3, $band_xpos + 1078.9); # -1060.6, -435, 435, 1060.6
 my $align_x = 565.66 - 560.57; # mm
 my $align_y = 227.70 - 210.48; # mm
# my $align_z = 0; # mm

sub build_bandMother
{
	my %detector = init_det();
	$detector{"name"}        = "band";
	$detector{"mother"}      = "root";
	$detector{"description"} = "Mother volume of BAND";
	$detector{"pos"}         = "0*mm 0*mm 350*cm";
	$detector{"rotation"}    = "0*deg 0*deg 0*deg";
	$detector{"color"}       = "339999";
	$detector{"type"}        = "Pgon"; # Tube # "200*mm 2000*mm 500*mm 0*deg 360*deg"; # "1500*mm 1600*mm 500*mm";
	$detector{"dimensions"}  = "-45*deg 360*deg 4*counts 2*counts 200*mm 200*mm 1500*mm 1500*mm 0*mm 700*mm";
	$detector{"material"}    = "G4_AIR";
	$detector{"style"}       = 0;
	print_det(\%configuration, \%detector);

	build_scintillators();
	build_frame();
	build_shielding();
}

sub build_scintillators
{
	for(my $j=1; $j<=$NUM_LAYERS; $j++)
	{
		for(my $i=1; $i<=$NUM_BARS; $i++)
		{
			my $barnum      = 100*$j + $i;

			my %detector = init_det();
			# positioning
			my $x      = $band_xpos; # "0";
			my $y      = $band_ypos; # "900";
			my $z      = $band_zpos;
			my $xpos = $x;
			my $ypos = $y - 73.69*($i-1); # 72
			my $zpos = $z - 76.75*($j-1); # 72
			my $xdim = $lbar_length/2;
			my $ydim = 36;
			my $zdim = 36;
			$bcolor  = '007fff';

			if($i<=10 || $i>=17) # long bars
			{
				if($j==$NUM_LAYERS)
				{
					$zdim = 10;
					$zpos = $zpos - 2; # +/- 26;
					$bcolor = '800080';
				}
				if($i<=3) # medium bars
				{
					$xdim = $mbar_length/2;
					$bcolor = 'ff00ff';
					if($j==$NUM_LAYERS)
						{$bcolor = '008000';}
				}

				if($j==5 && $i>=16) {next;}
				if($j==$NUM_LAYERS && $i>=16) {$zpos = $zpos + 72;}
				$detector{"name"}        = "scintillator_$barnum";
				$detector{"mother"}      = "band";
				$detector{"description"} = "Scintillator";
				$detector{"pos"}         = "$x*mm $ypos*mm $zpos*mm";
				$detector{"rotation"}    = "0*deg 0*deg 0*deg"; # -$theta*deg";
				$detector{"color"}       = $bcolor;
				$detector{"type"}        = "Box";
				$detector{"dimensions"}  = "$xdim*mm $ydim*mm $zdim*mm"; # 114*cm 114*cm 104*cm
				$detector{"material"}    = "ej200";
				$detector{"style"}       = 1;
				print_det(\%configuration, \%detector);

				for(my $k=1; $k<=2; $k++) # pmt shields
				{
					my $dx = 1138.74;
					if($i<=3)
						{$dx = 947.4;}
					my $xp = $x - $dx; # - 900;

					$detector{"name"}        = "pmtshield_$barnum L";
					my $colour               = "111111";
					if($k==2)
					{
						if($j==$NUM_LAYERS) {last;}
						$xp = $x + $dx; # 947.400;
						$detector{"name"}        = "pmtshield_$barnum R";
						$colour                  = "771111";
					}
					$detector{"mother"}      = "band";
					$detector{"description"} = "Mu metal shield for pmt";
					$detector{"pos"}         = "$xp*mm $ypos*mm $zpos*mm";
					$detector{"rotation"}    = "0*deg 90*deg 0*deg";
					$detector{"color"}       = $colour;
					$detector{"type"}        = "Tube";
					$detector{"dimensions"}  = "30.035*mm 32.725*mm 88.9*mm 0*deg 360*deg";
					$detector{"material"}    = "conetic";
					$detector{"style"}       = 1;
					print_det(\%configuration, \%detector);
				} # pmt shields

			} # long bars
			if($i>10 && $i<=16) # short bars
			{
				$bcolor = '4cbb17';
				if($j==$NUM_LAYERS)
				{
					$zdim = 10;
					$zpos = $zpos - 2; # +/- 26;
					$bcolor = '007fff';
				}
				if($j==5 && $i>=16) {next;}
				if($j==$NUM_LAYERS && $i>=16) {$zpos = $zpos + 72;}
				# Short Bars
				my $xpo = "753.5"; # 753.497 750
				my $ypo = 200 - 72*$i;
				my $zpo = $z + 72*($j-1);
				$detector{"name"}        = "scintillator_$barnum B";
				$detector{"mother"}      = "band";
				$detector{"description"} = "Short Bars";
				$detector{"pos"}         = "$xpo*mm $ypos*mm $zpos*mm";
				$detector{"rotation"}    = "0*deg 0*deg 0*deg"; # -$theta*deg";
				$detector{"color"}       = "$bcolor";
				$detector{"type"}        = "Box";
				$detector{"dimensions"}  = "255*mm 36*mm $zdim*mm"; # 114*cm 114*cm 104*cm
				$detector{"material"}    = "ej200";
				$detector{"style"}       = 1;
				print_det(\%configuration, \%detector);
			
				$bcolor = '32cd32';
				if($j==$NUM_LAYERS)
					{$bcolor = '007fff';}
				# Short Bars
				$xpo = "-753.5"; # -753.497 -750
				$detector{"name"}        = "scintillator_$barnum A";
				$detector{"mother"}      = "band";
				$detector{"description"} = "Short Bars";
				$detector{"pos"}         = "$xpo*mm $ypos*mm $zpos*mm";
				$detector{"rotation"}    = "0*deg 0*deg 0*deg";
				$detector{"color"}       = "$bcolor";
				$detector{"type"}        = "Box";
				$detector{"dimensions"}  = "255*mm 36*mm $zdim*mm";
				$detector{"material"}    = "ej200";
				$detector{"style"}       = 1;
				print_det(\%configuration, \%detector);

				for(my $k=1; $k<=4; $k++) # pmt shields
				{
					if($k>=3 && $j==$NUM_LAYERS){last;}
					my $xp = $x - 1138.74;
					$detector{"name"}        = "pmtshield_$barnum Lout";
					my $colour               = "111111";
					if($k==2)
					{
						$xp = $x + 1138.74;
						$detector{"name"}        = "pmtshield_$barnum Rout";
						$colour                  = "771111";
					}
					if($k==3)
					{
						$xp = $x - 368.263;
						$detector{"name"}        = "pmtshield_$barnum Rin";
						$colour                  = "771111";
					}
					if($k==4)
					{
						$xp = $x + 368.263;
						$detector{"name"}        = "pmtshield_$barnum Lin";
						$colour                  = "111111";
					}
					$detector{"mother"}      = "band";
					$detector{"description"} = "Mu metal shield for pmt";
					$detector{"pos"}         = "$xp*mm $ypos*mm $zpos*mm";
					$detector{"rotation"}    = "0*deg 90*deg 0*deg";
					$detector{"color"}       = $colour;
					$detector{"type"}        = "Tube";
					$detector{"dimensions"}  = "30.035*mm 32.725*mm 88.9*mm 0*deg 360*deg";
					$detector{"material"}    = "conetic";
					$detector{"style"}       = 1;
					print_det(\%configuration, \%detector);
				} # pmt shields

			} # short bars

		} # NUM_BARS
	} # NUM_LAYERS
}
sub build_frame
{
	for(my $i=1; $i<=4; $i++)
	{
		my $qnumber     = cnumber($i-1, 10);
		
		# positioning
		my $yp     = $band_ypos - 575.715; # 300
		my $zp     = $band_zpos - 533;     # 550 -> 200

		my %detector = init_det();
		$detector{"name"}        = "support_$qnumber";
		$detector{"mother"}      = "band";
		$detector{"description"} = "Vertical support beam of BAND frame";
		$detector{"pos"}         = "$vframepos[$i-1]*mm $yp*mm $zp*mm";
		$detector{"rotation"}    = "0*deg 0*deg 0*deg";
		$detector{"color"}       = "777777";
		$detector{"type"}        = "Box";
		$detector{"dimensions"}  = "$vframe[0]*inches $vframe[1]*mm $vframe[2]*inches"; # 6" x 4" or 3" x 0.25"
		$detector{"material"}    = "G4_STAINLESS-STEEL";
		$detector{"style"}       = 0;
		print_det(\%configuration, \%detector);

		# Inside of support beam
		$detector{"name"}        = "support_inside_$qnumber";
		$detector{"mother"}      = "support_$qnumber";
		$detector{"description"} = "Inside of support beam";
		$detector{"pos"}         = "0*mm 0*mm 0*mm";
		$detector{"rotation"}    = "0*deg 0*deg 0*deg";
		$detector{"color"}       = "eeeeee";
		$detector{"type"}        = "Box";
		$detector{"dimensions"}  = "$vinframe[0]*inches $vinframe[1]*mm $vinframe[2]*inches"; # 5.5" x 3.5" or 2.5" x 0.0"
		$detector{"material"}    = "G4_AIR";
		$detector{"style"}       = 0;
		print_det(\%configuration, \%detector);
	}
}

sub build_shielding
{
	my $q=0;
	for(my $n=1; $n<=$NUM_FEUS; $n++)
	{
		$q = $q + $n;
		my @lxpo = ($band_xpos - 763.065, $band_xpos - 0, $band_xpos + 763.065); # -760, 0, 760
		my @lypo = ($band_ypos - 652.850, $band_ypos - 367.6000, $band_ypos - 652.850); # 250, 570, 250
		my @lzpo = ($band_zpos - 556.097, $band_zpos - 629.3285, $band_zpos - 556.097); # 500, 650, 500 -> 250, 100, 250
		my @lnum = (19, 10, 19);
		my @sx   = (21.60/2, 39.30/2, 21.60/2); # swidth also center back plate 45.59"
		my @sz   = (1.102/2, 1.11/2, 1.102/2);  # slength center_back_plate 1.11"
		my $sy   = 2.83*$lnum[$n-1]/2;          # sheight
		my $sd   = $sx[$n-1] - 1/2;             # sdepth
		my $sb   = 0.79/2;                      # breadth

		my %detector = init_det();
		$detector{"name"}        = "leadshield_$q";
		$detector{"mother"}      = "band";
		$detector{"description"} = "Aluminum plates for lead shield $q";
		$detector{"pos"}         = "$lxpo[$n-1]*mm $lypo[$n-1]*mm $lzpo[$n-1]*mm";
		$detector{"rotation"}    = "0*deg 0*deg 0*deg";
		$detector{"color"}       = "aaaaaa";
		$detector{"type"}        = "Box";
		$detector{"dimensions"}  = "$sx[$n-1]*inches $sy*inches $sz[$n-1]*inches";
		$detector{"material"}    = "G4_Al";
		$detector{"style"}       = 0;
		print_det(\%configuration, \%detector);

		$detector{"name"}        = "leadblock_$q";
		$detector{"mother"}      = "leadshield_$q";
		$detector{"description"} = "Lead block inside shield $q";
		$detector{"pos"}         = "0*mm 0*mm 0*mm";
		$detector{"rotation"}    = "0*deg 0*deg 0*deg";
		$detector{"color"}       = "555555";
		$detector{"type"}        = "Box";
		$detector{"dimensions"}  = "$sd*inches $sy*inches $sb*inches";
		$detector{"material"}    = "G4_Pb";
		$detector{"style"}       = 0;
		print_det(\%configuration, \%detector);

		# $xpo = $xpo + 21;
		# $detector{"name"}        = "Rplate_$q";
		# $detector{"mother"}      = "crate_$qnumber";
		# $detector{"description"} = "Right plate $q";
		# $detector{"pos"}         = "$xpo*mm 0*mm $zpo*mm"; # 5*cm
		# $detector{"rotation"}    = "0*deg 0*deg 0*deg";
		# $detector{"color"}       = "888888"; #555555
		# $detector{"type"}        = "Box";
		# $detector{"dimensions"}  = "0.3*mm 116*mm 107.5*mm"; # 1*mm 133*mm 20*mm
		# $detector{"material"}    = "G4_Al";
		# $detector{"style"}       = 1;
		# print_det(\%configuration, \%detector);

		# $xpo = $xpo - 6.5;
		# $detector{"name"}        = "eboard_$q";
		# $detector{"mother"}      = "crate_$qnumber";
		# $detector{"description"} = "Electronics board $q";
		# $detector{"pos"}         = "$xpo*mm 0*mm $zpo*mm"; # 5*cm
		# $detector{"rotation"}    = "0*deg 0*deg 0*deg";
		# $detector{"color"}       = "9AB973"; #771111
		# $detector{"type"}        = "Box";
		# $detector{"dimensions"}  = "1*mm 116.75*mm 110*mm"; # 1*mm 133*mm 21*mm
		# $detector{"material"}    = "G10"; # pcb fiberglass
		# $detector{"style"}       = 1;
		# print_det(\%configuration, \%detector);
	}
}
