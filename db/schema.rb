# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[7.0].define(version: 2025_07_05_180617) do
  # These are extensions that must be enabled in order to support this database
  enable_extension 'plpgsql'

  create_table 'event_assignments', force: :cascade do |t|
    t.bigint 'event_id', null: false
    t.bigint 'member_id', null: false
    t.datetime 'created_at', null: false
    t.datetime 'updated_at', null: false
    t.index ['event_id'], name: 'index_event_assignments_on_event_id'
    t.index ['member_id'], name: 'index_event_assignments_on_member_id'
  end

  create_table 'event_teams', force: :cascade do |t|
    t.bigint 'event_id', null: false
    t.bigint 'team_id', null: false
    t.datetime 'created_at', null: false
    t.datetime 'updated_at', null: false
    t.index ['event_id', 'team_id'], name: 'index_event_teams_on_event_id_and_team_id', unique: true
    t.index ['event_id'], name: 'index_event_teams_on_event_id'
    t.index ['team_id'], name: 'index_event_teams_on_team_id'
  end

  create_table 'events', force: :cascade do |t|
    t.string 'title'
    t.text 'description'
    t.integer 'duration_seconds'
    t.datetime 'created_at', null: false
    t.datetime 'updated_at', null: false
    t.datetime 'occurred_at'
  end

  create_table 'jwt_denylist', force: :cascade do |t|
    t.string 'jti', null: false
    t.datetime 'exp', null: false
    t.datetime 'created_at', null: false
    t.datetime 'updated_at', null: false
    t.index ['jti'], name: 'index_jwt_denylist_on_jti'
  end

  create_table 'members', force: :cascade do |t|
    t.string 'name'
    t.string 'email'
    t.datetime 'created_at', null: false
    t.datetime 'updated_at', null: false
    t.boolean 'active', default: true
    t.string 'pix_key'
    t.datetime 'disabled_at'
    t.string 'external_id'
    t.index ['pix_key'], name: 'index_members_on_pix_key', unique: true
  end

  create_table 'memberships', force: :cascade do |t|
    t.bigint 'team_id', null: false
    t.bigint 'member_id', null: false
    t.datetime 'created_at', null: false
    t.datetime 'updated_at', null: false
    t.integer 'role', default: 0
    t.index ['member_id', 'team_id'], name: 'index_memberships_on_member_id_and_team_id', unique: true
    t.index ['member_id'], name: 'index_memberships_on_member_id'
    t.index ['team_id'], name: 'index_memberships_on_team_id'
  end

  create_table 'teams', force: :cascade do |t|
    t.string 'name'
    t.text 'description'
    t.datetime 'created_at', null: false
    t.datetime 'updated_at', null: false
  end

  create_table 'users', force: :cascade do |t|
    t.string 'name'
    t.string 'email', default: '', null: false
    t.string 'encrypted_password', default: '', null: false
    t.string 'reset_password_token'
    t.datetime 'reset_password_sent_at'
    t.datetime 'remember_created_at'
    t.datetime 'created_at', null: false
    t.datetime 'updated_at', null: false
    t.boolean 'suspended', default: false
    t.boolean 'super_admin', default: false
    t.index ['email'], name: 'index_users_on_email', unique: true
    t.index ['reset_password_token'], name: 'index_users_on_reset_password_token', unique: true
  end

  add_foreign_key 'event_assignments', 'events'
  add_foreign_key 'event_assignments', 'members'
  add_foreign_key 'event_teams', 'events'
  add_foreign_key 'event_teams', 'teams'
  add_foreign_key 'memberships', 'members'
  add_foreign_key 'memberships', 'teams'
end
