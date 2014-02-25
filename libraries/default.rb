module Mod_Network_interfaces
  def insert_line_if_no_match(filepath, regex, newline)
    @original_pathname = filepath
    @file_edited = false
    raise ArgumentError, "File doesn't exist" unless File.exist? @original_pathname
    raise ArgumentError, "File is blank" unless (@contents = File.new(@original_pathname).readlines).length > 0

    exp = Regexp.new(regex)
    new_contents = []
    @contents.each do |line|
      if line.match(exp)
        @file_edited = true
      end
    end
    if ! @file_edited
      @contents << newline
      backup_pathname = @original_pathname + ".old"
      FileUtils.cp(@original_pathname, backup_pathname, :preserve => true)
      File.open(@original_pathname, "w") do |newfile|
        @contents.each do |line|
          newfile.puts(line)
        end
        newfile.flush
      end
    end
  end
end

