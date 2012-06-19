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

    before_save :update_tags_cache!

    def tags
      self.tags_cache.map {|string|
        OpenStruct.new( Tag.parse_tag_from_string(string).merge({:whole_tag => string}) )
      }
    end

    def tags=(array_of_strings_or_tags)
      self.tagged_with = array_of_strings_or_tags.map {|item|
        if item.instance_of?(Tag)
          item
        elsif item.instance_of?(OpenStruct)
          Tag.find_or_create_by_string(item.whole_tag)
        elsif item.instance_of?(String)
          Tag.find_or_create_by_string(item)
        end
      }
      # puts self.tagged_with.inspect
      self.update_tags_cache!
    end

    def tags_list
      self.tags_cache.join(', ')
    end

    def tags_list=(string)
      self.tags = string.split(",").map {|a| a.strip }
    end

    def tag_for(group)
      tag = self.tags.find {|t| t.group == group }
      tag.name if tag
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