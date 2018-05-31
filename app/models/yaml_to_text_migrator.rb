class YamlToTextMigrator

  def migrate_all_yaml_files!
    yaml_filenames.each do |filename|
      migrate_yaml_file!(filename)
    end
  end

  private

  def migrate_yaml_file!(filename)
    text_data_file = TextDataFile.new(filename.gsub(/\.yml/, ".txt"))
    text_data_file.export_company_rows! YamlLoader.new.get_cohort(cohort_from_filename(filename))
  end

  def cohort_from_filename(filename)
    if filename =~ /fellowship/
      "F#{filename[/v(\d)/, 1]}"
    else
      "#{filename[/(winter|summer)/, 1][0].capitalize}#{filename[/20(\d{2})/, 1]}"
    end
  end

  def yaml_filenames
    Dir.glob("data/companies/*.yml")
  end
end
