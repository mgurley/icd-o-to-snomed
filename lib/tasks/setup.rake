require 'csv'
namespace :setup do
  desc "Sites WHO"
  task(sites: :environment) do  |t, args|
    Site.delete_all
    SiteSynonym.delete_all
    sites = CSV.new(File.open('lib/setup/data/Topoenglish.txt'), headers: true, col_sep: "\t", return_headers: true,  quote_char: "\'")
    sites.each do |row|
      puts row.to_hash['Kode']
      puts row.to_hash['Lvl']
      puts row.to_hash['Title']

      case row.to_hash['Lvl']
      when '3', '4'
        Site.create!(name: row.to_hash['Title'].gsub('"', '').downcase, icdo3_code: row.to_hash['Kode'], level: row.to_hash['Lvl'])
      end
    end

    sites = CSV.new(File.open('lib/setup/data/Topoenglish.txt'), headers: true, col_sep: "\t", return_headers: true,  quote_char: "\'")
    sites.each do |row|
      puts row.to_hash['Kode']
      puts row.to_hash['Lvl']
      puts row.to_hash['Title']

      case row.to_hash['Lvl']
      when 'incl'
        site = Site.where(icdo3_code: row.to_hash['Kode']).first
        site.site_synonyms.build(name: row.to_hash['Title'].gsub('"', '').downcase)
        site.save!
      end
    end

    def site_name_exists?(site_name)
      (Site.all.any? { |site| site.name.downcase.strip == site_name }  || SiteSynonym.all.any? { |site_synonym| site_synonym.name.downcase.strip == site_name })
    end

    Site.all.each do |site|
      words = site.name.split(',').map(&:strip) - ['nos']
      if words.size == 1
        name = words.first
        if !site_name_exists?(name)
          site.site_synonyms.build(name: words.first)
          site.save!
        end
      end
      if words.size > 1
        name = words.reverse.join(' ')
        if !site_name_exists?(name)
          site.site_synonyms.build(name: name)
          site.save!
        end

        name = words.join(' ')
        if !site_name_exists?(name)
          site.site_synonyms.build(name: name)
          site.save!
        end
      end
    end

    SiteSynonym.all.each do |site_synonym|
      words = site_synonym.name.split(',').map(&:strip) - ['nos']
      if words.size == 1
        name = words.first
        site = site_synonym.site
        if !site_name_exists?(name)
          site.site_synonyms.build(name: words.first)
          site.save!
        end
      end
      if words.size > 1
        site = site_synonym.site
        name = words.reverse.join(' ')
        if !site_name_exists?(name)
          site.site_synonyms.build(name: name)
          site.save!
        end

        name = words.join(' ')
        if !site_name_exists?(name)
          site.site_synonyms.build(name: name)
          site.save!
        end
      end
    end
  end

  desc "Histologies NCI"
  task(histologies_nci: :environment) do  |t, args|
    Histology.delete_all
    HistologySynonym.delete_all
    histologies = CSV.new(File.open('lib/setup/data/icd_o_31_histologies.csv'), headers: true, col_sep: ",", return_headers: false,  quote_char: "\"")
    histologies.each do |row|
      puts row.to_hash['icdo3_histology_code_name']
      puts row.to_hash['icdo3_histology_code']

      Histology.create!(name: row.to_hash['icdo3_histology_code_name'].downcase, icdo3_code: row.to_hash['icdo3_histology_code'])
    end


    histology_synonyms = CSV.new(File.open('lib/setup/data/icd_o_31_histology_synonyms.csv'), headers: true, col_sep: ",", return_headers: false,  quote_char: "\"")
    histology_synonyms.each do |row|
      puts row.to_hash['icdo3_histology_synonym_name']
      puts row.to_hash['icdo3_histology_code']

      histology = Histology.where(icdo3_code: row.to_hash['icdo3_histology_code']).first
      histology.histology_synonyms.build(name: row.to_hash['icdo3_histology_synonym_name'].downcase)
      histology.save!
    end
  end

  desc "SEER site histology validation list"
  task(seer_site_histology_validation_list: :environment) do  |t, args|
    site_histologies = CSV.new(File.open('lib/setup/data/sitetype.icdo3.d20150918.csv'), headers: true, col_sep: ",", return_headers: false,  quote_char: "\"")
    sites = Site.where(level: '4').order('icdo3_code ASC').map(&:icdo3_code)
    valid_site_histologies = []

    site_histologies.each do |site_histology|
      puts 'moomin'
      # puts site_histology.to_hash
      # site_histology.to_hash.keys.each do |key|
      #   puts key
      #   puts site_histology.to_hash[key]
      # end
      puts site_histology.to_hash['Site recode']
      site_histology.to_hash['Site recode'].split(',').each do |site_range|
        site_range.strip!
        if site_range.include?('-')
          begin_site, end_site = site_range.split('-')
          puts begin_site
          puts end_site
          begin_site = begin_site.insert(3, '.')
          end_site = end_site.insert(3, '.')
          begin_site_range = sites.index(begin_site)
          end_site_range = sites.index(end_site)
          puts begin_site_range
          puts end_site_range
          sites[begin_site_range..end_site_range].each do |site|
            puts site
            valid_site_histologies << { site: site, histology: site_histology.to_hash['Histology/Behavior']}
          end
        else
          # valid_site_histologies
          puts site_range
          site_range.insert(3, '.')
          valid_site_histologies << { site: site_range, histology: site_histology.to_hash['Histology/Behavior']}
        end
      end
      puts site_histology.to_hash['Site Description']
      puts site_histology.to_hash['Histology']
      puts site_histology.to_hash['Histology Description']
      puts site_histology.to_hash['Histology/Behavior']
      puts site_histology.to_hash['Histology/Behavior Description']
      puts 'little my'
    end
    puts 'act like a moomin'
    puts valid_site_histologies.size
    puts valid_site_histologies

    CSV.open('lib/setup/data_out/seer_valid_icdo3_site_histology_combinations.csv', "wb") do |csv|
      csv << valid_site_histologies.first.keys
      valid_site_histologies.each do |hash|
        csv << hash.values
      end
    end

    SeerValidIcdo3SiteHistologyCombination.delete_all
    valid_site_histologies.each do |valid_site_histology|
      SeerValidIcdo3SiteHistologyCombination.create!(icdo3_histology_code: valid_site_histology[:histology], icdo3_site_code: valid_site_histology[:site])
    end
  end

  desc "ICD-O-3 axis to SNOMED map"
  task(icd_o_3_axis_to_snomed_axis_map: :environment) do  |t, args|
    refsetid = '446608001'
    Map.destroy_all
    Histology.all.each do |histology|
      puts histology.icdo3_code
      simple_map_refsets = SimpleMapRefset.where(refsetid: refsetid, maptarget: histology.icdo3_code, active: '1').where("NOT EXISTS(SELECT 1 FROM curr_simplemaprefset_f AS snomed_maps WHERE snomed_maps.moduleid = curr_simplemaprefset_f.moduleid AND snomed_maps.refsetid = curr_simplemaprefset_f.refsetid AND snomed_maps.referencedcomponentid = curr_simplemaprefset_f.referencedcomponentid AND snomed_maps.maptarget = curr_simplemaprefset_f.maptarget AND snomed_maps.effectivetime > curr_simplemaprefset_f.effectivetime)")
      if simple_map_refsets.any?
        simple_map_refsets.each do |simple_map_refset|
          map = Map.new(icdo3_axis: 'histology', icdo3_code: histology.icdo3_code, snomed_code: simple_map_refset.referencedcomponentid, refsetid: refsetid)
          map.save!
        end
      end
    end

    Site.all.each do |site|
      puts site.icdo3_code
      simple_map_refsets = SimpleMapRefset.where(refsetid: refsetid, maptarget: site.icdo3_code, active: '1').where("NOT EXISTS(SELECT 1 FROM curr_simplemaprefset_f AS snomed_maps WHERE snomed_maps.moduleid = curr_simplemaprefset_f.moduleid AND snomed_maps.refsetid = curr_simplemaprefset_f.refsetid AND snomed_maps.referencedcomponentid = curr_simplemaprefset_f.referencedcomponentid AND snomed_maps.maptarget = curr_simplemaprefset_f.maptarget AND snomed_maps.effectivetime > curr_simplemaprefset_f.effectivetime)")
      if simple_map_refsets.any?
        simple_map_refsets.each do |simple_map_refset|
          map = Map.new(icdo3_axis: 'site', icdo3_code: site.icdo3_code, snomed_code: simple_map_refset.referencedcomponentid, refsetid: refsetid)
          map.save!
        end
      end
    end
  end

  desc "ICD-O-3 Combinations to SNOMED map"
  task(icd_o_3_combinations_to_snomed_map: :environment) do  |t, args|
    site_histology_combinations = CSV.new(File.open('lib/setup/data_out/seer_valid_icdo3_site_histology_combinations.csv'), headers: true, col_sep: ",", return_headers: false,  quote_char: "\"")
    snomed_precoordinated_mappings = SnomedDescription.joins("join curr_relationship_f r on curr_description_f.conceptid = r.sourceid and r.active = '1' and r.typeid = '116676008'").
    joins("join curr_relationship_f r2 on curr_description_f.conceptid = r2.sourceid and r2.active = '1' and r2.typeid = '363698007' and r.relationshipgroup = r2.relationshipgroup").
    where(typeid: '900000000000003001', active: '1').
    where("not exists(
    select 1
    from curr_relationship_f r3
    where r.moduleid = r3.moduleid
    and r.sourceid = r3.sourceid
    and r.relationshipgroup = r3.relationshipgroup
    and r.typeid = r3.typeid
--    and r.characteristictypeid = r3.characteristictypeid
--    and r.modifierid = r3.modifierid
    and r3.effectivetime > r.effectivetime
    )").
    where("not exists(
    select 1
    from curr_relationship_f r4
    where r2.moduleid = r4.moduleid
    and r2.sourceid = r4.sourceid
    and r2.relationshipgroup = r4.relationshipgroup
    and r2.typeid = r4.typeid
--    and r2.characteristictypeid = r4.characteristictypeid
--    and r2.modifierid = r4.modifierid
    and r4.effectivetime > r2.effectivetime
    )").select('DISTINCT curr_description_f.conceptid, r.destinationid AS histology_destinationid, r2.destinationid AS site_destinationid')

    SnomedPrecoordinatedMapping.delete_all
    snomed_precoordinated_mappings.each do |snomed_precoordinated_mapping|
      SnomedPrecoordinatedMapping.create(conceptid: snomed_precoordinated_mapping['conceptid'], histology_destinationid: snomed_precoordinated_mapping['histology_destinationid'], site_destinationid: snomed_precoordinated_mapping['site_destinationid'])
    end

    CombinationMap.delete_all

    # site_histology_combinations.select { |site_histology_combination| site_histology_combination.to_hash['histology'] == '8051/3' }.each do |site_histology_combination|
    site_histology_combinations.each do |site_histology_combination|
      histology_icdo3_code = site_histology_combination.to_hash['histology']
      site_icdo3_code = site_histology_combination.to_hash['site']

      refsetid = '446608001'
      histology_icdo3_code_snomed_code_mappings = Map.where(icdo3_axis: 'histology', icdo3_code: histology_icdo3_code)
      site_icdo3_code_snomed_code_mappings = Map.where(icdo3_axis: 'site', refsetid: refsetid, icdo3_code: site_icdo3_code)

      if histology_icdo3_code_snomed_code_mappings.empty? && site_icdo3_code_snomed_code_mappings.empty?
        combination_map = CombinationMap.new
        combination_map.icdo3_histology_code = histology_icdo3_code
        combination_map.icdo3_site_code = site_icdo3_code
        combination_map.save!
      end

      if histology_icdo3_code_snomed_code_mappings.empty? && site_icdo3_code_snomed_code_mappings.any?
        site_icdo3_code_snomed_code_mappings.each do |site_icdo3_code_snomed_code_mapping|
          combination_map = CombinationMap.new
          combination_map.icdo3_histology_code = histology_icdo3_code
          combination_map.icdo3_site_code = site_icdo3_code
          combination_map.snomed_site_code = site_icdo3_code_snomed_code_mapping.snomed_code
          combination_map.save!
        end
      end

      histology_icdo3_code_snomed_code_mappings.each do |histology_icdo3_code_snomed_code_mapping|
        puts 'we have a histology map'
        puts histology_icdo3_code_snomed_code_mapping.icdo3_code
        puts histology_icdo3_code_snomed_code_mapping.snomed_code

        if site_icdo3_code_snomed_code_mappings.empty?
          combination_map = CombinationMap.new
          combination_map.icdo3_histology_code = histology_icdo3_code
          combination_map.icdo3_site_code = site_icdo3_code
          combination_map.snomed_histology_code = histology_icdo3_code_snomed_code_mapping.snomed_code
          combination_map.save!
        end

        site_icdo3_code_snomed_code_mappings.each do |site_icdo3_code_snomed_code_mapping|
          puts 'we have a site map'
          puts site_icdo3_code_snomed_code_mapping.icdo3_code
          puts site_icdo3_code_snomed_code_mapping.snomed_code

          snomed_descriptions = SnomedPrecoordinatedMapping.where(histology_destinationid: histology_icdo3_code_snomed_code_mapping.snomed_code, site_destinationid: site_icdo3_code_snomed_code_mapping.snomed_code)
          snomed_descriptions.each do |snomed_description|
            combination_map = CombinationMap.new
            combination_map.icdo3_histology_code = histology_icdo3_code
            combination_map.icdo3_site_code = site_icdo3_code
            combination_map.refsetid = histology_icdo3_code_snomed_code_mapping.refsetid
            combination_map.snomed_histology_code = histology_icdo3_code_snomed_code_mapping.snomed_code
            combination_map.snomed_site_code = site_icdo3_code_snomed_code_mapping.snomed_code
            combination_map.snomed_precoordinated_code = snomed_description.conceptid
            combination_map.save!
          end

          if snomed_descriptions.empty?
            combination_map = CombinationMap.new
            combination_map.icdo3_histology_code = histology_icdo3_code
            combination_map.icdo3_site_code = site_icdo3_code
            combination_map.refsetid = histology_icdo3_code_snomed_code_mapping.refsetid
            combination_map.snomed_histology_code = histology_icdo3_code_snomed_code_mapping.snomed_code
            combination_map.snomed_site_code = site_icdo3_code_snomed_code_mapping.snomed_code
            combination_map.save!
          end
        end
      end
    end
  end
end
