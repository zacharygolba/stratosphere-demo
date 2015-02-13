# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20150213074308) do

  create_table "documents", force: :cascade do |t|
    t.string   "name",                      limit: 255
    t.datetime "created_at",                            null: false
    t.datetime "updated_at",                            null: false
    t.string   "attachment_file",           limit: 255
    t.string   "attachment_content_type",   limit: 255
    t.integer  "attachment_content_length", limit: 8
  end

  create_table "music_videos", force: :cascade do |t|
    t.datetime "created_at",                       null: false
    t.datetime "updated_at",                       null: false
    t.string   "video_file",           limit: 255
    t.string   "video_content_type",   limit: 255
    t.integer  "video_content_length", limit: 8
    t.string   "title",                limit: 255
  end

  create_table "posts", force: :cascade do |t|
    t.string   "title",                limit: 255,   default: "New Post", null: false
    t.text     "body",                 limit: 65535
    t.datetime "created_at",                                              null: false
    t.datetime "updated_at",                                              null: false
    t.string   "image_file",           limit: 255
    t.string   "image_content_type",   limit: 255
    t.integer  "image_content_length", limit: 8
  end

end
