requires 'ExtUtils::MakeMaker', '6.64';
requires 'XML::SAX';
requires 'MooseX::NonMoose';
requires 'Moose';
requires 'MooseX::Types::Path::Class';
requires 'XML::Filter::BufferText';
requires 'Check::ISA';
requires 'MooseX::Traits';

on test => sub {
	requires 'Test::More', '0.98';
	requires 'XML::LibXSLT', 1.99;
	requires 'XML::LibXML', 2.0203;
	requires 'XML::XPath', 1.47;
};