RSpec.shared_examples 'synchronously geocodable' do
  describe 'the interface the geocodable must implement' do
    subject { valid_new_geocodable }

    # needed for the ModelGeocoder
    it { is_expected.to respond_to(:full_street_address) }

    # used by #needs_to_be_geocoded?
    it { is_expected.to respond_to(:has_address_changes?) }

    # used by #geocode
    it { is_expected.to respond_to(:add_geocoding_failed_error) }
  end

  def modify_address(subject)
    subject.send("#{address_field_name}=", address_field_updated_value)
  end

  describe '#geocode' do
    context 'when the subject is not valid' do
      subject { invalid_geocodable }

      it 'does not call the geocoder' do
        expect(ModelGeocoder).not_to receive(:geocode)
        subject.geocode
      end

      it 'returns false' do
        expect(subject.geocode).to be(false)
      end
    end

    context 'when the subject is valid' do
      subject { valid_new_geocodable }

      context 'when the subject does not need to be geocoded' do
        before do
          subject.coordinates = [1.0, 1.0]
          subject.save!
        end

        it 'does not call the geocoder' do
          expect(ModelGeocoder).not_to receive(:geocode)
          subject.geocode
        end

        it 'returns true' do
          expect(subject.geocode).to be(true)
        end
      end

      context 'when the subject needs to be geocoded' do
        before do
          subject.coordinates = nil
        end

        context 'when geocoding succeeds' do
          before do
            allow(ModelGeocoder).to receive(:geocode).and_return([1.0, 1.0])
          end

          it 'returns true' do
            expect(subject.geocode).to be(true)
          end

          specify 'subject.errors.count is 0' do
            subject.geocode
            expect(subject.errors.count).to be(0)
          end

          context 'no persistence' do
            before do
              subject.save!
              expect(subject).not_to be_changed
              expect(subject.coordinates).to eq([nil, nil])
              subject.geocode
            end

            it 'sets the new coordinates on the in-memory instance' do
              expect(subject.coordinates).to eq([1.0, 1.0])
            end

            it 'does not persist the changed fields' do
              expect(subject).to be_changed
              expect(subject.reload.coordinates).to eq([nil, nil])
            end
          end
        end

        context 'when geocoding fails' do
          before do
            allow(ModelGeocoder).to receive(:geocode).and_return(nil)
          end

          it 'adds an error to subject.errors' do
            subject.geocode
            expect(subject.errors).to have_key(:address)
          end

          it 'returns false' do
            expect(subject.geocode).to be(false)
          end

          context 'no persistence' do
            before do
              subject.coordinates = [1.0, 1.0]
              subject.save!
              modify_address(subject)
              subject.geocode
            end

            it 'blanks out the in-memory instance coordinates' do
              expect(subject.coordinates).to eq([nil, nil])
            end

            it 'does not persist the changed fields' do
              expect(subject).to be_changed
              expect(subject.reload.coordinates).to eq([1.0, 1.0])
            end
          end
        end
      end
    end
  end

  describe '#needs_to_be_geocoded?' do
    subject { saved_geocodable }

    context 'when the model has not been geocoded' do
      before do
        subject.coordinates = nil
        expect(subject).not_to be_geocoded
      end

      it 'returns true' do
        expect(subject.needs_to_be_geocoded?).to be(true)
      end
    end

    context 'when the model has been geocoded' do
      before do
        subject.update_coordinates!([1.0, 1.0])
        expect(subject).to be_geocoded
      end

      context 'when the model address fields have not changed' do
        before do
          expect(subject).not_to have_address_changes
        end

        it 'returns false' do
          expect(subject.needs_to_be_geocoded?).to be(false)
        end
      end

      context 'when the model address fields have changed' do
        before do
          modify_address(subject)
          expect(subject).to have_address_changes
        end

        it 'returns true' do
          expect(subject.needs_to_be_geocoded?).to be(true)
        end
      end
    end
  end

  describe '#save_with_geocoding' do
    before { allow(saved_geocodable).to receive(:geocode).and_return(result_of_geocoding) }
    subject { saved_geocodable.save_with_geocoding }

    context 'when geocoding fails' do
      let(:result_of_geocoding) { false }

      it { is_expected.to be(false) }

      it 'does not call save' do
        expect(saved_geocodable).not_to receive(:save)
        subject
      end
    end

    context 'when geocoding succeeds' do
      let(:result_of_geocoding) { true }
      let(:result_of_saving) { true }
      before { allow(saved_geocodable).to receive(:save).and_return(result_of_saving) }

      it 'calls save' do
        expect(saved_geocodable).to receive(:save)
        subject
      end

      context 'when saving fails' do
        let(:result_of_saving) { false }
        it { is_expected.to be(false) }
      end

      context 'when saving succeeds' do
        it { is_expected.to be(true) }
      end
    end
  end

  describe '#update_with_geocoding' do
    subject { saved_geocodable.update_with_geocoding(updated_address_params) }

    it 'updates the geocodable with new attributes' do
      allow(saved_geocodable).to receive(:save_with_geocoding)
      subject
      expect(saved_geocodable.changed_attributes).to include(updated_address_params.keys.first)
    end

    it 'calls #save_with_geocoding' do
      expect(saved_geocodable).to receive(:save_with_geocoding)
      subject
    end

    it 'returns the return value of #save_with_geocoding' do
      allow(saved_geocodable).to receive(:save_with_geocoding).and_return(:return_marker)
      expect(subject).to eq(:return_marker)
    end
  end
end
