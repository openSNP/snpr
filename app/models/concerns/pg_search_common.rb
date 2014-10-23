module PgSearchCommon
  extend ActiveSupport::Concern
  include PgSearch

  module ClassMethods
    def pg_search_common_scope(config = {})
      pg_search_scope :search, default_config.merge(config)
    end

    def default_config
      {
        using: { 
          tsearch: { 
            prefix: true
          }
        }
      }
    end
  end
end
