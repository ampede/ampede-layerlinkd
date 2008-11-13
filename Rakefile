# $Id$

require 'rubygems'
require_gem 'rake'

require 'ruby_sources'



# sh "rm -R RagelSources" rescue nil
# 
# task :default => [ :build ]
# 
# task :build => [ 'RagelSources', :build_dot_h, :build_dot_m, :build_dot_dot ]
# 
# directory 'RagelSources'
# 
# task :build_dot_h => %w( PDFLexer-Ragel.h PDFStreamLexer-Ragel.h )
# 							
# rule '.h' => '.rh' do |t|
# 	sh "~/bin/ragel '#{t.source}' -c -G2 -o 'RagelSources/#{t.name}'"
# end
# 
# task :build_dot_m => %w(	AIDocument-Ragel.m
# 							AIDocument-Ragel1.m
# 							AIDocument-Ragel2.m
# 							AIDocument-Ragel3.m
# 							AIDocument-Ragel4.m
# 							
# 							PDFLexer-Ragel.m
# 							PDFStreamLexer-Ragel.m	)
# 
# rule '.m' => '.rl' do |t|
# 	sh "~/bin/ragel '#{t.source}' -c -G2 -o 'RagelSources/#{t.name}'"
# end
# 
# task :build_dot_dot =>  %w(	AIDocument-Ragel.dot
# 								AIDocument-Ragel1.dot
# 								AIDocument-Ragel2.dot
# 								AIDocument-Ragel3.dot
# 								AIDocument-Ragel4.dot
# 							
# 								PDFLexer-Ragel.dot
# 								PDFStreamLexer-Ragel.dot	)
# 
# rule '.dot' => '.rl' do |t|
# 	sh "~/bin/ragel '#{t.source}' -V -o 'RagelSources/#{t.name}'"
# end