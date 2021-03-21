# frozen_string_literal: true

class Post < ApplicationRecord
  log_audit

  belongs_to :user, optional: true
  has_many :comments

  enum status: {
    draft: 1,
    published: 2
  }
end
