# frozen_string_literal: true

class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true

  def self.copy_csv(sql)
    Enumerator.new do |y|
      conn = ActiveRecord::Base.connection.raw_connection
      conn.copy_data "COPY (#{sql}) TO STDOUT WITH CSV HEADER DELIMITER ';'" do
        while row = conn.get_copy_data
          y << row
        end
      end
    end
  end
end
