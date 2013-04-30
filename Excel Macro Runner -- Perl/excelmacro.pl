#!perl

##################
#
# This file was automatically generated by ZooZ.pl v1.2
# on Fri Feb  6 14:20:09 2009.
# Project: Project 1
# File:    C:/Documents and Settings/matthew.dumas/Desktop/Tools Source Code/Excel Macro Runner/ExcelMacro.zooz
#
##################

#
# Headers
#
use strict;
use warnings;
use diagnostics;

use Tk 804;

#
# Global variables
#
my (
     # MainWindow
     $MW,

     # Hash of all widgets
     %ZWIDGETS,
    );

#
# User-defined variables (if any)
#
my $Excel = undef;

my $macro = undef;

my $file = 'c:\\data';

my $nf = '0';

my $dir = 'C:/Documents and Settings/matthew.dumas/Desktop/Perl IDE/ZooZ-1.2';

my $Book = undef;


######################
#
# Create the MainWindow
#
######################

$MW = MainWindow->new;

######################
#
# Load any images and fonts
#
######################
ZloadImages();
ZloadFonts ();



# Widget Radiobutton1 isa Radiobutton
$ZWIDGETS{'Radiobutton1'} = $MW->Radiobutton(
   -text     => 'Singe File',
   -value    => 0,
   -variable => \$nf,
  )->grid(
   -row    => 0,
   -column => 0,
  );

# Widget Labelframe2 isa Labelframe
$ZWIDGETS{'Labelframe2'} = $MW->Labelframe(
   -text => 'Impedance',
  )->grid(
   -row        => 1,
   -column     => 0,
   -rowspan    => 3,
   -columnspan => 3,
  );

# Widget Label2 isa Label
$ZWIDGETS{'Label2'} = $ZWIDGETS{Labelframe2}->Label(
   -justify => 'left',
   -text    => 'File:',
  )->grid(
   -row    => 0,
   -column => 0,
  );

# Widget Label3 isa Label
$ZWIDGETS{'Label3'} = $ZWIDGETS{Labelframe2}->Label(
   -text => 'Macro Name',
  )->grid(
   -row    => 1,
   -column => 0,
  );

# Widget Button4 isa Button
$ZWIDGETS{'Button4'} = $ZWIDGETS{Labelframe2}->Button(
   -command => 'main::Process',
   -text    => 'Process',
  )->grid(
   -row        => 2,
   -column     => 0,
   -columnspan => 3,
  );

# Widget Entry2 isa Entry
$ZWIDGETS{'Entry2'} = $ZWIDGETS{Labelframe2}->Entry(
   -textvariable => \$file,
   -width        => 40,
  )->grid(
   -row    => 0,
   -column => 1,
  );

# Widget Entry3 isa Entry
$ZWIDGETS{'Entry3'} = $ZWIDGETS{Labelframe2}->Entry(
   -textvariable => \$macro,
  )->grid(
   -row        => 1,
   -column     => 1,
   -columnspan => 2,
  );

# Widget Button2 isa Button
$ZWIDGETS{'Button2'} = $ZWIDGETS{Labelframe2}->Button(
   -command => 'main::GetFile',
   -justify => 'left',
   -text    => 'Browse',
  )->grid(
   -row    => 0,
   -column => 2,
  );

# Widget Label6 isa Label
$ZWIDGETS{'Label6'} = $MW->Label()->grid(
   -row    => 4,
   -column => 0,
  );

# Widget Radiobutton2 isa Radiobutton
$ZWIDGETS{'Radiobutton2'} = $MW->Radiobutton(
   -text     => 'Multiple Files',
   -value    => 1,
   -variable => \$nf,
  )->grid(
   -row        => 0,
   -column     => 1,
   -columnspan => 2,
  );

###############
#
# MainLoop
#
###############

MainLoop;

#######################
#
# Subroutines
#
#######################

sub ZloadImages {
}

sub ZloadFonts {
}

sub DisplayBanner {
   use Tk::JPEG;

   my $img1 = $MW->Photo( 'fullscale',
        -format => 'jpeg',
        -file => 'a.jpg',
	-height => 0,
	-width => 0
    );

   $ZWIDGETS{'Label6'} = $MW->Label(
      -justify => 'left',
      -image    => $img1,
     )->grid(
      -row    => 4,
      -column => 1,
     );
}

sub Process {
   use Win32::OLE qw(in with);
   use File::List;
   use Win32::OLE::Const;
   use Win32::OLE::Const 'Microsoft Excel';
   $Win32::OLE::Warn = 3;

   $Excel = Win32::OLE->GetActiveObject('Excel.Application') || Win32::OLE->new('Excel.Application', 'Quit');  
$Excel->{Visible} = 1;

  if ($nf == 0) {    #Single File Only
	$Book = $Excel->Workbooks->Open( $file );

	&_macro;
	system("pause");
	$Book->Close;
  }
  if ($nf == 1) {   #directory search
	my $search = new File::List($dir);
	my @files  = @{ $search->find("Reg.xls") };  
        my $b;


       foreach $b (@files) {
	   $Book = $Excel->Workbooks->Open( $b );
	   &_macro;
	system("pause");
	   $Book->Close;
	   print $b."\n";
       }
  }
	
}

