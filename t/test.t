use Test::More qw[no_plan];
use strict;
$^W = 1;

use_ok 'FTPmonitor';

ok(
my $ftp_monitor = FTPmonitor->new({
    'log_file' => 'logs/log.log',
    'input_ftp_host' => 'localhost',
    'input_ftp_login' => 'ftp',
    'input_ftp_password' => '1234',
    'input_ftp_dir' => '/incoming',
    'output_ftp_host' => 'localhost',
    'output_ftp_login' => 'ftp',
    'output_ftp_password' => '1234',
    'output_ftp_dir' => '/incoming',
    'input_local_dir' => './input',
    'output_local_dir' => './output',
    'time_ftp_scan' => 60,
})
,
'Can-t create instance of FTPmonitor'
);

