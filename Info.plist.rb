require 'plist.rb'
require 'project_keys.rb'
require "english_keys.rb"

=begin

  Information property list files contain essential configuration information for a bundled executable.
  Most bundles have at least one file of this type (usually named Info.plist) containing most of the 
  bundle’s configuration information. Other files may also be present depending on the bundle’s contents.
  
=end

entries = %w(
  CFBundleDevelopmentRegion
  CFBundleDisplayName
  CFBundleExecutable
  CFBundleIconFile
  CFBundleIdentifier
  CFBundleInfoDictionaryVersion
  CFBundlePackageType
  CFBundleSignature
  CFBundleVersion
  SIMBLTargetApplications
)

write_plist entries # defaults to $stdout