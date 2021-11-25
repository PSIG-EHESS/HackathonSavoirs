class SuggestionsService::Strategies
  MIN_DISPLAYED_SUGGESTION = 3
  ENGINES = %w[location chrono concept].freeze

  attr_reader :history, :engine

  def initialize(history, engine)
    raise StandardError.new("#{engine} is not a valid engine") unless ENGINES.include?(engine)

    @history = history
    @engine = engine
  end

  def to_html
    ApplicationController.render(
      partial: 'articles/suggestion',
      collection: send("#{engine}_suggestions").includes(:authors).limit(20),
    )
  end

  class << self
    def async_run(history_id, key)
      SuggestionsJob.perform_later(history_id, key)
    end
  end

private

  def concept_suggestions
    entry = Entry.find_by(slug: history.previous_article)

    concepts = history.previous_params['concepts'] || []
    concepts << (concepts.any? ?
      entry.highest_weighted_concept.id :
      entry.weighted_concepts.pluck(:id))

    Entry.search_by_concept(concepts.flatten, history.previous_article)
  end

  def chrono_suggestions
    from = history.previous_params['date_from']
    to = history.previous_params['date_to']
    entry = Entry.find_by(slug: history.previous_article)

    from = entry.min_date.to_s unless from.present?
    to = entry.max_date.to_s unless to.present?

    Entry.search_by_chrono(from, to, history.previous_article)
  end

  def location_suggestions
    entry = Entry.find_by(slug: history.previous_article)

    locations = history.previous_params['locations'] || []
    locations << (locations.any? ?
      entry.highest_weighted_localisation.id :
      entry.weighted_locations.pluck(:id))

    Entry.search_by_location(locations.flatten, history.previous_article)
  end
end
