module Languages
  UK_MINORITY_LANGUAGES = %w(sco gd bfi isg).map { |l| LanguageList::LanguageInfo.find l }
  EXCLUDED_LANGUAGES = %w(en).map { |l| LanguageList::LanguageInfo.find l }
  AVAILABLE_LANGUAGES = (
    (LanguageList::COMMON_LANGUAGES + UK_MINORITY_LANGUAGES) - EXCLUDED_LANGUAGES
  ).sort_by(&:common_name).freeze
  AVAILABLE_LANGUAGES_ISO_639_3_CODES = Set.new(AVAILABLE_LANGUAGES.map(&:iso_639_3)).freeze
end
