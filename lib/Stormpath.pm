package Stormpath;
use strict;
use Carp;
use version; 
$VERSION = qv('1.0.0');

use REST::Client;

use Moo;
use namespace::clean;

use constant BASE_URL => 'https://api.stormpath.com/v1';

has 'api_key' => ( 
    is => 'ro',
    required => 1 
);

has 'client' => (
    is => 'rw',
    default => sub {
        REST::Client->new();
    }
);


has applications => (
    is          => 'ro',
    predicate   => 'has_applications',
);

has directories => (
    is          => 'ro',
    predicate   => 'has_directories',
);

has accounts => (
    is          => 'ro',
    predicate   => 'has_accounts',
);

has groups => (
    is          => 'ro',
    predicate   => 'has_groups',
);

has group_memberships => (
    is          => 'ro',
    predicate   => 'has_group_memberships',
);

has account_store_mappings => (
    is          => 'ro',
    predicate   => 'has_account_store_mappings',
);



1; # Magic true value required at end of module
__END__

=head1 NAME

Stormpath - API client for stormpath


=head1 VERSION

This document describes Stormpath version 1.0.0


=head1 SYNOPSIS

    use Stormpath;
  
  
=head1 DESCRIPTION

This is an api client for the stormpath API


=head1 INTERFACE 


=head1 DIAGNOSTICS

=for author to fill in:
    List every single error and warning message that the module can
    generate (even the ones that will "never happen"), with a full
    explanation of each problem, one or more likely causes, and any
    suggested remedies.

=over

=item C<< Error message here, perhaps with %s placeholders >>

[Description of error here]

=item C<< Another error message here >>

[Description of error here]

[Et cetera, et cetera]

=back


=head1 CONFIGURATION AND ENVIRONMENT

Stormpath requires no configuration files or environment variables.


=head1 DEPENDENCIES

    Moo
    namespace::clean
    REST::Client


=head1 INCOMPATIBILITIES

None reported.


=head1 BUGS AND LIMITATIONS

No bugs have been reported.

Please report any bugs or feature requests to
C<bug-stormpath@rt.cpan.org>, or through the web interface at
L<http://rt.cpan.org>.


=head1 AUTHOR

Tyson Maly  C<< <tvmaly@cpan.org> >>


=head1 LICENCE AND COPYRIGHT

Copyright (c) 2014, Tyson Maly C<< <tvmaly@cpan.org> >>. All rights reserved.

This module is free software; you can redistribute it and/or
modify it under the same terms as Perl itself. See L<perlartistic>.


=head1 DISCLAIMER OF WARRANTY

BECAUSE THIS SOFTWARE IS LICENSED FREE OF CHARGE, THERE IS NO WARRANTY
FOR THE SOFTWARE, TO THE EXTENT PERMITTED BY APPLICABLE LAW. EXCEPT WHEN
OTHERWISE STATED IN WRITING THE COPYRIGHT HOLDERS AND/OR OTHER PARTIES
PROVIDE THE SOFTWARE "AS IS" WITHOUT WARRANTY OF ANY KIND, EITHER
EXPRESSED OR IMPLIED, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE. THE
ENTIRE RISK AS TO THE QUALITY AND PERFORMANCE OF THE SOFTWARE IS WITH
YOU. SHOULD THE SOFTWARE PROVE DEFECTIVE, YOU ASSUME THE COST OF ALL
NECESSARY SERVICING, REPAIR, OR CORRECTION.

IN NO EVENT UNLESS REQUIRED BY APPLICABLE LAW OR AGREED TO IN WRITING
WILL ANY COPYRIGHT HOLDER, OR ANY OTHER PARTY WHO MAY MODIFY AND/OR
REDISTRIBUTE THE SOFTWARE AS PERMITTED BY THE ABOVE LICENCE, BE
LIABLE TO YOU FOR DAMAGES, INCLUDING ANY GENERAL, SPECIAL, INCIDENTAL,
OR CONSEQUENTIAL DAMAGES ARISING OUT OF THE USE OR INABILITY TO USE
THE SOFTWARE (INCLUDING BUT NOT LIMITED TO LOSS OF DATA OR DATA BEING
RENDERED INACCURATE OR LOSSES SUSTAINED BY YOU OR THIRD PARTIES OR A
FAILURE OF THE SOFTWARE TO OPERATE WITH ANY OTHER SOFTWARE), EVEN IF
SUCH HOLDER OR OTHER PARTY HAS BEEN ADVISED OF THE POSSIBILITY OF
SUCH DAMAGES.
