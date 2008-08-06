#!/usr/bin/perl

use strict;
use warnings;
use DBI;
use Data::Dumper;
use YAML;
use Mail::Send;

my $Master = {
  DBUSER => 'replicant',
  DBPASS => 'deckard',
  DBHOST => 'hush.hexten.net',
};

my $Slave = {
  DBUSER => 'admin',
  DBPASS => 'spocklade',
  DBHOST => 'localhost',
};

my $Config = {
  MAILTO   => 'andy@hexten.net',
  SUBJECT  => '[slave] Slave error',
  MAXLAG   => 10_000_000,
  MAXDELAY => 1800,
};

my $master = check_server(
  $Master,
  'SHOW MASTER STATUS',
  'SELECT @@global.max_binlog_size AS max_binlog_size'
);
my $slave = check_server( $Slave, 'SHOW SLAVE STATUS' );

check_status( $Config, $master, $slave );

sub check_status {
  my ( $config, $master, $slave ) = @_;

  my @fail   = ();
  my $assert = sub {
    my ( $cond, @desc ) = @_;
    push @fail, join '', @desc unless $cond;
  };

  my $max_pos = $master->{max_binlog_size};
  my $master_pos = log_offset( $master, 'File', 'Position', $max_pos );
  my $slave_pos
   = log_offset( $slave, 'Master_Log_File', 'Exec_Master_Log_Pos',
    $max_pos );

  my $behind = $master_pos - $slave_pos;

  $assert->(
    $behind <= $config->{MAXLAG},
    "Slave is within ",
    $config->{MAXLAG}, " bytes of master (currently $behind)"
  );

  $assert->(
    $slave->{Slave_IO_Running} eq 'Yes',
    "Slave IO is running"
  );

  $assert->(
    $slave->{Seconds_Behind_Master} <= $config->{MAXDELAY},
    "Slave is less than ",
    $config->{MAXDELAY}, "seconds of master"
  );

  $assert->( 0, "Force mail" );

  if ( @fail ) {
    my $msg = Mail::Send->new;
    $msg->to( $config->{MAILTO} );
    $msg->subject( $config->{SUBJECT} );
    $msg->add('X-Is-Alert', 'Yes');
    my $fh = $msg->open;
    print $fh "Problems with slave status:\n\n";
    print $fh "  $_\n" for @fail;
    print $fh "\nMaster status:\n\n";
    print $fh Dump( $master );
    print $fh "\nSlave status:\n\n";
    print $fh Dump( $slave );
    close $fh;
    print "Mail sent\n";
  }

}

sub log_offset {
  my ( $rec, $log_file, $log_pos, $log_max ) = @_;
  my ( $file, $pos ) = @{$rec}{ $log_file, $log_pos };
  die "Can't parse log number from $file" unless $file =~ /(\d+)/;
  return $1 * $log_max + $pos;
}

sub check_server {
  my ( $config, @query ) = @_;

  my $db
   = DBI->connect( sprintf( 'DBI:mysql:host=%s', $config->{DBHOST} ),
    $config->{DBUSER}, $config->{DBPASS},
    { RaiseError => 1, AutoCommit => 1 } );

  my %status = ();
  for my $query ( @query ) {
    my $row = $db->selectrow_hashref( $query );
    %status = ( %status, %$row );
  }

  $db->disconnect;
  return \%status;

}

__DATA__

my $_master = {
  'Position'         => '16654148',
  'Binlog_Do_DB'     => '',
  'Binlog_Ignore_DB' => '',
  'File'             => 'mysql-bin.000002'
};

my $_slave = {
  'Master_SSL_Allowed'          => 'No',
  'Relay_Log_Space'             => '16654285',
  'Master_SSL_Key'              => '',
  'Master_SSL_Cipher'           => '',
  'Exec_Master_Log_Pos'         => '16654148',
  'Relay_Master_Log_File'       => 'mysql-bin.000002',
  'Master_SSL_CA_File'          => '',
  'Replicate_Ignore_DB'         => '',
  'Slave_SQL_Running'           => 'Yes',
  'Master_Port'                 => '3306',
  'Seconds_Behind_Master'       => '0',
  'Replicate_Wild_Do_Table'     => '',
  'Connect_Retry'               => '10',
  'Relay_Log_Pos'               => '16654285',
  'Last_Errno'                  => '0',
  'Skip_Counter'                => '0',
  'Until_Log_Pos'               => '0',
  'Last_Error'                  => '',
  'Master_User'                 => 'replicant',
  'Master_Host'                 => 'hush.hexten.net',
  'Master_Log_File'             => 'mysql-bin.000002',
  'Replicate_Do_Table'          => '',
  'Relay_Log_File'              => 'mysqld-relay-bin.000004',
  'Replicate_Do_DB'             => '',
  'Slave_IO_Running'            => 'Yes',
  'Replicate_Ignore_Table'      => '',
  'Slave_IO_State'              => 'Waiting for master to send event',
  'Until_Condition'             => 'None',
  'Until_Log_File'              => '',
  'Replicate_Wild_Ignore_Table' => '',
  'Master_SSL_CA_Path'          => '',
  'Read_Master_Log_Pos'         => '16654148',
  'Master_SSL_Cert'             => ''
};

