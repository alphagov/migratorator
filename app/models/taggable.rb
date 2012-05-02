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
  end
end