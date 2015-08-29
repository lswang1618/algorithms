Ransack.configure do |config|
  # don't exclude null and empty strings from search
  config.add_predicate 'in_null', # Name your predicate
    # What non-compound ARel predicate will it use? (eq, matches, etc)
    arel_predicate: 'in',
    # Format incoming values as you see fit. (Default: Don't do formatting)
    # formatter: proc { |v| "#{v}-diddly" },
    # Validate a value. An "invalid" value won't be used in a search.
    # Default is v.present?
    validator: proc { |v| true },
    # Should compounds be created? Will use the compound (any/all) version
    # of the arel_predicate to create a corresponding any/all version of
    # your predicate. (Default: true)
    compounds: true
    # Force a specific column type for type-casting of supplied values.
    # (Default: use type from DB column)
    # type: :string
end