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

ActiveRecord::Schema.define(version: 20170709145123) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "combination_maps", id: :serial, force: :cascade do |t|
    t.string "icdo3_histology_code", null: false
    t.string "icdo3_site_code", null: false
    t.string "refsetid"
    t.string "snomed_histology_code"
    t.string "snomed_site_code"
    t.string "snomed_precoordinated_code"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "curr_associationrefset_f", primary_key: ["id", "effectivetime"], force: :cascade do |t|
    t.uuid "id", null: false
    t.string "effectivetime", limit: 8, null: false
    t.string "active", limit: 1, null: false
    t.string "moduleid", limit: 18, null: false
    t.string "refsetid", limit: 18, null: false
    t.string "referencedcomponentid", limit: 18, null: false
    t.string "targetcomponentid", limit: 18, null: false
  end

  create_table "curr_attributevaluerefset_f", primary_key: ["id", "effectivetime"], force: :cascade do |t|
    t.uuid "id", null: false
    t.string "effectivetime", limit: 8, null: false
    t.string "active", limit: 1, null: false
    t.string "moduleid", limit: 18, null: false
    t.string "refsetid", limit: 18, null: false
    t.string "referencedcomponentid", limit: 18, null: false
    t.string "valueid", limit: 18, null: false
  end

  create_table "curr_complexmaprefset_f", primary_key: ["id", "effectivetime"], force: :cascade do |t|
    t.uuid "id", null: false
    t.string "effectivetime", limit: 8, null: false
    t.string "active", limit: 1, null: false
    t.string "moduleid", limit: 18, null: false
    t.string "refsetid", limit: 18, null: false
    t.string "referencedcomponentid", limit: 18, null: false
    t.integer "mapgroup", limit: 2, null: false
    t.integer "mappriority", limit: 2, null: false
    t.text "maprule"
    t.text "mapadvice"
    t.text "maptarget"
    t.string "correlationid", limit: 18, null: false
  end

  create_table "curr_concept_f", primary_key: ["id", "effectivetime"], force: :cascade do |t|
    t.string "id", limit: 18, null: false
    t.string "effectivetime", limit: 8, null: false
    t.string "active", limit: 1, null: false
    t.string "moduleid", limit: 18, null: false
    t.string "definitionstatusid", limit: 18, null: false
  end

  create_table "curr_description_f", primary_key: ["id", "effectivetime"], force: :cascade do |t|
    t.string "id", limit: 18, null: false
    t.string "effectivetime", limit: 8, null: false
    t.string "active", limit: 1, null: false
    t.string "moduleid", limit: 18, null: false
    t.string "conceptid", limit: 18, null: false
    t.string "languagecode", limit: 2, null: false
    t.string "typeid", limit: 18, null: false
    t.text "term", null: false
    t.string "casesignificanceid", limit: 18, null: false
  end

  create_table "curr_extendedmaprefset_f", primary_key: ["id", "effectivetime"], force: :cascade do |t|
    t.uuid "id", null: false
    t.string "effectivetime", limit: 8, null: false
    t.string "active", limit: 1, null: false
    t.string "moduleid", limit: 18, null: false
    t.string "refsetid", limit: 18, null: false
    t.string "referencedcomponentid", limit: 18, null: false
    t.integer "mapgroup", limit: 2, null: false
    t.integer "mappriority", limit: 2, null: false
    t.text "maprule"
    t.text "mapadvice"
    t.text "maptarget"
    t.string "correlationid", limit: 18
    t.string "mapcategoryid", limit: 18
  end

  create_table "curr_langrefset_f", primary_key: ["id", "effectivetime"], force: :cascade do |t|
    t.uuid "id", null: false
    t.string "effectivetime", limit: 8, null: false
    t.string "active", limit: 1, null: false
    t.string "moduleid", limit: 18, null: false
    t.string "refsetid", limit: 18, null: false
    t.string "referencedcomponentid", limit: 18, null: false
    t.string "acceptabilityid", limit: 18, null: false
  end

  create_table "curr_relationship_f", primary_key: ["id", "effectivetime"], force: :cascade do |t|
    t.string "id", limit: 18, null: false
    t.string "effectivetime", limit: 8, null: false
    t.string "active", limit: 1, null: false
    t.string "moduleid", limit: 18, null: false
    t.string "sourceid", limit: 18, null: false
    t.string "destinationid", limit: 18, null: false
    t.string "relationshipgroup", limit: 18, null: false
    t.string "typeid", limit: 18, null: false
    t.string "characteristictypeid", limit: 18, null: false
    t.string "modifierid", limit: 18, null: false
  end

  create_table "curr_simplemaprefset_f", primary_key: ["id", "effectivetime"], force: :cascade do |t|
    t.uuid "id", null: false
    t.string "effectivetime", limit: 8, null: false
    t.string "active", limit: 1, null: false
    t.string "moduleid", limit: 18, null: false
    t.string "refsetid", limit: 18, null: false
    t.string "referencedcomponentid", limit: 18, null: false
    t.text "maptarget", null: false
    t.index ["moduleid", "refsetid", "referencedcomponentid"], name: "test"
  end

  create_table "curr_simplerefset_f", primary_key: ["id", "effectivetime"], force: :cascade do |t|
    t.uuid "id", null: false
    t.string "effectivetime", limit: 8, null: false
    t.string "active", limit: 1, null: false
    t.string "moduleid", limit: 18, null: false
    t.string "refsetid", limit: 18, null: false
    t.string "referencedcomponentid", limit: 18, null: false
  end

  create_table "curr_stated_relationship_f", primary_key: ["id", "effectivetime"], force: :cascade do |t|
    t.string "id", limit: 18, null: false
    t.string "effectivetime", limit: 8, null: false
    t.string "active", limit: 1, null: false
    t.string "moduleid", limit: 18, null: false
    t.string "sourceid", limit: 18, null: false
    t.string "destinationid", limit: 18, null: false
    t.string "relationshipgroup", limit: 18, null: false
    t.string "typeid", limit: 18, null: false
    t.string "characteristictypeid", limit: 18, null: false
    t.string "modifierid", limit: 18, null: false
  end

  create_table "curr_textdefinition_f", primary_key: ["id", "effectivetime"], force: :cascade do |t|
    t.string "id", limit: 18, null: false
    t.string "effectivetime", limit: 8, null: false
    t.string "active", limit: 1, null: false
    t.string "moduleid", limit: 18, null: false
    t.string "conceptid", limit: 18, null: false
    t.string "languagecode", limit: 2, null: false
    t.string "typeid", limit: 18, null: false
    t.text "term", null: false
    t.string "casesignificanceid", limit: 18, null: false
  end

  create_table "histologies", id: :integer, default: -> { "nextval('diagnoses_id_seq'::regclass)" }, force: :cascade do |t|
    t.string "name", null: false
    t.string "icdo3_code"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "histology_synonyms", id: :integer, default: -> { "nextval('diagnosis_synonyms_id_seq'::regclass)" }, force: :cascade do |t|
    t.integer "histology_id", null: false
    t.string "name", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "maps", id: :serial, force: :cascade do |t|
    t.string "icdo3_axis", null: false
    t.string "icdo3_code", null: false
    t.string "snomed_code", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "refsetid"
  end

  create_table "seer_valid_icdo3_site_histology_combinations", force: :cascade do |t|
    t.string "icdo3_histology_code", null: false
    t.string "icdo3_site_code", null: false
  end

  create_table "site_synonyms", id: :serial, force: :cascade do |t|
    t.integer "site_id", null: false
    t.string "name", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "sites", id: :serial, force: :cascade do |t|
    t.string "name", null: false
    t.string "icdo3_code"
    t.string "level"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "snomed_precoordinated_mappings", id: :serial, force: :cascade do |t|
    t.string "conceptid", null: false
    t.string "histology_destinationid", null: false
    t.string "site_destinationid", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["histology_destinationid", "site_destinationid"], name: "idx_histology_destinationid_site_destinationid"
  end

end
