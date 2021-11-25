class Entry < ApplicationRecord
  extend FriendlyId
  include PgSearch::Model

  friendly_id :title, use: :slugged

  # configure full text search
  pg_search_scope :search_by_text,
                  against: :full_text,
                  using: {
                    tsearch: {
                      dictionary: 'simple',
                      highlight: {
                        StartSel: '<b>',
                        StopSel: '</b>',
                        MaxWords: 40,
                        MinWords: 20,
                        ShortWord: 4,
                        MaxFragments: 3,
                        FragmentDelimiter: '<span class="separator">...</span>'
                      },
                    },
                  }

  # Not an active record attribute : only to store child entries as solr request results
  attr_accessor :paragraphs

  belongs_to :entry, optional: true
  alias_attribute :containing_article, :entry

  has_many :entry_locations
  has_many :locations, through: :entry_locations
  has_many :entry_datations
  has_many :datations, through: :entry_datations
  has_many :entry_concepts
  has_many :concepts, through: :entry_concepts

  has_many :datation_weights
  has_many :weighted_datations, through: :datation_weights, source: :datation
  has_many :location_weights
  has_many :weighted_locations, through: :location_weights, source: :location
  has_many :concept_weights
  has_many :weighted_concepts, through: :concept_weights, source: :concept

  has_many :entries

  has_many :entry_people
  has_many :authors,
           -> { where(entry_people: { role: 'author' } ) },
           through: :entry_people,
           source: :person
  has_many :translators,
           -> { where(entry_people: { role: 'translators' } ) },
           through: :entry_people,
           source: :person
  has_many :quoted,
           -> { where(entry_people: { role: 'quoted' } ) },
           through: :entry_people,
           source: :person

  scope :articles, -> { where(entry: nil) }
  scope :with_slugs_order, -> (slugs) {
    order = sanitize_sql_array(['array_position(ARRAY[?]::text[], entries.slug::text)', slugs])
    order(order)
  }

  def self.sortable_attributes
    %w[
      metadatas->>'collection_name'
      metadatas->>'publication_date'
      title
      people.lastname
    ]
  end

  def calculate_concept_weights
    return if paragraph?

    concepts = EntryConcept
      .where(entry_id: entries.pluck(:id))
      .group(:concept_id)
      .count
      .map do |concept_id, weight|
        { concept_id: concept_id, weight: weight, entry_id: id }
      end

    ConceptWeight.insert_all(concepts) if concepts.any?
  end

  def self.search_by_concept(concept_ids, previous_article = nil)
    Entry.from(
      Entry
        .joins(:concept_weights)
        .where(concept_weights: { concept_id: concept_ids }, entry_id: nil)
        .where.not(slug: previous_article)
        .group(:id, :weight)
        .select(
          'DISTINCT ON (entries.id) entries.id',
          'formatted_content->\'title\' AS formatted_title',
          :slug,
          '(count(concept_weights.entry_id)) AS count',
          '(concept_weights.weight) AS weight'),
      :entries,
    ).order('count DESC, weight DESC')
  end

  def calculate_location_weights
    return if paragraph?

    locations = EntryLocation
      .where(entry_id: entries.pluck(:id))
      .group(:location_id)
      .count
      .map do |location_id, weight|
        { location_id: location_id, weight: weight, entry_id: id }
      end

    LocationWeight.insert_all(locations) if locations.any?
  end

  def self.search_by_location(locations, previous_article = nil)
    Entry.from(
      Entry
        .joins(:location_weights)
        .where(location_weights: { location_id: locations }, entry_id: nil)
        .where.not(slug: previous_article)
        .group(:id, :weight)
        .select(
          'DISTINCT ON (entries.id) entries.id',
          'formatted_content->\'title\' AS formatted_title',
          :slug,
          '(count(location_weights.entry_id)) AS count',
          '(location_weights.weight) AS weight'
        ),
      :entries,
    ).order('count DESC, weight DESC')
  end

  def calculate_datation_weights
    return if paragraph?

    datations = EntryDatation
      .where(entry_id: entries.pluck(:id))
      .group(:datation_id)
      .count
      .map do |datation_id, weight|
        { datation_id: datation_id, weight: weight, entry_id: id }
      end

    DatationWeight.insert_all(datations) if datations.any?
  end

  def self.search_by_chrono(from, to, previous_article = nil)
    Entry.from(
      Entry
        .joins(:weighted_datations)
        .where(datations: { date: from..to }, entry_id: nil)
        .where.not(slug: previous_article)
        .group(:id, :weight)
        .select(
          'DISTINCT ON (entries.id) entries.id',
          'formatted_content->\'title\' AS formatted_title',
          :slug,
          '(count(datation_weights.entry_id)) AS count',
          '(datation_weights.weight) AS weight',
        ),
      :entries,
    ).order('count DESC, weight DESC')
  end

  def article?
    entry_id.nil?
  end

  def paragraph?
    entry_id.present?
  end

  def highest_weighted_localisation
    weighted_locations.order(weight: :desc).first
  end

  def highest_weighted_concept
    weighted_concepts.order(weight: :desc).first
  end

  def highest_weighted_datation
    weighted_datations.order(weight: :desc).first
  end

  def min_date
    weighted_datations.minimum(:date)
  end

  def max_date
    weighted_datations.maximum(:date)
  end

  def as_json(*)
    super(include: {
      authors: { only: [:name] },
      paragraphs: { only: %i[id order full_text html_id] },
    })
  end

  def file_name
    author = authors.map(&:name).join('-')
    author.present? ? "#{author}_#{title}" : title
  end

  def epub_path
    Rails.root.join('storage', 'epub', "#{file_name}.epub")
  end

  def to_epub(file_name)
    EpubService::Generator.call(self) unless File.exist?(epub_path)
    epub_path
  end
end
