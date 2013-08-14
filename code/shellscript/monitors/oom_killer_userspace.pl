#!/usr/bin/perl -w
# From: http://stackoverflow.com/questions/2125812/what-is-the-best-way-to-prevent-out-of-memory-oom-freezes-on-linux
# Checks available memory usage and calculates size in MB
# If free memory is below your minimum level specified, then
# the script will attempt to close the troublesome processes down
# that you specify. If it can't, it will issue a -9 KILL signal.
#
# Uses external commands (cat and pidof)
#
# Cheers, insertable

our $memmin = 50;
our @procs = qw(/usr/bin/firefox /usr/local/sbin/apache2);

sub killProcs
{
    use vars qw(@procs);
    my @pids = ();
    foreach $proc (@procs)
    {
        my $filename=substr($proc, rindex($proc,"/")+1,length($proc)-rindex($proc,"/")-1);
        my $pid = `pidof $filename`;
        chop($pid);
        my @pid = split(/ /,$pid);
        push @pids, $pid[0];
    }
    foreach $pid (@pids)
    {
        #try to kill process normall first
        system("kill -15 " . $pid); 
        print "Killing " . $pid . "\n";
        sleep 1;
        if (-e "/proc/$pid")
        {
            print $pid . " is still alive! Issuing a -9 KILL...\n";
            system("kill -9 " + $pid);
            print "Done.\n";
        } else {
            print "Looks like " . $pid . " is dead\n";
        }
    }
    print "Successfully finished destroying memory-hogging processes!\n";
    exit(0);
}

sub checkMem
{
    use vars qw($memmin);
    my ($free) = $_[0];
    if ($free > $memmin)
    {
        print "Memory usage is OK\n";
        exit(0);
    } else {
        killProcs();
    }
}

sub main
{
    my $meminfo = `cat /proc/meminfo`;
    chop($meminfo);
    my @meminfo = split(/\n/,$meminfo);
    foreach my $line (@meminfo)
    {
        if ($line =~ /^MemFree:\s+(.+)\skB$/)
        {
            my $free = ($1 / 1024);
            &checkMem($free);
        }
    }
}

main();