sub GetFile {
if ($nf == 0) {
 my (@dump,$r,$p,$dump);

   my $f = $MW->getOpenFile(-title => 'Choose File to Open',
			   -defaultextension => '.xls',
			   -initialdir       => $dir,
			   -filetypes        =>
			   [
			    ['Excel 97-2000',   '.xls'],
			    ['Excel 2007',   '.xlsx'],
			    ['All Files',  '*'    ],
			   ]
			  );
  $file = $f;

 } 
if ($nf == 1) { 
    $dir = $MW->chooseDirectory(-title => 'Choose location of files',			  
			   -initialdir       => $dir,
			   -mustexist        => 1
			  );
    
}


}

sub _macro {
#   my $chart = $Book->Charts->Add({After => $Book->Worksheets($num_of_Sheets)})  || die Win32::OLE->LastError(); 
    my $s = $Book->ActiveSheet->Name;

    $Book->Sheets($s)->Select;
    $Book->ActiveSheet->Shapes->AddChart->Select;
    my $r = $Book->ActiveSheet->Range("\$A:\$D");
    $Book->ActiveChart->SetSourceData({Source=>$r, PlotBy=>xlColumns});
    $Book->ActiveChart->{ChartType} = xlLine;
      
          

    $Book->ActiveChart->SeriesCollection(4)->{AxisGroup} = xlSecondary;

    
    $Book->ActiveChart->Axes(xlValue, xlSecondary)->{MinimumScale} = 0;
    $Book->ActiveChart->Axes(xlValue, xlSecondary)->{MaximumScale} = 12;
    $Book->ActiveChart->Axes(xlValue, xlSecondary)->{MajorUnit} = 2;
    $Book->ActiveChart->Axes(xlValue, xlSecondary)->{MaximumScale} = 14;
    $Book->ActiveChart->Axes(xlValue, xlSecondary)->{MajorUnit} = 1;
    $Book->ActiveChart->Axes(xlValue, xlSecondary)->{ReversePlotOrder} = 1;
    $Book->ActiveChart->Axes(xlValue, xlSecondary)->{Crosses} = xlMaximum;

     
    $Book->ActiveChart->Axes(xlValue)->{CrossesAt} = 0;
    $Book->ActiveChart->Axes(xlValue)->{CrossesAt} = -20;
    $Book->ActiveChart->{HasTitle} = 1;    
#    $Book->ActiveChart->{Name} = "Signals in 1750 Swipe";
     
    $Book->ActiveChart->ChartTitle->{Text} = "Signals In 1750 Swipe";

    $Book->ActiveChart->Axes(xlCategory, xlPrimary)->{HasTitle} = 1;
    $Book->ActiveChart->Axes(xlValue, xlPrimary)->{HasTitle} = 1;
    $Book->ActiveChart->Axes(xlValue, xlPrimary)->AxisTitle->{Text} = "mV (left)/Gain Step (right)";     
    $Book->ActiveChart->Axes(xlCategory, xlPrimary)->AxisTitle->{Text} = "Slice number, bottom of finger is 1";
    $Book->ActiveChart->Location({Where=>xlLocationAsNewSheet, Name=>"Signal Chart"});
    
    $Book->Sheets($s)->Select;
    $Book->Sheets($s)->Activate;
    $Book->ActiveSheet->Shapes->AddChart->Select;
    $r = $Book->ActiveSheet->Range("\$D:\$D");
    $Book->ActiveChart->SetSourceData({Source=>$r, PlotBy=>xlColumns});
    $Book->ActiveChart->{ChartType} = xlLineMarkers;
    $Book->ActiveChart->Location({Where=>xlLocationAsNewSheet, Name=>"Gain Chart"});
    $Book->ActiveChart->{HasTitle} = 1;
    $Book->ActiveChart->ChartTitle->{Text} = "Gain over Swipe";
     
     
    $Book->ActiveChart->Axes(xlValue)->{MinimumScale} = 0;
    $Book->ActiveChart->Axes(xlValue)->{MaximumScale} = 12;
    $Book->ActiveChart->Axes(xlValue)->{MajorUnit} = 2;
    $Book->ActiveChart->Axes(xlValue)->{MaximumScale} = 14;
    $Book->ActiveChart->Axes(xlValue)->{MajorUnit} = 1;
    $Book->ActiveChart->Axes(xlValue)->{Crosses} = xlMaximum;
    $Book->ActiveChart->Axes(xlValue)->{ReversePlotOrder} = 1;
    $Book->ActiveChart->ApplyLayout(10);
     
         
    $Book->ActiveChart->Axes(xlValue, xlPrimary)->AxisTitle->{Text} = "Gain Step";  
    $Book->ActiveChart->Axes(xlCategory, xlPrimary)->AxisTitle->{Text} = "Slice, 1 is bottom of finger";
     
}
