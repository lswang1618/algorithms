class Reader < ActiveRecord::Base
  include Utilities
  has_many :visits, dependent: :destroy
  has_many :responses, dependent: :destroy
  has_many :questions, through: :responses
  has_many :articles, through: :visits
  has_many :publishers, through: :articles

  after_create :update_alpha_id

  DEMOGRAPHICS = ["age","gender","country","region","city"]

  # generate some helpful scopes for the demographics
  DEMOGRAPHICS.each do |demographic|
    scope demographic, -> (value) {where(demographic => value)}
  end
  
  # Internal: Get the demographics of the reader
  # 
  # Examples
  # 
  # Reader.first.get_demographics
  # # => {"age": 30, "gender": male}
  #
  # Returns a hash of the demographics
  def get_demographics
    my_demographics = {}
    Reader::DEMOGRAPHICS.each do |demographic|
      my_demographics[demographic] = self[demographic]
    end
    return my_demographics
  end

  def update_demographics(demographics)
    demographics.each do |key, value|
      if Reader::DEMOGRAPHICS.include? key.downcase
        self.attributes = {key.to_sym => value}
      end
    end
    if self.changed? then self.save end
  end

  # get the statistics on each type of demographic and their options
  def self.get_demographic_stats
    stats = {}
    Reader::DEMOGRAPHICS.each do |demographic|
      stats[demographic] = Reader.group(demographic).count
    end
    return stats
  end

  # like above, but without the counts
  # designed for select tags
  def self.get_demographic_options
    stats = {}
    Reader::DEMOGRAPHICS.each do |demographic|
      stats[demographic] = Reader.group(demographic).pluck(demographic)
    end
    return stats.transform_values{|demo| demo.map {|demo_type| demo_type.present? ? demo_type.titleize : "Unknown"}}
  end
  # Internal: Handle a popup visit from a reader by creating or finding then updating reader
  # 
  # 
  # alpha_id - The alpha_id of the reader (presumably found--or not--from a cookie)
  # ip - The IP address of the request, presumably the reader's
  # page - The URL of the page making the request, presumably the reader's
  #
  # Examples
  # 
  # Reader.popup_visit("A1B2C3D4E5", "000.000.000.000", "localhost:3000/test")
  #
  # Returns the created or found reader
  def self.popup_visit(alpha_id: "", ip: "", page: "", geocode: nil)
    reader = Reader.create_with(initial_ip: ip, initial_page: page)
    reader = reader.find_or_create_by(alpha_id: alpha_id)
    reader.attributes = {last_ip: ip, last_page: page}
    if !geocode.nil?
      geo_data = geocode.data
      reader.attributes = {city: geo_data[:city_name], region: geo_data[:region_name], country: geo_data[:country_name]}
    end
    # handle readers already in db but without ip seen before
    if reader.initial_ip.nil?
      reader.attributes = {initial_ip: ip, initial_page: page}
    end
    reader.save
    return reader    
  end

  private
    def update_alpha_id
      self.update(alpha_id: generate_alpha_id(self.class))
    end
end
