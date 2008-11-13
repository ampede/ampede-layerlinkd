require 'apple_strings.rb'
require 'project_keys.rb'
require 'english_keys.rb'

=begin

  Localized versions of Info.plist keys
  
  This generates data in UTF-8 format.
  .strings files should be in UTF-16 format, so you'll need another task to convert the results.
  
=end 

entries = %w(
  CFBundleDisplayName
  CFBundleGetInfoString
  CFBundleName
  CFBundleShortVersionString
  NSHumanReadableCopyright
)

write_apple_strings( entries ) # by default, write_apple_strings writes to $stdout