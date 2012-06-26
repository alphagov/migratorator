module Taggable
  extend ActiveSupport::Concern

  included do
    has_and_belongs_to_many :tagged_with, :class_name => "Tag"
    field :tags_cache,      type: Array, default: []
    field :tags_list_cache, type: String, default: ""

    validate :tags_have_unique_sections

    scope :tagged_with_all, proc {|array| all_in({ :tagged_with_ids => self.valid_tags_for(array) }) }
    scope :tagged_with_any, proc {|array| any_in({ :tagged_with_ids => self.valid_tags_for(array) }) }
    scope :by_filter_path,   proc {|string| tagged_with_all(string.split('/')) }

    after_initialize :extract_tagged_with
    before_validation :update_tagged_with
    before_save :update_tags_cache!

    attr_writer :primary_tags
    cattr_accessor :additional_tag_groups

    def additional_tags
      (@additional_tags || []).map {|s| OpenStruct.new(Tag.parse_tag_from_string(s).merge({:whole_tag => s})) }
    end

    def primary_tags
      (@primary_tags || []).map {|s| OpenStruct.new(Tag.parse_tag_from_string(s).merge({:whole_tag => s})) }
    end

    def primary_tags=(array)
      @primary_tags = array
    end

    def primary_tags_list
      primary_tags.join(', ')
    end

    def primary_tags_list=(string)
      self.primary_tags = string.split(',').map(&:strip)
    end

    def tags
      self.primary_tags.reject {|t| !t.group.blank? and additional_tags.map(&:group).include?(t.group) } + self.additional_tags
    end

    def tags_list
      self.tags.map(&:whole_tag).join(', ')
    end

    alias_method :tags=, :primary_tags=
    alias_method :tags_list=, :primary_tags_list=

    def tags_cache
      read_attribute(:tags_cache).map {|s| OpenStruct.new(Tag.parse_tag_from_string(s).merge({:whole_tag => s})) }
    end

    def tag_for(group)
      tag = tags_cache.find {|t| t.group == group }
      tag.name if tag
    end

    def self.additional_tag(group, true_value, false_value)
      define_method "#{group}".to_sym do
        tag_for(group) == true_value ? true : false
      end
      define_method "#{group}=".to_sym do |state|
        !state.blank? ? update_tag_for(group,true_value) : update_tag_for(group,false_value)
      end

      alias_method "#{group}?".to_sym, "#{group}".to_sym

      @@additional_tag_groups = (@@additional_tag_groups || []) + [group]
    end

    def update_tag_for(group, new_tag)
      @additional_tags = (@additional_tags || []).reject {|t| t =~ /^#{group}:/ } + ["#{group}:#{new_tag}"]
      update_tagged_with and update_tags_cache!
    end

    def self.valid_tags_for(array)
      array.map {|tag|
        tag = tag.instance_of?(Tag) ? tag : Tag.find_by_string(tag)
        tag.present? ? tag.id : nil
      }.compact
    end

    def update_tags_cache!
      self.tags_cache = self.tagged_with.map(&:whole_tag)
      self.tags_list_cache = self.tags_list
    end


    private
      def extract_tagged_with
        return if new_record?
        @primary_tags = self.tags_cache.reject {|t| self.additional_tag_groups.include?(t.group) }.map(&:whole_tag)
        @additional_tags = self.tags_cache.select {|t| self.additional_tag_groups.include?(t.group) }.map(&:whole_tag)
      end

      def update_tagged_with
        self.tagged_with = self.tags.map {|item|
          if item.instance_of?(Tag)
            item
          elsif item.instance_of?(OpenStruct)
            Tag.find_or_create_by_string(item.whole_tag)
          elsif item.instance_of?(String)
            Tag.find_or_create_by_string(item)
          end
        }
      end

      def tags_have_unique_sections
        duplicate_groups = []
        self.tags.reject {|t| t.group == nil }.each do |tag|
          if self.tags.select {|t| t.group == tag.group }.size > 1
            duplicate_groups << tag.group
          end
        end

        duplicate_groups.uniq.each do |group|
          self.errors.add(:tagged_with, "contains more than one tag from #{group}.")
        end
      end
  end
end