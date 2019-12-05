# frozen_string_literal: true

# Base class for games
class Base
  private

  def initialize_kingdoms(min_vassals_count_for_became_ruler: 0)
    Kingdom.reset if Kingdom.all.any?
    initialize_instance_variables(min_vassals_count_for_became_ruler)
  end

  def initialize_instance_variables(min_vassals_count_for_became_ruler)
    GREAT_HOUSES.map do |kingdom|
      name = kingdom[:name].downcase
      Kingdom.class_variable_set('@@min_vassals_count_for_became_ruler', min_vassals_count_for_became_ruler)
      instance_variable_set("@#{name}", Kingdom.find_or_create(name.capitalize, kingdom[:emblem], kingdom[:king])) if
        instance_variable_get("@#{name}").nil?
    end
  end
end
