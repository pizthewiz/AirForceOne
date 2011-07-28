
require 'rake'
framework 'Foundation'

GIT = '/usr/bin/git'
BUNDLE_IDENTIFIER_KEY = 'CFBundleIdentifier'
BUNDLE_VERSION_NUMBER_KEY = 'CFBundleVersion'
BUNDLE_VERSION_STRING_KEY = 'CFBundleShortVersionString'
HEAD_REVISION_KEY = 'com.chordedconstructions.ProjectHEADRevision'

ARCHIVE_NAME = 'AriForceOne'
ARCHIVE_INCLUDE_FILES = %w(README.markdown TODO CHANGELOG Display\ On\ Apple\ TV.qtz)
ARCHIVE_EXCLUDE_FILES = %w()

# helpers
def build_number
  `#{GIT} log --pretty=format:'' | wc -l`.scan(/\d+/).first
end
def build_string
  string = `#{GIT} describe --dirty`
  # ignore leading 'v' if it is there
  string.sub(/^[v]+/, '').strip unless string.nil? or string.empty?
end
def head_rev
  rev = `#{GIT} rev-parse HEAD`
  rev.strip unless rev.nil? or rev.empty?
end
def select_file(filepath)
  url = NSURL.fileURLWithPath filepath
  NSWorkspace.sharedWorkspace.activateFileViewerSelectingURLs([url])
end

# tasks
desc 'update Info.plist build version number and string from git'
task :update_bundle_version, [:build_dir, :infoplist_path] do |t, args|
  # based on
  # http://github.com/guicocoa/xcode-git-cfbundleversion/
  # http://github.com/digdog/xcode-git-cfbundleversion/
  # http://github.com/jsallis/xcode-git-versioner
  # http://github.com/juretta/iphone-project-tools/tree/v1.0.3

  build_dir = ENV['BUILT_PRODUCTS_DIR'] || args.build_dir
  infoplist_path = ENV['INFOPLIST_PATH'] || args.infoplist_path
  unless !build_dir.nil? and !infoplist_path.nil?
    puts "ERROR - requires build directory and infoplist path via args or 'BUILT_PRODUCTS_DIR' and 'INFOPLIST_PATH'"
    exit 1
  end

  product_plist_path = File.join(build_dir, infoplist_path)
  unless File.file? product_plist_path
    puts "ERROR - cannot find build product's info plist at path '#{product_plist_path}'"
    exit 1
  end

  synthesized_build_number = build_number
  synthesized_build_string = build_string

  # update plist
  info = NSMutableDictionary.dictionaryWithContentsOfFile product_plist_path
  info[BUNDLE_VERSION_NUMBER_KEY] = synthesized_build_number
  info[BUNDLE_VERSION_STRING_KEY] = synthesized_build_string unless synthesized_build_string.empty?
  info[HEAD_REVISION_KEY] = head_rev

  # rewrite plist to disk
  error = Pointer.new(:object)
  data = NSPropertyListSerialization.dataWithPropertyList(info, format:NSPropertyListXMLFormat_v1_0, options:0, error:error)
  if error[0]
    puts "ERROR - failed to serialize plist"
    exit 1
  end
  status = data.writeToFile(product_plist_path, atomically:true)
  unless status
    puts "ERROR - failed to write updated plist to disk"
    exit 1    
  end

  # friendly output
  puts "updated '#{BUNDLE_VERSION_NUMBER_KEY}' in '#{File.basename(infoplist_path)}' to #{synthesized_build_number}"
  puts "updated '#{BUNDLE_VERSION_STRING_KEY}' in '#{File.basename(infoplist_path)}' to #{synthesized_build_string}" unless synthesized_build_string.empty?
end

desc 'create archive of application and resources for distribution'
task :create_archive, [:build_path, :build_product_name] do |t, args|
  build_dir = ENV['BUILT_PRODUCTS_DIR'] || args.build_path
  build_product_name = ENV['FULL_PRODUCT_NAME'] || args.build_product_name
  unless !build_dir.nil? && !build_product_name.nil?
    puts "ERROR - requires build directory and product name via args or 'BUILT_PRODUCTS_DIR' and 'FULL_PRODUCT_NAME'"
    exit 1
  end

  base_name = File.basename(build_product_name, File.extname(build_product_name))
  dir_name = "#{base_name}-#{build_string}"
  FileUtils.rm_r(Dir.glob("#{dir_name}/"), {:secure => true}) if File.exists? dir_name
  FileUtils.mkdir dir_name unless File.exists? dir_name

  %x{ ditto "#{build_dir}" "#{dir_name}"  }

  # TODO - wonder if that could be incorporated into the EXCLUDE_FILES list
  FileUtils.rm_r(Dir.glob(File.join(dir_name, '*.dSYM')), {:secure => true})
  exclude_file_list = ARCHIVE_EXCLUDE_FILES.collect { |f| File.join(dir_name, f) }
  FileUtils.rm_r(exclude_file_list, {:secure => true})
  # TODO - probably want to exclude dot files too

  FileUtils.cp ARCHIVE_INCLUDE_FILES, dir_name

  output_filename = "#{dir_name}.zip"
  %x{ zip -r -y #{output_filename} "#{dir_name}" }
  puts "created #{output_filename}"

  FileUtils.rm_r(dir_name, {:secure => true})

  output_filepath = File.join(File.dirname(__FILE__), output_filename)
  select_file(output_filepath)
end

desc 'delete archive'
task :clobber_archive do
  Dir.glob(ARCHIVE_NAME+"-[0-9].[0-9].[0-9]*.zip").each do |f|
    puts "removing '#{f}'"
    FileUtils.rm_r(f, {:secure => true})
  end
end
