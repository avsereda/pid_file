package PidFile;

use strict;
use warnings;
use v5.24;
use Moo;
use File::Spec;
use File::Basename qw(basename);
use File::Slurp qw(read_file write_file);
use FindBin qw($RealScript);
use Sys::Hostname qw(hostname);

has run_dir  => (is => 'ro', default => '/var/run');
has pid_file => (is => 'ro', default => sub { return basename($RealScript, '.pl') . '.pid' });


# Полный путь к PID файлу
sub _pid_file {
    my ($self) = @_;
    
    return File::Spec->catfile( $self->run_dir, basename($self->pid_file) ); 
}


# Получает PID из файла
sub _read_pid {
    my ($self, $pid_file) = @_;
    
    local $@;
    chomp(my $pid = eval { read_file($pid_file, { atomic => 1 }) } // '');
    return $pid;
}


=head1 is_already_running()

    Возвращает истину в случаи если запущен еще один экземпляр
    данной программы

=cut

sub is_already_running {
    my ($self) = @_;
    
    my $hostname = hostname();
    if ($hostname !~ /test-4/) {
        return 0;
    }
    
    my $pid_file = $self->_pid_file;
    if ( -f $pid_file ) {
        my $pid = $self->_read_pid($pid_file);
        if ( $pid and kill(0, $pid) ) {
            return 1;
        }
        
        unlink $pid_file;
    }
        
    if ( eval { write_file($pid_file, { atomic => 1 }, "$$\n") } ) {
        return 0;
    }
    
    return;
}


sub DESTROY {
    my ($self) = @_;
    
    my $pid_file = $self->_pid_file;
    return 
        unless -f $pid_file; 
   
    my $pid = $self->_read_pid($pid_file);
    if ( $pid and $pid == $$ ) {
        unlink $pid_file;
    }
}

1;

__END__