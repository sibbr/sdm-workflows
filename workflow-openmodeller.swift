### Type definitions
type request_file;
type environment_layers;
type occurrences_file;
type serialized_model;
type projected_map;

type modeling_results {
	serialized_model model;
	projected_map map;
}

### Mapper declarations
request_file requests[] <ext;exec="species_mapper.sh",o=filename(occurrences)>;
environment_layers env_layers[] <filesys_mapper;location="workshop/Brasil_ASC/", suffix=".asc">;
# Receives the path to the occurrences file through the -o parameter
occurrences_file occurrences <single_file_mapper;file=arg("o")>;
modeling_results results[] <ext;exec="modeling_results_mapper.sh",o=filename(occurrences)>;

### App definitions
app (request_file out[]) generate_requests(occurrences_file i) {
	generate_requests filename(i);
}

app (modeling_results out) do_modeling(request_file r, environment_layers e[], occurrences_file o) {
	om_console filename(r);
}

### 
requests = generate_requests(occurrences);

foreach request,index in requests {
	results[index] = do_modeling(request, env_layers, occurrences);
}
