require 'plist.rb'
require 'project_keys.rb'
require 'english_keys.rb'

=begin

  The version.plist file is for the benefit of Installer.app
  and is also used by PackageMaker (and Iceberg).
  
  BuildVersion, CFBundleShortVersionString, and SourceVersion are required.
  
  All values are Strings (no Integers).
  
=end

entries = %w{
  BuildVersion
  CFBundleShortVersionString
  CFBundleVersion
  ProjectName
  ReleaseStatus
  SourceVersion
}
 
write_plist entries # by default, write_plist writes to $stdout