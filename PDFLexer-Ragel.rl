//
//  PDFLexer-Ragel.rl
//  LayerLink
//
//  Created by Eric Ocean on Thu Jul 15 2004.
//  Copyright (c) 2004 Eric Daniel Ocean. All rights reserved.
//

#import "PDFLexer.h"
#import "PDFObjects.h"


#define IDENT_BUFLEN 256

%% PDFParsingMachine
	alphtype unsigned char;
	
	#*************************************************************************************************************#
	# global information #
	
	# Each machine that returns an object is setup to do so upon _leaving_ the machine.
	# The diagrams were generated from the machine (only), so you'll see that transition on reaching EOF
	# In the final machine used to parse the PDF, it will happen on every round of the Kleene star
	#
	# None of the machines repeat by themselves; they are all one-shot machines.
	
	#*************************************************************************************************************#
	# the whitespace, eol, delimiter, regular, and comment machines #
	
	# whitespace in a PDF file includes the NULL character, and consecutive whitespace is treated as one
	whitespace = /[\t\f\n\r\0 ]/ ;

	eol = /[\r\n]/ | '\r\n' ;
	
	delimiter = [()<>\[\]{}/%] ;
	
	regular = any - ( whitespace | delimiter ) ;

	# The priority bump on the terminator of the comments brings us out of the extend* which matches everything.
	comment = '%' . extend* $0 . eol @1 ;
	
	#*************************************************************************************************************#
	# the boolean machine #
	
	action false {
		fsm->boolVal = NO;
	}
	
	action true {
		fsm->boolVal = YES;
	}
	
	action boolean {
		[fsm->self addToken:[PDFBoolean booleanWithBool:fsm->boolVal]];
	}
	
	# Boolean objects can be used as the values of array elements and dictionary entries, and
	# can also occur in PostScript calculator functions as the results of boolean and
	# relational operators and as operands to the conditional operators if and ifelse
	boolean = (( 'true' >true ) | ( 'false' >false )) %boolean ;
	
	#*************************************************************************************************************#
	# the number machine #
	
	init {
		fsm->nullByte = 0;
	}
	
	action setupNum {
		fsm->numChars = [[NSMutableData alloc] initWithCapacity:10];
		fsm->isReal = NO;
	}

	action bufNum {
		[fsm->numChars appendBytes:&fc length:1];
	}
	
	action number {
		[fsm->numChars appendBytes:&fsm->nullByte length:1];
		
		// search for decimal point, yes, make real number; no, make integer number
		int length = [fsm->numChars length];
		char *buffer = (char *)[fsm->numChars bytes];
		int i;
		
		for ( i = 0; i < length; i++ )
		{
			char c = buffer[i];
			if ( c == '.' ) fsm->isReal = YES; 
		}
		
		if ( fsm->isReal )
		{
			[fsm->self addToken:[PDFRealNumber realNumberWithString:
														[NSString stringWithCString:(char *)[fsm->numChars bytes]]]];
		}
		else
		{
			[fsm->self addToken:[PDFIntegerNumber integerNumberWithString:
														[NSString stringWithCString:(char *)[fsm->numChars bytes]]]];
		}
		
		[fsm->numChars release]; fsm->numChars = nil;
	}
	
	integer = [+\-]? digit+ ;
	
	# A float is at least one decimal digit and a point, which can lead or trail, with an optional sign in front
	float = [+\-]? (( digit* '.' digit+ ) | ( digit+ '.' digit* )) ;
	
	# Executes A on entering the machine and B upon leaving.
	number = ( integer | float ) >setupNum $bufNum %number;
	
	#*************************************************************************************************************#
	# the hexString machine #
	
	action setupHex {
		fsm->hexChars = [[NSMutableData alloc] initWithCapacity:512];
		fsm->hexByte = 0;
		fsm->hexChar1 = 0;
		fsm->hexChar2 = 0;
		fsm->shouldSetFirstHexChar = YES;
	}
	
	action bufHex {
		// we only add the byte we're building after every two hex characters
		if ( fsm->shouldSetFirstHexChar )
		{
			fsm->hexChar1 = fc;
			fsm->shouldSetFirstHexChar = NO;
		}
		else
		{
			fsm->hexChar2 = fc;
			fsm->hexByte = hexToUChar( fsm->hexChar1 , fsm->hexChar2 );
			[fsm->hexChars appendBytes:&fsm->hexByte length:1];
			fsm->shouldSetFirstHexChar = YES;
			fsm->hexByte = 0; // reinitialize the byte
			fsm->hexChar1 = 0; // reinitialize the first hex char
			fsm->hexChar2 = 0; // reinitialize the second hex char
		}
	}
	
	action hexString {
		// add the final byte to the data if it wasn't already added (because only one of the two hex chars was provided)
		if ( fsm->shouldSetFirstHexChar == NO ) fsm->hexByte = hexToUChar( fsm->hexChar1 , fsm->hexChar2 );
		[fsm->hexChars appendBytes:&fsm->hexByte length:1];
		
		[fsm->self addToken:[PDFString stringWithData:fsm->hexChars]];
		[fsm->hexChars release]; fsm->hexChars = nil;
	}
	
	# Executes setupHex on entering the machine, bufHex on encountering each hex digit, and hexString when finished.
	# The spec states, indirectly, that comments don't occur within strings. I'm assuming that includes hex strings.
	hexString = ('<' >setupHex . (whitespace? (xdigit >bufHex))* (whitespace? '>')) %hexString;

	#*************************************************************************************************************#
	# the name machine #

	action setupName {
		fsm->nameChars = [[NSMutableData alloc] initWithCapacity:64];
		fsm->nameHexByte = 0;
		fsm->nameHexChar1 = 0;
	}
	
	action bufNameChar {
		[fsm->nameChars appendBytes:&fc length:1];
	}
	
	action bufFirstHexChar {
		fsm->nameHexChar1 = fc;
	}
	
	action bufSecondHexCharNameChar {
		fsm->nameHexByte = hexToUChar( fsm->nameHexChar1 , fc ); // fc is the second hex char
		
		[fsm->nameChars appendBytes:&fsm->nameHexByte length:1];
		
		fsm->nameHexByte = 0; // reinitialize the byte
		fsm->nameHexChar1 = 0; // reinitialize the first hex char
	}

	action name {
		[fsm->nameChars appendBytes:&fsm->nullByte length:1];
		[fsm->self addToken:[PDFName nameWithString:[NSString stringWithCString:(char *)[fsm->nameChars bytes]]]];
								
		[fsm->nameChars release]; fsm->nameChars = nil;
	}
	
	# This is a fairly complicated machine.
	# On entrance, the machine executes setupName,
	# then after each character of the name it executes bufNameChar,
	# unless the character is the '#" escape character, in which case it executes nothing.
	# After reading the first hex character after the escape code it executes bufFirstHexChar,
	# and after the second hex character it executes bufSecondHexCharNameChar.
	# Finally, when the machine leaves, it executes name.
	# Note that a name can be zero length.
	name = ( '/' >setupName . ( ( regular - '#' ) $bufNameChar | ( '#' . ( xdigit >bufFirstHexChar . xdigit @bufSecondHexCharNameChar ) ) )* ) %name;

	#*************************************************************************************************************#
	# the literalString machine #
	
	action lineFeed {
		fsm->appendByte = '\n';
		[fsm->literalChars appendBytes:&fsm->appendByte length:1];
	}
	
	action carriageReturn {
		fsm->appendByte = '\r';
		[fsm->literalChars appendBytes:&fsm->appendByte length:1];
	}
	
	action horizontalTab {
		fsm->appendByte = '\t';
		[fsm->literalChars appendBytes:&fsm->appendByte length:1];
	}
	
	action backspace {
		fsm->appendByte = 8;
		[fsm->literalChars appendBytes:&fsm->appendByte length:1];
	}
	
	action formFeed {
		fsm->appendByte = '\f';
		[fsm->literalChars appendBytes:&fsm->appendByte length:1];
	}
	
	action leftParen {
		fsm->appendByte = '(';
		[fsm->literalChars appendBytes:&fsm->appendByte length:1];
	}
	
	action rightParen {
		fsm->appendByte = ')';
		[fsm->literalChars appendBytes:&fsm->appendByte length:1];
	}
	
	action backslash {
		fsm->appendByte = '\\';
		[fsm->literalChars appendBytes:&fsm->appendByte length:1];
	}
	
	action beginOctal {
		fsm->octalByte = 0;
		fsm->octal1 = 0;
		fsm->octal2 = 0;
		fsm->octal3 = 0;
		fsm->octalCharToBuf = 1;
	}
	
	action bufOctal {
		switch ( fsm->octalCharToBuf ) {
		case 1: fsm->octal1 = fc; fsm->octalCharToBuf = 2; break;
		case 2: fsm->octal2 = fc; fsm->octalCharToBuf = 3; break;
		case 3: fsm->octal3 = fc; fsm->octalCharToBuf = 4; break;
		// case 4 never occurs; see state machine for details
		}
	}
	
	action octal {
		switch ( fsm->octalCharToBuf ) {
		// case 1 never occurs; see state machine for details
		case 2: fsm->octalByte = octalToUChar( '0', '0', fsm->octal1 ); break;
		case 3: fsm->octalByte = octalToUChar( '0', fsm->octal1, fsm->octal2 ); break;
		case 4: fsm->octalByte = octalToUChar( fsm->octal1, fsm->octal2, fsm->octal3 ); break;
		}
		
		[fsm->literalChars appendBytes:&fsm->octalByte length:1];
	}
	
	action bufLiteralChar {
		fsm->charBuf = fc;
	}
	
	action nonEscapeChars {
		// increase the left parenthesis count whenever we encounter one
		// only escaped left parenthesis aren't counted
		if ( fsm->charBuf == '(' ) fsm->leftParenCount += 1;
		
		[fsm->literalChars appendBytes:&fsm->charBuf length:1];
	}

	action beginLiteralString {
		fsm->literalChars = [[NSMutableData alloc] initWithCapacity:512];
		fsm->leftParenCount = 1;
	}
	
	action evaluateRightParenthesis {
		// this is not called for escaped right parenthesis, which do not count towards the parenthesis matching
	
		fsm->leftParenCount -= 1; // match our left parenthesis
		
		// when all the left parenthesis have been matched with their right parenthesis, we're done
		if ( fsm->leftParenCount != 0 )  fgoto nextChar; // we're not finished
	}
	
	action literalString {
		[fsm->self addToken:[PDFString stringWithData:fsm->literalChars]];
								
		[fsm->literalChars release]; fsm->literalChars = nil;
	}


	lp = '(';
	rp = ')';
	
	octal = [0-7]; # I think this is right, but I'm not sure
	
	# 92 is the number for the '\' character
	escape = 92 . ( ([n] %lineFeed) | ([r] %carriageReturn) | ([t] %horizontalTab) | ([b] %backspace) | ([f] %formFeed) | ([(] %leftParen) | ([)] %rightParen) | (92 %backslash) | (octal{1,3} >beginOctal $bufOctal %octal) | eol );
	
	nonEscapeChars = ( any - (rp|92) ) $bufLiteralChar %nonEscapeChars ;
	
	recordChar = ( nonEscapeChars | escape );
	
	# This is a fairly subtle machine. If you look at the diagram, you'll see that I labeled state 1 "nextChar".
	# Literal strings in PDF allow for unescaped, matched parenthesis. Unmatched parenthesis must be escaped.
	# There are also a plethora of escape codes and escape sequences, along with an eol backslash continuation character.
	literalString = (( ( (lp $0 >beginLiteralString) | ( lp . ( nextChar: recordChar** ) ))) . ( rp >1 >evaluateRightParenthesis ) ) %literalString ;
	
	#*************************************************************************************************************#
	# the array machines #
	
	action beginArray {
		[fsm->self addToken:[PDFToken beginArray]];
	}
	
	action endArray {
		[fsm->self addToken:[PDFToken endArray]];
	}
	
	beginArray = '[' %beginArray ;
	endArray = ']' %endArray ;
	
	# The remainder of the parsing logic is handled by an array parser.
	
	#*************************************************************************************************************#
	# the dictionary and pdfNull machines #
	
	action beginDict {
		[fsm->self addToken:[PDFToken beginDict]];
	}
	action endDict {
		[fsm->self addToken:[PDFToken endDict]];
	}
	
	beginDict = '<<' %beginDict ;
	endDict = '>>' %endDict ;
	
	action pdfNull {
		[fsm->self addToken:[PDFToken pdfNull]];
	}
	
	pdfNull = 'null' %pdfNull;
	
	# The remainder of the parsing logic is handled by a dictionary parser.
	
	#*************************************************************************************************************#
	# the stream machine #
	
	# This machine only retrieves the raw stream data; it does not parse that data in any way.
	# It's a little odd, in that it adds three tokens instead of the usual one.
	
	action beginStream {
		[fsm->self addToken:[PDFToken beginStream]];
		fsm->streamBytes = [[NSMutableData alloc] initWithCapacity:512];
	}
	
	action bufStream {
		[fsm->streamBytes appendBytes:&fc length:1];

	} 
	
	action stream {
		// bufStream records 8 bytes more data then necessary: endstrea
		[fsm->self addToken:[PDFStreamData streamDataWithData:
									[fsm->streamBytes subdataWithRange:NSMakeRange( 0, ([fsm->streamBytes length] - 8) )]]];
		[fsm->self addToken:[PDFToken endStream]];
		[fsm->streamBytes release]; fsm->streamBytes = nil;
	}
																					# this isn't quite right;
																					# their could be an unused end-of-line
																					# marker included
	stream = ( ('stream' >beginStream) . ( [\n] | "\r\n" ) . any* $0 $bufStream . (('endstream') @1) ) %stream;
	
	# The remainder of the parsing logic is handled by a stream parser.
	# It expects to see an indirect object, then a dictionary, then a beginStream token, and then an NSData, followed
	# by an endStream token.

	#*************************************************************************************************************#
	# the indirectObject machines #
	
	action beginIndirectObject {
		[fsm->self addToken:[PDFToken beginIndirectObject]];
	}
	action endIndirectObject {
		[fsm->self addToken:[PDFToken endIndirectObject]];
	}
		
	beginIndirectObject = 'obj' %beginIndirectObject ;
	endIndirectObject = 'endobj' %endIndirectObject ;
	
	# The remainder of the parsing logic is handled by an indirect object parser.

	#*************************************************************************************************************#
	# the indirectObjectReference machine #
	
	action indirectObjectReference {
		[fsm->self addToken:[PDFToken objectReference]];
	}
		
	indirectObjectReference = 'R' %indirectObjectReference ;
		
	#*************************************************************************************************************#
	# the xref machine #
	
	action beginXref {
		[fsm->self addToken:[PDFToken xref]];
	}
		
	beginXref = 'xref' %beginXref ;
		
	#*************************************************************************************************************#
	# the trailer machine #
	
	action beginTrailer {
		[fsm->self addToken:[PDFToken trailer]];
	}
		
	beginTrailer = 'trailer' %beginTrailer ;
		
	#*************************************************************************************************************#
	# the startxref machine #
	
	action beginStartxref {
		[fsm->self addToken:[PDFToken startxref]];
	}
		
	beginStartxref = 'startxref' %beginStartxref ;
		
	#*************************************************************************************************************#
	# the free machine #
	
	action beginFree {
		[fsm->self addToken:[PDFToken pdfFree]];
	}
		
	beginFree = 'f' %beginFree ;
		
	#*************************************************************************************************************#
	# the inUse machine #
	
	action beginInUse {
		[fsm->self addToken:[PDFToken inUse]];
	}
		
	beginInUse = 'n' %beginInUse ;
		
	#*************************************************************************************************************#
	# the operator machine #
	
	action setupOperator {
		fsm->operatorChars = [[NSMutableData alloc] initWithCapacity:4];
	}
	
	action bufOperatorChar {
		[fsm->operatorChars appendBytes:&fc length:1];
	}
	
	action operator {
		[fsm->operatorChars appendBytes:&fsm->nullByte length:1];
		[fsm->self addToken:[PDFOperator operatorWithString:
											[NSString stringWithCString:(char *)[fsm->operatorChars bytes]]]];
								
		[fsm->operatorChars release]; fsm->operatorChars = nil;
	}
	
	opchars = ( alnum | ['"*] );
	
	operator = ( alpha >setupOperator . ( opchars $bufOperatorChar )* ) %operator;

	#*************************************************************************************************************#
	# the PDFParsingMachine machine #
	
	# Or together then star all the lanuage elements. Use the longest match
	# kleene star operator This is so that when we see 'aa' we stay in the fin
	# machine to match an ident of length two and not wrap around to the front
	# to match two idents of length one.
	PDFParsingMachine_main = ( 
		whitespace |
		comment |
		boolean |
		number |
		hexString |
		name |
		literalString |
		beginArray |
		endArray |
		beginDict |
		endDict |
		pdfNull |
		stream |
		beginIndirectObject |
		endIndirectObject |
		indirectObjectReference |
		beginXref |
		beginTrailer |
		beginStartxref |
		beginFree |
		beginInUse )**;

	# This machine matches everything, taking note of newlines.
	# XXX I'm not sure this machine is correct, so I'm not using it.
	# newline = ( any | eol %{ [fsm->self incrementLine]; } )*;

	# The final fsm is the lexer intersected with the newline machine which
	# will count lines for us. Since the newline machine accepts everything,
	# the strings accepted are goverened by the PDFParsingMachine_main machine,
	# onto which the newline machine overlays line counting.
	
	main := PDFParsingMachine_main; #  & newline;
	
%%
