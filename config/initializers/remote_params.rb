module Remote

  if File.exist?(remote = Rails.root.join("config/remote.yml"))
    YAML.load_file(remote).each do |k, v|
      eval(%(def #{k} ; "#{v}" ; end))
    end
  end

  def method_missing(method, *args)
    nil
  end

  extend self

end
