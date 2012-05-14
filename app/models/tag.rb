class Tag
  include Mongoid::Document

  STATUS_DONE_TAG = "status:closed"

  field :group, type: String
  field :name,  type: String

  validates :name, :presence => true
  validates :name, :uniqueness => {:scope => :group}

  default_scope order_by([:group, :asc], [:name, :asc])

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

  def whole_tag
    group.blank? ? name : group + ':' + name
  end

  def whole_tag=(string)
    Tag.parse_tag_from_string(string).each { |key, val| send("#{key}=", val) }
  end

  def to_hash
    { :group => group, :name => name }
  end

  def to_param
    whole_tag
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