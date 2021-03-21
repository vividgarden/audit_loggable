# frozen_string_literal: true

class PostsController < ApplicationController
  before_action :populate_user

  def create
    Post.create!(
      type:   "AwesomePost",
      status: :draft,
      title:  "title value",
      body:   "body value",
      number: 100
    )
    head :created
  end

  private

  attr_accessor :current_user, :current_custom_user

  def populate_user; end
end
