#! /bin/sh
#---------------------------------------------------------------------------------


./ftp_monitor.pl  \
    --input-ftp-host=10.49.12.68 \
    --input-ftp-login=ftp \
    --input-ftp-password=121212 \
    --input-ftp-dir=/incoming/test/input \
    --output-ftp-host=10.49.12.68 \
    --output-ftp-login=ftp \
    --output-ftp-password=121212 \
    --output-ftp-dir=/incoming/test/output \
    --input-local-dir=./input \
    --output-local-dir=./output \
    --log-file=./logs/log.log \
    --time-ftp-scan=1

