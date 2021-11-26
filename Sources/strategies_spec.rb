require 'rails_helper'

RSpec.describe SuggestionsService::Strategies do

  describe 'constructor' do
    let(:history) { FactoryBot.build(:history) }

    context 'with invalid engine' do
      it 'raise an error' do
        expect { described_class.new(history, 'bad') }.to raise_error StandardError

      end
    end
  end

  describe '#location_suggestions' do
    let(:strategy) do
      described_class.new(history, 'location')
    end

    let(:entry) do
      FactoryBot.create(
        :entry,
        weighted_locations: FactoryBot.create_list(:location, 2),
      )
    end

    context 'without previous params' do
      let!(:history) { FactoryBot.create(:history, previous_article: entry.slug) }

      it 'call chrono search with history params' do
        allow(Entry).to receive(:search_by_location).and_return([])
        strategy.send(:location_suggestions)

        expect(Entry).to have_received(:search_by_location).with(
          entry.weighted_locations.pluck(:id), entry.slug
        )
      end
    end

    context 'with previous params' do
      let!(:history) do
        FactoryBot.create(
          :history,
          previous_article: entry.slug,
          previous_params: { locations: ['10', '12']},
        )
      end

      it 'call chrono search with history params' do
        allow(Entry).to receive(:search_by_location).and_return([])
        strategy.send(:location_suggestions)

        expect(Entry).to have_received(:search_by_location).with(
          ['10', '12', entry.highest_weighted_localisation.id],
          entry.slug,
        )
      end
    end
  end

  describe '#concept_suggestions' do
    let(:strategy) { described_class.new(history, 'concept') }
    let(:entry) do
      FactoryBot.create(
        :entry,
        weighted_concepts: FactoryBot.create_list(:concept, 2),
      )
    end

    context 'without previous params' do
      let!(:history) { FactoryBot.create(:history, previous_article: entry.slug) }

      it 'call concept search with entry params' do
        allow(Entry).to receive(:search_by_concept).and_return([])
        strategy.send(:concept_suggestions)

        expect(Entry).to have_received(:search_by_concept).with(
          entry.weighted_concepts.pluck(:id), entry.slug
        )
      end
    end

    context 'with previous params' do
      let!(:history) do
        FactoryBot.create(
          :history,
          previous_article: entry.slug,
          previous_params: { concepts: ['10', '12'] },
        )
      end

      it 'call concept search with history params' do
        allow(Entry).to receive(:search_by_concept).and_return([])
        strategy.send(:concept_suggestions)

        expect(Entry).to have_received(:search_by_concept).with(
          ['10', '12', entry.highest_weighted_concept.id],
          entry.slug,
        )
      end
    end
  end

  describe '#chrono_suggestions' do
    let(:strategy) { described_class.new(history, 'chrono') }
    let(:entry) do
      FactoryBot.create(
        :entry,
        weighted_datations: FactoryBot.create_list(:datation, 2),
      )
    end

    context 'without previous params' do
      let!(:history) { FactoryBot.create(:history, previous_article: entry.slug) }

      it 'call chrono search with history params' do
        allow(Entry).to receive(:search_by_chrono).and_return([])
        strategy.send(:chrono_suggestions)

        expect(Entry).to have_received(:search_by_chrono).with(
          *entry.weighted_datations.order(date: :asc).pluck(:date).map(&:to_s),
          entry.slug,
        )
      end
    end

    context 'with previous params' do
      let!(:history) do
        FactoryBot.create(
          :history,
          previous_article: entry.slug,
          previous_params: { date_from: '-200', date_to: '1000' },
        )
      end

      it 'call chrono search with history params' do
        allow(Entry).to receive(:search_by_chrono).and_return([])
        strategy.send(:chrono_suggestions)

        expect(Entry)
          .to have_received(:search_by_chrono).with('-200', '1000', entry.slug)
      end
    end
  end
end