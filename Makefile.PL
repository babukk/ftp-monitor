use ExtUtils::MakeMaker;

WriteMakefile (
    AUTHOR        => 'Konstantin Bakunov <konstantin.bakunov@gmail.com>',
    ABSTRACT      => 'FTP monitor',
    NAME          => 'FTPmonitor',
    PREREQ_PM     => { Net::FTP => 0, File::Listing => 0, POSIX => 0, Log::Log4perl => 0, File::ChangeNotify => 0, },
    VERSION_FROM  => 'FTPmonitor.pm',
);
