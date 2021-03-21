# frozen_string_literal: true

class Comment < ApplicationRecord
  log_audit except: :number

  belongs_to :post, optional: true
  belongs_to :user, optional: true
end
