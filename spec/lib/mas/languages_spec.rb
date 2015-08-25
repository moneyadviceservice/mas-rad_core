RSpec.describe Languages do
  describe '::AVAILABLE_LANGUAGES' do
    it 'returns a list of languages' do
      expect(Languages::AVAILABLE_LANGUAGES).to have(74).languages
    end

    it 'does not include English' do
      expect(Languages::AVAILABLE_LANGUAGES).to_not include LanguageList::LanguageInfo.find('en')
    end

    it 'does include minority languages' do
      expect(Languages::AVAILABLE_LANGUAGES).to include LanguageList::LanguageInfo.find('sco')
    end

    it 'sorts them by common English name' do
      sorted_languages = Languages::AVAILABLE_LANGUAGES.sort_by(&:common_name)
      expect(Languages::AVAILABLE_LANGUAGES).to eq(sorted_languages)
    end
  end
end
