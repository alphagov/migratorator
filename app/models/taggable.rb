module Taggable
  extend ActiveSupport::Concern

  included do
    has_and_belongs_to_many :tagged_with, :class_name => "Tag"

    alias_method :tags, :tagged_with

    def tags=(array_of_strings_or_tags)
      self.tagged_with = array_of_strings_or_tags.map {|item| item.instance_of?(String) ? Tag.find_or_create_by_string(item) : item }
    end

    def tags_list
      tagged_with.map(&:whole_tag).join(', ')
    end

    def tags_list=(string)
      self.tags = string.split(",").map {|a| a.strip }
    end

    def self.valid_tags_for(array)
      array.map {|tag|
        tag = Tag.find_by_string(tag)
        tag.present? ? tag.id : nil
      }.compact
    end

    def self.tagged_with_all(array)
      self.all_in :tagged_with_ids => self.valid_tags_for(array)
    end

    def self.tagged_with_any(array)
      self.any_in :tagged_with_ids => self.valid_tags_for(array)
    end
  end
end