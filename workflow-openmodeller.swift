### Type definitions
type request_file;
type occurrences_file;
type mask_file;
type output_format_file;
type output_mask_file;
type serialized_model;
type projected_map;
type map;
type output_map;

type modeling_results {
	serialized_model model;
	projected_map map;
}

### Mapper declarations
occurrences_file occurrences <single_file_mapper;file=arg("o")>;
mask_file mask <single_file_mapper;file=arg("mask-file")>;
output_format_file output_format <single_file_mapper;file=arg("output-format")>;
output_mask_file output_mask <single_file_mapper;file=arg("output-mask")>;
string min_occ=arg("min-occ", "10");
request_file requests[] <ext;exec="species_mapper.sh",i=filename(occurrences), m=min_occ>;
map maps_env[] <fixed_array_mapper; files=arg("maps")>;
output_map output_maps[] <fixed_array_mapper; files=arg("output-maps")>;
# Receives the path to the occurrences file through the -o parameter
modeling_results results[] <ext;exec="modeling_results_mapper.sh",i=filename(occurrences), m=min_occ>;

### App definitions
app (request_file out[]) generate_requests(occurrences_file i, string m, map maps[], mask_file mf, output_format_file off, output_map omaps[], output_mask_file omf) {
	generate_requests "-o" filename(i) 
		"--min_occurrences" m 
		"--map_list" strjoin(filenames(maps), ",")
		"-m" filename(mf) 
		"--output_format_file" filename(off)
		"--output_map_list" strjoin(filenames(omaps), ",")
		"--output_mask_file" filename(omf);
}

app (modeling_results out) do_modeling(request_file r, occurrences_file o, map maps[], mask_file mf, output_format_file off, output_map omaps[], output_mask_file omf) {
	om_console filename(r);
}

### Function call
requests = generate_requests(occurrences, min_occ, maps_env, mask, output_format, output_maps, output_mask);

foreach request,index in requests {
	results[index] = do_modeling(request, occurrences, maps_env, mask, output_format, output_maps, output_mask);
}
