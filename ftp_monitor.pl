#! /usr/bin/perl -w
#----------------------------------------------------------------------------------

use strict;
use warnings;

use Getopt::Long qw( GetOptions );
use FTPmonitor;

my $usage = "Usage: $0 ";

my $input_ftp_host;
my $input_ftp_login;
my $input_ftp_password;

my $output_ftp_host;
my $output_ftp_login;
my $output_ftp_password;

my $input_ftp_directory;
my $output_ftp_directory;

my $input_local_directory;
my $output_local_directory;

my $time_ftp_scan = 60;

my $log_file;

GetOptions(
    'input-ftp-host=s' => \$input_ftp_host,
    'input-ftp-login=s' => \$input_ftp_login,
    'input-ftp-password=s' => \$input_ftp_password,
    'input-ftp-dir=s' => \$input_ftp_directory,

    'output-ftp-host=s' => \$output_ftp_host,
    'output-ftp-login=s' => \$output_ftp_login,
    'output-ftp-password=s' => \$output_ftp_password,
    'output-ftp-dir=s' => \$output_ftp_directory,

    'input-local-dir=s' => \$input_local_directory,
    'output-local-dir=s' => \$output_local_directory,

    'log-file=s' => \$log_file,
    'time-ftp-scan=s' => \$time_ftp_scan,
) or die $usage;


my $ftp_monitor = FTPmonitor->new({
    'log_file' => $log_file,

    'input_ftp_host' => $input_ftp_host,
    'input_ftp_login' => $input_ftp_login,
    'input_ftp_password' => $input_ftp_password,
    'input_ftp_dir' => $input_ftp_directory,

    'output_ftp_host' => $output_ftp_host,
    'output_ftp_login' => $output_ftp_login,
    'output_ftp_password' => $output_ftp_password,
    'output_ftp_dir' => $output_ftp_directory,

    'input_local_dir' => $input_local_directory,
    'output_local_dir' => $output_local_directory,

    'time_ftp_scan' => $time_ftp_scan,
});

$ftp_monitor->run;

exit;
