package FTPmonitor;

use strict;
use warnings;

use threads;
use Net::FTP;
use File::Listing qw(parse_dir);
use POSIX qw(strftime);
use File::ChangeNotify;
use Data::Dumper;

# ----------------------------------------------------------------------------------------------------------------------

sub new {
    my ($class, $params) = @_;

    my $self;

    while (my ($k, $v) = each %{$params}) {
        $self->{ $k } = $v;
    }

    bless $self, $class;

    if ($self->{ 'log_file' }) {
        require Log::Log4perl;

        my $log_conf =  '
            log4perl.rootLogger              = DEBUG, LOG1
            log4perl.appender.LOG1           = Log::Log4perl::Appender::File
            log4perl.appender.LOG1.filename  = ' . $self->{ 'log_file' } . '
            log4perl.appender.LOG1.mode      = append
            log4perl.appender.LOG1.layout    = Log::Log4perl::Layout::PatternLayout
            log4perl.appender.LOG1.layout.ConversionPattern = %d %p %m %n
        ';

        eval {
            $self->{ 'logger' } = Log::Log4perl->get_logger();
            Log::Log4perl::init(\$log_conf);
        };
    }

    return $self;
}

# ----------------------------------------------------------------------------------------------------------------------

sub run {
    my ($self) = @_;


    $self->{ 'ftp_mon_thread' } = threads->create(sub{ $self->threadFtpProc; });
    $self->{ 'local_mon_thread' } = threads->create(sub{ $self->threadLocalFilesProc; });

    sleep $self->{ 'time_ftp_scan' }  while (1);
}

# ----------------------------------------------------------------------------------------------------------------------

sub threadFtpProc {
    my ($self) = @_;

    $self->connect_input_ftp;

    while (1) {
        my $files = $self->{ 'input_ftp' }->dir;
        foreach my $entry (parse_dir($files)) {
            my ($fileName, $type, $size, $mtime, $mode) = @{$entry};
            next unless $type eq 'f';
            $self->copyFileFtpToLocalDir($fileName)  unless  -f $self->{ 'input_local_dir' } . '/' . $fileName;
        }

        sleep $self->{ 'time_ftp_scan' };
    }

    return;
}

# ----------------------------------------------------------------------------------------------------------------------

sub copyFileFtpToLocalDir {
    my ($self, $file) = @_;

    $self->{ 'logger' }->info('Copying file ' . $file . ' from FTP to local dir.');
    $self->{ 'input_ftp' }->get($file, $self->{ 'input_local_dir' } . '/' . $file);
    $self->{ 'logger' }->info('File ' .  $file . ' has been copied.');

    return;
}

# ----------------------------------------------------------------------------------------------------------------------

sub threadLocalFilesProc {
    my ($self) = @_;

    $self->{ 'local_files_watcher' } = File::ChangeNotify->instantiate_watcher(
            'directories' => [ $self->{ 'output_local_dir' } ],
    );

    while (my @events = $self->{ 'local_files_watcher' }->wait_for_events) {
        # print Dumper(@events);
        foreach my $ev (@events) {
            if ($ev->{ 'type' } eq 'create') {
                if (-f $ev->{ 'path' }) {
                    $self->{ 'logger' }->info('New file created: ' .  $ev->{ 'path' });
                    $self->sendFileToftp($ev->{ 'path' });
                }
            }
        }
    }

    return;
}

# ----------------------------------------------------------------------------------------------------------------------

sub sendFileToftp {
    my ($self, $file) = @_;

    $self->{ 'logger' }->info('Trying to send file ' .  $file );
    $self->connect_output_ftp;
    $self->{ 'output_ftp' }->cwd($self->{ 'output_ftp_dir' });
    $self->{ 'output_ftp' }->put($file);
    $self->{ 'output_ftp' }->quit;
    $self->{ 'logger' }->info('File ' .  $file . ' has been sent.');

    return;
}

# ----------------------------------------------------------------------------------------------------------------------

sub connect_input_ftp {
    my ($self) = @_;

    $self->{ 'input_ftp' } = Net::FTP->new($self->{ 'input_ftp_host' }, Debug => 0);
    $self->{ 'input_ftp' }->login($self->{ 'input_ftp_login' }, $self->{ 'input_ftp_password' });
    $self->{ 'input_ftp' }->binary;
    $self->{ 'input_ftp' }->cwd($self->{ 'input_ftp_dir' });

    return;
}

# ----------------------------------------------------------------------------------------------------------------------

sub connect_output_ftp {
    my ($self) = @_;

    $self->{ 'output_ftp' } = Net::FTP->new($self->{ 'output_ftp_host' }, Debug => 0);
    $self->{ 'output_ftp' }->login($self->{ 'output_ftp_login' }, $self->{ 'output_ftp_password' });
    $self->{ 'output_ftp' }->binary;
    $self->{ 'output_ftp' }->cwd($self-{ 'output_ftp_dir' });

    return;
}

1;
