package XML::Schematron;

use strict;
use SAXDriver::XMLParser;

use vars qw/$VERSION/;

$VERSION = '0.53';

sub new {
    my ($proto, %args) = @_;
    my $class = ref($proto) || $proto;
    my $self  = { schema => $args{schema} || '',
                  tests  => $args{tests}  || []};
    bless ($self, $class);
    return $self;
}

sub build_tests {
    my $self = shift;
    my $schema = $_[0] || $self->{schema};
    my $sax_handler = SchematronReader->new();
    my $sax_parser = SAXDriver::XMLParser->new( Handler => $sax_handler);
    push (@{$self->{tests}}, $sax_parser->parse($schema));
}

sub add_test {
    my $self = shift;
    my %args = @_;
    $args{pattern} ||= '[none]';
#   print "adding test $args{expr}, $args{context}, $args{message}, $args{type}, $args{pattern} \n";
    push (@{$self->{tests}}, [$args{expr}, $args{context}, $args{message}, $args{type}, $args{pattern}]);    
}

sub tests {
    my $self = shift;
    return $_[0] ? $self->{tests} = $_[0] : $self->{tests};
}

sub schema {
    my $self = shift;
    return $_[0] ? $self->{schema} = $_[0] : $self->{schema};
}
1;

package SchematronReader;
use strict;

use vars qw/$context $current_ns $action $message $test @tests $pattern/;

sub new {
    my $type = shift;
    return bless {}, $type;
}

sub start_element {
    my ($self, $el) = @_;
    my ($package, $filename, $line) = caller;
    my %attrs;

#   warn "Starting element $el->{Name}\n";

    foreach my $attr (keys %{$el->{Attributes}}) {
        $attrs{$el->{Attributes}->{$attr}->{LocalName}} = $el->{Attributes}->{$attr}->{Value};
    }

    $context = $attrs{context} if ($attrs{context});

    if (($el->{Name} =~ /(assert|report)$/)) {
        $test = $attrs{test};
    }
    elsif ($el->{Name} eq 'pattern') {
        $pattern = $attrs{name};
    }
}

sub end_element {
    my ($self, $el) = @_;
    my ($ns, $test_type);
    if (($el->{Name} =~ /(assert|report)$/)) {
        if ($el->{Name} =~ /^(.+?):(.+?)$/) {
            $ns = $1;
            $test_type = $2;
        }
        else {
            $test_type = $el->{Name};
        }

        push (@tests, [$test, $context, $message, $test_type, $pattern]);
        $message = ''; 
    }
}

sub characters {
    my ($self, $characters) = @_;
    if ($characters->{Data} =~ /[^\s\n]/g) {
        my $chars = $characters->{Data};
        $chars =~ s/\B\s\.?//g;
        $message .= $chars
    }
}

sub end_document {
     # when the doc ends, return the tests
     return @tests;
}

sub start_document {
    # sax conformance only.
}

sub processing_instruction {
    # sax conformance only.
}

sub comment {
    # sax conformance only.
}


1;
__END__
# Below is the stub of documentation for your module. You better edit it!

=head1 NAME

XML::Schematron - Perl implementation of the Schematron.

=head1 SYNOPSIS

  This package should not be used directly. Use one of the subclasses instead.

=head1 DESCRIPTION

This is the superclass for the XML::Schematron::* modules.

Please run perldoc XML::Schematron::XPath, or perldoc XML::Schematron::Sablotron for examples and complete documentation.

=head1 AUTHOR

Kip Hampton, khampton@totalcinema.com

=head1 COPYRIGHT

Copyright (c) 2000 Kip Hampton. All rights reserved. This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself. 

=head1 SEE ALSO

For information about Schematron, sample schemas, and tutorials to help you write your own schmemas, please visit the
Schematron homepage at: http://www.ascc.net/xml/resource/schematron/

=cut
