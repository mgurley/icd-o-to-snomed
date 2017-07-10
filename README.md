# icd-o-to-snomed
Some code to perform mappings from ICD-O to SNOMED.

* Dependencies:
 * Ruby:  Ruby version: 2.3.1
 * Ruby on Rails:  ~5.1.2
 * Databases:
	 * SNOMED CT:
		 * PostgreSQL >=9.4
		 * Download: https://www.nlm.nih.gov/healthit/snomedct/us_edition.html
		 * Useful project for loading SNOMED CT into a PostgreSQL database: https://github.com/rorydavidson/SNOMED-CT-Database
	 * NCI Metathesaurus:
		 * MySQL >=5.6.25
		 * Download: https://cbiit.nci.nih.gov/evs-download/metathesaurus-downloads/
		 * You will need UMLS credentials to download the NCI Metathesaurus.
		 * Useful tutorial on MetamorphoSys – The UMLS Installation Tool: http://blog.appliedinformaticsinc.com/getting-started-with-metamorphosys-the-umls-installation-tool/

 # Instructions

* The applications assumes it is pointed to a SNOMED CT database loaded into PostgreSQL.  See config/database.yml for database connection information.
* Install the Rails bundle
```
bundle exec install
```
* Migrate the custom tables:
```
bundle exec rake db:migrate
```

