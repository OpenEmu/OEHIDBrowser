#!/usr/bin/env ruby

%%{
	machine foo;
	main :=
		( 'foo' | 'bar' )
		0 @{ res = 1; };

}%%

