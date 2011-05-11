module FileUtilities
  module ClassMethods
    def persist(geo_accession, force=false)
      record = self.first(:conditions => {:geo_accession => geo_accession})
      if !record
        record = self.new(:geo_accession => geo_accession)
      end
      record.persist if (record.new_record? || force)
      record
    end
  end

  def make_directory(target)
    Dir.mkdir(target) unless File.exists?(target)
  end

  def remove_item(directory)
    FileUtils.rm_r(directory) if File.exists?(directory)
  end

  def gunzip(filename)
    command = "gunzip --force #{filename}"
    success = system(command)
    success && $?.exitstatus == 0
  end

  def write_file(filename, text)
    text.force_encoding('UTF-8')
    File.open(filename, 'w') do |out|
      out.write(text)
    end
  end

  def file_hash(matchers, filename)
    hash = matchers.inject({}) {|h, matcher| h[matcher[:name]] = []; h}
    File.open(filename, "rb", :encoding => 'ISO-8859-1').each do |line|
      matchers.each do |matcher|
        if m = line.encode('UTF-8').match(matcher[:regex])
          hash[matcher[:name]] << m[1].chomp
          break
        end
      end
    end
    hash
  end

  def join_item(item)
    item.is_a?(Array) ? item.join(' ') : item
  end

end