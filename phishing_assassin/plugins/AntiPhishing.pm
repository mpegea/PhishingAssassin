package Mail::SpamAssassin::Plugin::AntiPhishing;

use Mail::SpamAssassin::Plugin;
use strict;
use warnings;
use re 'taint';
use Data::Dumper; # --- Tool ---
use LWP::UserAgent;

our @ISA = qw(Mail::SpamAssassin::Plugin);

sub new {
  my $class = shift;
  my $mailsaobject = shift;
  $class = ref($class) || $class;
  my $self = $class->SUPER::new($mailsaobject);
  bless ($self, $class);
  $self->register_eval_rule ("href_inspector");
  print "-----> [LOAD][href_inspector] Registered Mail::SpamAssassin::Plugin::AntiPhishing -> href_inspector\n" or die "Error writing: $!";
  $self->register_eval_rule ("ssl_checker");
  print "-----> [LOAD][ssl_checker] Registered Mail::SpamAssassin::Plugin::AntiPhishing -> ssl_checker\n" or die "Error writing: $!";
  return $self;
}

################################################################################

sub href_inspector {
  print "-----> [EVAL][href_inspector] eval_function test called\n" or die "Error writing: $!";
  my ($self, $permsgstatus, $data) = @_;
  for my $var(@$data){
    if($var=~/<a\s+href\s*=\s*"(.+)"\s*>\s*(.+)\s*<\/a>/){
      unless($1 eq $2){
        print "-----> [WARN][href_inspector] Positive evaluation\n";
        print "-----> [INFO][href_inspector] \"$2\" anchor links to $1\n";
        return 1;
      }
    }
  }
  return 0;
}

################################################################################

sub ssl_checker {
  print "-----> [EVAL][ssl_checker] eval_function test called\n" or die "Error writing: $!";
  my ($self, $permsgstatus, $data) = @_;
  my $info_message = '';
  my $positive_eval = 0;
  my $user_agent = LWP::UserAgent->new(ssl_opts => { verify_hostname => 1});
  $user_agent->timeout(3);
  for my $var(@$data){
    if($var=~/\b((?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?))\b/){ # --- TODO --- When created, move to a domain/subdomain check plugin
      $info_message = "-----> [INFO][ssl_checker] Given href is an IP: $1\n";
      $positive_eval = 1;
    }
    elsif($var=~/<a\s+href\s*=\s*"(.+)"\s*>\s*.+\s*<\/a>/){
      my $href = $1;
      if($href=~/https/){
        my $response = $user_agent->get($href);
        unless($response->is_success){
        $info_message = "-----> [INFO][ssl_checker] ".$response->status_line."\n";
        $positive_eval = 1;
        }
      }
      else{
        $info_message = "-----> [INFO][ssl_checker] Given href isn't a site that uses SSL: $href\n";
        $positive_eval = 1;
      }
    }
    if($positive_eval){
      print "-----> [WARN][ssl_checker] Positive evaluation\n";
      print "$info_message";
      return 1;
    }
  }
  return 0;
}
1;

################################################################################

## DUMPER TOOL
#my $dumper = Data::Dumper->Dump([$data]);
#print $dumper;
