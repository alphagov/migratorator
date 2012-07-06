class Tag
  include Mongoid::Document

  STATUS_DONE_TAG = "status:closed"
  SECTIONS_TO_EXCLUDE = ["content-item","reviewed"]

  field :group, type: String
  field :name,  type: String

  validates :name, :presence => true
  validates :name, :uniqueness => {:scope => :group}

  default_scope order_by([:group, :asc], [:name, :asc])

  scope :without_excluded_sections, where(:group.nin => SECTIONS_TO_EXCLUDE)
  scope :by_group, proc {|string| where(:group => string) }

  before_validation :sanitize_tag

  class TagNotFound < Exception; end

  has_and_belongs_to_many :mappings

  def self.grouped
    self.all.group_by(&:group)
  end

  def self.find_or_create_by_string(string)
    find_by_string(string) || create_from_string(string)
  end

  def self.create_from_string(string)
    Tag.create parse_tag_from_string(string)
  end

  def self.find_by_string(string)
    Tag.where(parse_tag_from_string(string)).first
  end

  def self.find_by_group_and_name(group, name)
    Tag.where(:group => group, :name => name).first
  end

  def self.find_by_group(group)
    Tag.where(:group => group).all
  end

  def mapping_count
    self.mapping_ids.size
  end

  def whole_tag
    group.blank? ? name : group + ':' + name
  end

  def whole_tag=(string)
    Tag.parse_tag_from_string(string).each { |key, val| send("#{key}=", val) }
  end

  alias_method :to_param, :whole_tag
  alias_method :to_s, :whole_tag

  def to_hash
    { :group => group, :name => name }
  end

  def merge_into!(new_tag)
    new_tag = Tag.find_by_string(new_tag) unless new_tag.instance_of?(Tag)
    raise(TagNotFound.new) if new_tag.nil?

    self.mappings.all.each do |mapping|
      mapping.tags = mapping.tags.reject! {|tag| tag.whole_tag == self.whole_tag }.map(&:whole_tag) + [new_tag.whole_tag]
      mapping.save!
    end

    self.destroy
  end

  private
    def sanitize_tag
      self.group = self.group.parameterize if self.group
      self.name = self.name.parameterize if self.name
    end

    def self.parse_tag_from_string(s)
      group, name = s.sub(/^([^:]+)$/,':\\1').split(':',-2)
      return { :group => (group.blank? ? nil : group), :name => name }
    end
end