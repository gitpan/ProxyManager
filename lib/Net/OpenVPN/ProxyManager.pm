package Net::OpenVPN::ProxyManager;
use Moose;
use 5.10.0;
use Net::OpenVPN::ProxyManager::Config;
use Capture::Tiny 'capture';

our $VERSION = '0.01';

has config_path 	=> ( is => 'rw', isa => 'Str', default => '/tmp/openvpn-config.conf' );
has config			=> ( is => 'rw', isa => 'Object', builder => 'create_config');

sub test_openvpn {
	my ($self) = @_;
	my  ($stdout, $stderr, @result) = capture { system 'which', 'openvpn'; };
	$result[0] ? die qq!openvpn not found (are you using Linux?)! : 1;
	chomp $stdout;
	return $stdout;
}

sub create_config {
	my ($self, $params) = @_;
	ref $params eq 'HASH' ? Net::OpenVPN::ProxyManager::Config->new($params) : Net::OpenVPN::ProxyManager::Config->new;
}

sub connect {
	my ($self, $config_string) = @_;
	
	#check openvpn is installed
	my $openvpn_path = $self->test_openvpn;
	
	# open FH and print config file to /tmp
	open (my $fh, '>', $self->config_path() ); 
	$self->config()->print_config($fh, $config_string);
	$fh->close;
	system 'chmod', '644', $self->config_path;
	
	# run openvpn
	system 'sudo', $openvpn_path, '--config', $self->config_path;
}

no Moose;
1;

__END__

=pod

=head1 NAME

Net::OpenVPN::ProxyManager - connect to proxy servers using OpenVPN.

=head1 SYNOPSIS

	use Net::OpenVPN::ProxyManager;
	
	my $pm = Net::OpenVPN::ProxyManager->new;
	
	# Create a config object to enter proxy details
	my $config_object = $pm->create_config({remote => '100.120.3.34 53', proto => 'udp'});
	
	#Launch OpenVPN and connect to the proxy
	$pm->connect($config_object);

=head1 DESCRIPTION

Net::OpenVPN::ProxyManager is an object oriented module that provides methods to
simplify the management of proxy connections that support OpenVPN. This is a base 
generic class, see Net::OpenVPN::ProxyManager::HMA for additional methods to 
interact with hidemyass.com proxy servers. 

=head1 DEPENDENCIES

Non-Perl dependencies

OS - this module has been tested on Ubuntu linux 12.04. It should work on other Linux distros, 
perhaps OSX but probably not Windows.

OpenVPN - this module has been tested on OpenVPN version 2.2.1. I do not know if it will work 
on earlier versions. See Net::OpenVPN::Manage for a Perl module that does not require OpenVPN
to be installed.

You will also need an internet connection!

=cut

=head1 TO DO / UNSATISFACTORY STUFF

By default OpenVPN runs as root and this module uses the 'sudo' command
when starting OpenVPN. Ergh.

The module only enables connection to one proxy server per invocation.
OpenVPN only supports one connection per client, however I would like to change this to a 
forked model where connections can be initialised and dropped without closing the whole process 
via a 'disconnect' method.

=head1 AUTHOR

David Farrell, C<< <davidnmfarrell at gmail.com> >>

=head1 BUGS

Please report any bugs or feature requests to C<bug-openvpn-proxymanager at rt.cpan.org>, or through
the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=OpenVPN-ProxyManager>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.

=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc OpenVPN::ProxyManager


You can also look for information at:

=over 4

=item * RT: CPAN's request tracker (report bugs here)

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=OpenVPN-ProxyManager>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/OpenVPN-ProxyManager>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/OpenVPN-ProxyManager>

=item * Search CPAN

L<http://search.cpan.org/dist/OpenVPN-ProxyManager/>

=back


=head1 ACKNOWLEDGEMENTS


=head1 LICENSE AND COPYRIGHT

Copyright 2013 David Farrell.

This program is free software; you can redistribute it and/or modify it
under the terms of the the Artistic License (2.0). You may obtain a
copy of the full license at:

L<http://www.perlfoundation.org/artistic_license_2_0>

Any use, modification, and distribution of the Standard or Modified
Versions is governed by this Artistic License. By using, modifying or
distributing the Package, you accept this license. Do not use, modify,
or distribute the Package, if you do not accept this license.

If your Modified Version has been derived from a Modified Version made
by someone other than you, you are nevertheless required to ensure that
your Modified Version complies with the requirements of this license.

This license does not grant you the right to use any trademark, service
mark, tradename, or logo of the Copyright Holder.

This license includes the non-exclusive, worldwide, free-of-charge
patent license to make, have made, use, offer to sell, sell, import and
otherwise transfer the Package with respect to any patent claims
licensable by the Copyright Holder that are necessarily infringed by the
Package. If you institute patent litigation (including a cross-claim or
counterclaim) against any party alleging that the Package constitutes
direct or contributory patent infringement, then this Artistic License
to you shall terminate on the date that such litigation is filed.

Disclaimer of Warranty: THE PACKAGE IS PROVIDED BY THE COPYRIGHT HOLDER
AND CONTRIBUTORS "AS IS' AND WITHOUT ANY EXPRESS OR IMPLIED WARRANTIES.
THE IMPLIED WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR
PURPOSE, OR NON-INFRINGEMENT ARE DISCLAIMED TO THE EXTENT PERMITTED BY
YOUR LOCAL LAW. UNLESS REQUIRED BY LAW, NO COPYRIGHT HOLDER OR
CONTRIBUTOR WILL BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, OR
CONSEQUENTIAL DAMAGES ARISING IN ANY WAY OUT OF THE USE OF THE PACKAGE,
EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.


=cut

