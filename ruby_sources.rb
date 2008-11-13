RUBY_SOURCES = {
  'version.plist' => %w{
    project_keys.rb
    english_keys.rb
  },
  'English.lproj/InfoPlist.strings' => %w{
    project_keys.rb
    english_keys.rb
  },
  'Info.plist' => %w{
    project_keys.rb
    english_keys.rb
  }
}

#######################################################################################

# create manual require dependencies
RUBY_SOURCES.each { |k,v| file k => v }

# create ruby source dependency
RUBY_SOURCES.keys.each { |k| file k => "#{k}.rb" }
  
# create plist.rb and apple_strings.rb require dependencies
RUBY_SOURCES.keys.each do |k|
  if k =~ /\.strings/
    file k => "apple_strings.rb"
  elsif k =~ /\.plist/   
    file k => "plist.rb"
  end
end
