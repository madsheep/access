class Storage
  attr_accessor :dir

  def self.instance
    @@instance ||= new(AppConfig.permissions_repo.checkout_dir)
  end

  def self.data
    instance.data
  end

  def self.reset_data
    instance.reset_data
  end

  def initialize(dir)
    self.dir = dir
  end

  def reset_data
    @data = nil
  end

  def data
    if AppConfig.cache_data
      @data ||= build_tree
    else
      build_tree
    end
  end

  def build_tree
    # http://www.dzone.com/snippets/build-hash-tree-array-file
    # https://gist.github.com/awesome/3842062
    hash = files_list.inject({}) do |hash, path|
      tree = hash
      path_parts = split_path(path)
      path_parts.each_with_index do |part, index|
        tree[part] ||= {}
        if index == (path_parts.size - 1) # last element
          tree[part] = YAMLReader.new(file_path: path, validation: validation).call
        end
        tree = tree[part]
      end
      hash
    end
    Hashie::Mash.new(hash)
  end

  def files_list
    Dir["#{dir}/**/*.yml"]
  end

  def split_path(path)
    path.gsub(dir, '').gsub('.yml', '').split('/').reject(&:empty?)
  end

  def self.validation_errors
    data
    instance.validation.errors
  end

  def validation
    @validation ||= YAMLValidation.new
  end
end