*  The installation of the NCI Metathesaurus is only necessary to obtain a copy of ICD-O 3.1 histologies.
	*  WHO/IARC published ICD-O 3 in 2000 .
	*  WHO makes ICD-O 3  available in a downloadable tab-delimited format here: http://www.who.int/classifications/icd/adaptations/oncology/en/
	*  WHO/IARC published ICD-O 3.1 in 2011.
	*  WHO does not make available a downloadable tab-delimited format of ICD-O 3.1.
	*  WHO does provide a summary of the 2011 3.1 changes in PDF format here: http://www.who.int/classifications/icd/updates/icd03updates/en/
	* The NCI Metathesaurus contains ICD-O 3.1.
	* Here is some SQL to extract ICD-O 3.1 histologies from the NCI Metathesaurus:

  ```
SELECT code AS icdo3_histology_code
     , str AS icdo3_histology_code_name
FROM mrconso
WHERE sab = 'ICDO'
AND tty = 'PT'
AND code like '%/%'
ORDER BY code, tty
   ```
   *  Save the results of this SQL to lib/setup/data/icd_o_31_histologies.csv
   *  Here is some SQL to extract ICD-O 3.1 histology synonyms from the NCI Metathesaurus:

   ```
SELECT code AS icdo3_histology_code
     , str AS icdo3_histology_synonym_name
FROM mrconso m1
WHERE
sab = 'ICDO'
AND code like '%/%'
AND tty IN('SY', 'RT')
AND NOT EXISTS(
SELECT 1
FROM mrconso m2
WHERE
sab = 'ICDO'
AND code like '%/%'
AND tty = 'OP'
AND m1.code = m2.code
)
ORDER BY code, tty

   ```
   * Save the results of this SQL to lib/setup/data/icd_o_31_histology_synonyms.csv
   * Run the following rake task to load ICD-O 3.1 histologies and histology synonyms :
   ```
   bundle exec rake setup:histologies_nci
   ```
   * This loads the ICD-O 3.1 histologies into the histologies and histology_synonyms tables.
   * Run the following rake task to load ICD-O 3.1 sites and and site synonyms :
   ```
      bundle exec rake setup:sites_who
   ```
   * This loads the sites and site_synonyms tables from the file lib/setup/data/Topoenglish.txt.  This file was obtained from WHO at the link above.  There were no changes in the sites axis of ICD-O between versions 3 and and 3.1.
   * Load valid combinations of site and histology based on the ICD-O-3 SEER Site/Histology Validation List obtained here: https://seer.cancer.gov/icd-o-3/.  This Excel Validation List has been saved at lib/setup/data/sitetype.icdo3.d20150918.xls.  A CSV version of the Validation List has been saved at lib/setup/data/sitetype.icdo3.d20150918.csv.  Run the following rake task to parse the SEER file:
   ```
      bundle exec rake setup:seer_site_histology_validation_list
   ```
   * This loads the seer_valid_icdo3_site_histology_combinations table with valid combinations for malignant tumors and Primary CNS benign tumors.   It also saves the combinations to a file at lib/setup/data_out/seer_valid_icdo3_site_histology_combinations.csv.
   * Load ICD-O 3.1 axis to SNOMED axis mappings.
	   * ICD-O 3.1 histology axis to "Body Structure (body structure) | Body structure, altered from its original anatomical structure (morphologic abnormality)"
	   * ICD-O 3.1 site axis to "Body Structure (body structure) | Anatomical or acquired body structure (body structure)"
	   * Run the following rake task load the ICD-O 3.1 axis to SNOMED axis mappings :
     ```
     bundle exec rake setup:icd_o_3_axis_to_snomed_axis_map
     ```
	 * This loads the maps table with ICD-O 3.1 codes paired with a corresponding SNOMED code via the 'ICD-O simple map reference set (foundation metadata concept) 446608001'.  SNOMED has made known that refset 445508001 maps to an unreleased version of ICD-O 3.2 via ICD-11.
	 * Here is some SQL to analyze the axis to axis mappings:
	 ```
         /* List all ICD-O 3.1 Site codes */
         select  m.icdo3_axis, s.icdo3_code, s.name, m.snomed_code, m.refsetid
         from sites s left join maps m on s.icdo3_code = m.icdo3_code and m.icdo3_axis = 'site' and m.refsetid = '446608001'
         where s.level = '4'
         order by s.icdo3_code

         /* List all unmapped ICD-O 3.1 Site codes: 43 */
         select s.icdo3_code, s.name, count(m.snomed_code) as     snomed_code_map_count
         from sites s left join maps m on s.icdo3_code = m.icdo3_code and m.icdo3_axis = 'site' and m.refsetid = '446608001'
         where s.level = '4'
         group by s.name, s.icdo3_code
         having count(m.snomed_code) = 0
         order by s.icdo3_code

         /* List all ICD-O 3.1 Site codes mapped to one SNOMED code: 4 */
         select s.icdo3_code, s.name, count(m.snomed_code) as snomed_code_map_count
         from sites s left join maps m on s.icdo3_code = m.icdo3_code and m.icdo3_axis = 'site' and m.refsetid = '446608001'
         where s.level = '4'
         group by s.name, s.icdo3_code
         having count(m.snomed_code) = 1
         order by s.icdo3_code

         /* List all ICD-O 3.1 Site codes mapped more than one SNOMED code: 283 */
         select s.icdo3_code, s.name, count(m.snomed_code) as snomed_code_map_count
         from sites s left join maps m on s.icdo3_code = m.icdo3_code and m.icdo3_axis = 'site' and m.refsetid = '446608001'
         where s.level = '4'
         group by s.name, s.icdo3_code
         having count(m.snomed_code) > 1
         order by s.icdo3_code

         /* List all ICD-O 3.1 Histology codes */
         select  m.icdo3_axis, h.icdo3_code, h.name, m.snomed_code, m.refsetid
         from histologies h left join maps m on h.icdo3_code = m.icdo3_code and m.icdo3_axis = 'histology' and m.refsetid = '446608001'
         order by h.icdo3_code

         /* List all unmapped ICD-O 3.1 Histology codes: 13 */
         select h.name, h.icdo3_code, count(m.snomed_code) as snomed_code_map_count
         from histologies h left join maps m on h.icdo3_code = m.icdo3_code and m.icdo3_axis = 'histology' and m.refsetid = '446608001'
         group by h.name, h.icdo3_code
         having count(m.snomed_code) = 0
         order by h.icdo3_code

         /* List all ICD-O 3.1 Histology codes mapped to one SNOMED code: 854 */
         select h.name, h.icdo3_code, count(m.snomed_code) as snomed_code_map_count
         from histologies h left join maps m on h.icdo3_code = m.icdo3_code and m.icdo3_axis = 'histology' and m.refsetid = '446608001'
         group by h.name, h.icdo3_code
         having count(m.snomed_code) = 1
         order by h.icdo3_code

         /* List all ICD-O 3.1 Histology codes mapped more than one SNOMED code: 198 */
         select h.name, h.icdo3_code, count(m.snomed_code) as snomed_code_map_count
         from histologies h left join maps m on h.icdo3_code = m.icdo3_code and m.icdo3_axis = 'histology' and m.refsetid = '446608001'
         group by h.name, h.icdo3_code
         having count(m.snomed_code) > 1
         order by h.icdo3_code
          ```
   * 69,824 SNOMED Disease (disorders) have a pre-coordinated relationship via the 'Finding Site' attribute relationship and an 'Associated Morphology' attribute relationship.
     * Here is some SQL to list the SNOMED precoordinations:
     ```
        SELECT  distinct  d.conceptid
              , r.destinationid AS histology_destinationid
              , r2.destinationid AS site_destinationid
        FROM curr_description_f d
        join curr_relationship_f r on d.conceptid = r.sourceid and r.active = '1' and r.typeid = '116676008' -- "Associated morphology (attribute)"
        join curr_relationship_f r2 on d.conceptid = r2.sourceid and r2.active = '1' and r2.typeid = '363698007' and r.relationshipgroup = r2.relationshipgroup -- "Finding site (attribute)"
        where d.typeid = '900000000000003001'
        and d.active = '1'
        and not exists(
        select 1
        from curr_relationship_f r3
        where r.moduleid = r3.moduleid
        and r.sourceid = r3.sourceid
        and r.relationshipgroup = r3.relationshipgroup
        and r.typeid = r3.typeid
        --and r.characteristictypeid = r3.characteristictypeid
        --and r.modifierid = r3.modifierid
        and r3.effectivetime > r.effectivetime
        )
        and not exists(
        select 1
        from curr_relationship_f r4
        where r2.moduleid = r4.moduleid
        and r2.sourceid = r4.sourceid
        and r2.relationshipgroup = r4.relationshipgroup
        and r2.typeid = r4.typeid
        --and r2.characteristictypeid = r4.characteristictypeid
        --and r2.modifierid = r4.modifierid
        and r4.effectivetime > r2.effectivetime
        )
        order by d.conceptid
        ```
     *  Here is some SQL to list all the precoordinated SNOMED Disease (disorders)  that can be mapped to valid SEER ICD-O 3.1 site/histology combinations:
     ```
        /* 1915 non-unique SEER site/histology combinations can be mapped to precoordinated  SNOMED Disease (disorders), 975 unique combinations*/
        with icd_o_to_snomed_site_maps  as (
        select referencedcomponentid
             , refsetid
             , active
             , maptarget
        from curr_simplemaprefset_f map
        where map.refsetid = '446608001'
        and map.active = '1'
        and maptarget like '%C%'
        and not exists(
        select 1
        from curr_simplemaprefset_f map2
        where map.moduleid = map2.moduleid
        and map.refsetid = map2.refsetid
        and map.referencedcomponentid = map2.referencedcomponentid
        and map2.effectivetime > map.effectivetime
        )
        ),
        icd_o_to_snomed_histology_maps  as (
        select referencedcomponentid
             , refsetid
             , active
             , maptarget
        from curr_simplemaprefset_f map
        where map.refsetid = '446608001'
        and map.active = '1'
        and maptarget like '%/%'
        and not exists(
        select 1
        from curr_simplemaprefset_f map2
        where map.moduleid = map2.moduleid
        and map.refsetid = map2.refsetid
        and map.referencedcomponentid = map2.referencedcomponentid
        and map2.effectivetime > map.effectivetime
        )
        )
        SELECT  distinct  d.conceptid
              , r2.destinationid AS site_destinationid
              , r.destinationid AS histology_destinationid
              , icd_o_to_snomed_histology_maps.maptarget as histology_icdo_3_code
              , icd_o_to_snomed_site_maps.maptarget as site_icdo_3_code
              , seer_valid_icdo3_site_histology_combinations.icdo3_site_code
              , seer_valid_icdo3_site_histology_combinations.icdo3_histology_code
        FROM curr_description_f d
        join curr_relationship_f r on d.conceptid = r.sourceid and r.active = '1' and r.typeid = '116676008' -- "Associated morphology (attribute)"
        join curr_relationship_f r2 on d.conceptid = r2.sourceid and r2.active = '1' and r2.typeid = '363698007' and r.relationshipgroup = r2.relationshipgroup -- "Finding site (attribute)"
        left join icd_o_to_snomed_histology_maps on r.destinationid =  icd_o_to_snomed_histology_maps.referencedcomponentid
        left join icd_o_to_snomed_site_maps on r2.destinationid =  icd_o_to_snomed_site_maps.referencedcomponentid
        left join seer_valid_icdo3_site_histology_combinations on seer_valid_icdo3_site_histology_combinations.icdo3_site_code = icd_o_to_snomed_site_maps.maptarget and seer_valid_icdo3_site_histology_combinations.icdo3_histology_code = icd_o_to_snomed_histology_maps.maptarget
        where d.typeid = '900000000000003001'
        and d.active = '1'
        and not exists(
        select 1
        from curr_relationship_f r3
        where r.moduleid = r3.moduleid
        and r.sourceid = r3.sourceid
        and r.relationshipgroup = r3.relationshipgroup
        and r.typeid = r3.typeid
        --and r.characteristictypeid = r3.characteristictypeid
        --and r.modifierid = r3.modifierid
        and r3.effectivetime > r.effectivetime
        )
        and not exists(
        select 1
        from curr_relationship_f r4
        where r2.moduleid = r4.moduleid
        and r2.sourceid = r4.sourceid
        and r2.relationshipgroup = r4.relationshipgroup
        and r2.typeid = r4.typeid
        --and r2.characteristictypeid = r4.characteristictypeid
        --and r2.modifierid = r4.modifierid
        and r4.effectivetime > r2.effectivetime
        )
        and exists(
        select 1
        from icd_o_to_snomed_histology_maps
        where r.destinationid =  icd_o_to_snomed_histology_maps.referencedcomponentid
        )
        and exists(
        select 1
        from icd_o_to_snomed_site_maps
        where r2.destinationid =  icd_o_to_snomed_site_maps.referencedcomponentid
        )
        and seer_valid_icdo3_site_histology_combinations.icdo3_site_code is not null
        and seer_valid_icdo3_site_histology_combinations.icdo3_histology_code is not null
        order by icd_o_to_snomed_histology_maps.maptarget, icd_o_to_snomed_site_maps.maptarget
        ```
   *  It might be possible select a single SNOMED code appropriate for each ICD-O 3.1 code if the multiple mappings could role up to single code within the SNOMED hierarchy via the "Is a (attribute)" relationship.  Here is some SQL that might help with analyzing this possibility:
   ```
      with icd_o_to_snomed_site_maps  as (
      select referencedcomponentid
      , refsetid
      , active
      , maptarget
      from curr_simplemaprefset_f map
      where map.refsetid = '446608001'
      and map.active = '1'
      and maptarget like '%C%'
      and not exists(
      select 1
      from curr_simplemaprefset_f map2
      where map.moduleid = map2.moduleid
      and map.refsetid = map2.refsetid
      and map.referencedcomponentid = map2.referencedcomponentid
      and map2.effectivetime > map.effectivetime
      )
      )
      --'C01.9'
      --'C00.4'
      select *
      from icd_o_to_snomed_site_maps m1 join curr_relationship_f r on r.sourceid = m1.referencedcomponentid and r.active = '1'and r.typeid in('116680003')
                                        join icd_o_to_snomed_site_maps m2 on r.destinationid = m2.referencedcomponentid
      where m1.maptarget = 'C01.9'
      and m2.maptarget = 'C01.9'
      and not exists(
      select 1
      from curr_relationship_f r2
      where r.moduleid = r2.moduleid
      and r.sourceid = r2.sourceid
      and r.relationshipgroup = r2.relationshipgroup
      and r.typeid = r2.typeid
      --and r.characteristictypeid = r2.characteristictypeid
      --and r.modifierid = r2.modifierid
      and r2.effectivetime > r.effectivetime
      )
      order by r.sourceid, r.destinationid
      ```