### Type definitions
type request_file;
type environment_layers;
type occurrences_file;
type mask_file;
type output_format_file;
type output_mask_file;
type serialized_model;
type projected_map;

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
request_file requests[] <ext;exec="species_mapper.sh",i=filename(occurrences), min=min_occ>;
environment_layers env_layers[] <filesys_mapper;location="workshop/Brasil_ASC/", suffix=".asc">;
# Receives the path to the occurrences file through the -o parameter
modeling_results results[] <ext;exec="modeling_results_mapper.sh",i=filename(occurrences), min=min_occ>;

### App definitions
app (request_file out[]) generate_requests(occurrences_file i, string m, mask_file mf, output_format_file off, output_mask_file omf) {
	generate_requests filename(i) m filename(mf) filename(off) filename(omf);
}

app (modeling_results out) do_modeling(request_file r, environment_layers e[], occurrences_file o) {
	om_console filename(r);
}

### Function call
requests = generate_requests(occurrences, min_occ, mask, output_format, output_mask);

foreach request,index in requests {
	results[index] = do_modeling(request, env_layers, occurrences);
}
