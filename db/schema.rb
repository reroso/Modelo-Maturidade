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

ActiveRecord::Schema.define(version: 2023_07_07_104609) do

  create_table "dimensaos", force: :cascade do |t|
    t.string "descricao"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.integer "maturidade_id", null: false
    t.index ["maturidade_id"], name: "index_dimensaos_on_maturidade_id"
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

  create_table "processos", force: :cascade do |t|
    t.string "descricao"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.integer "dimensao_id", null: false
    t.index ["dimensao_id"], name: "index_processos_on_dimensao_id"
  end

  create_table "resultados", force: :cascade do |t|
    t.string "descricao"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.integer "processo_id", null: false
    t.index ["processo_id"], name: "index_resultados_on_processo_id"
  end

  add_foreign_key "dimensaos", "maturidades"
  add_foreign_key "processos", "dimensaos"
  add_foreign_key "resultados", "processos"
end
