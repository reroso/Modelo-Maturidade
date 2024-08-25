# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `rails
# db:schema:load`. When creating a new database, `rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2024_08_25_151801) do

  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.integer "record_id", null: false
    t.integer "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.integer "byte_size", null: false
    t.string "checksum", null: false
    t.datetime "created_at", null: false
    t.integer "classificacao"
    t.text "descricao"
    t.integer "modelo"
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "admins", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["email"], name: "index_admins_on_email", unique: true
    t.index ["reset_password_token"], name: "index_admins_on_reset_password_token", unique: true
  end

  create_table "dimensaos", force: :cascade do |t|
    t.string "descricao"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.integer "maturidade_id", null: false
    t.string "nivel_selecionado"
    t.index ["maturidade_id"], name: "index_dimensaos_on_maturidade_id"
  end

  create_table "dominios", force: :cascade do |t|
    t.string "nome"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "levels", force: :cascade do |t|
    t.string "index"
    t.text "descricao"
    t.integer "modelo_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "maturidades", force: :cascade do |t|
    t.string "nome"
    t.string "descricao"
    t.string "tipoNivel"
    t.string "menorNivel"
    t.string "maiorNivel"
    t.string "resultadoEscolha"
    t.string "nivelEscolha"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "modelo_aplicados", force: :cascade do |t|
    t.string "metodo"
    t.string "instituicao"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.integer "dominio_id", null: false
    t.integer "maturidade_id", null: false
    t.integer "user_id", null: false
    t.index ["dominio_id"], name: "index_modelo_aplicados_on_dominio_id"
    t.index ["maturidade_id"], name: "index_modelo_aplicados_on_maturidade_id"
    t.index ["user_id"], name: "index_modelo_aplicados_on_user_id"
  end

  create_table "processos", force: :cascade do |t|
    t.string "descricao"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.integer "dimensao_id", null: false
    t.string "nivel_selecionado"
    t.index ["dimensao_id"], name: "index_processos_on_dimensao_id"
  end

  create_table "resultados", force: :cascade do |t|
    t.string "descricao"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.integer "processo_id", null: false
    t.string "nivel_selecionado"
    t.index ["processo_id"], name: "index_resultados_on_processo_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "dimensaos", "maturidades"
  add_foreign_key "modelo_aplicados", "dominios"
  add_foreign_key "modelo_aplicados", "maturidades"
  add_foreign_key "modelo_aplicados", "users"
  add_foreign_key "processos", "dimensaos"
  add_foreign_key "resultados", "processos"
end
