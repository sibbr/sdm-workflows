### Definição de tipos
type request_file;
type occurrences_file;
type serialized_model;
type projected_map;

type modeling_results {
	serialized_model model;
	projected_map map;
}

### Mapeando variáveis ao fs
request_file requests[] <ext;exec="species_mapper.sh",o=@filename(occurrences)>;
occurrences_file occurrences <single_file_mapper;file="./teste.txt">;
modeling_results results[] <ext;exec="modeling_results_mapper.sh",o=@filename(occurrences)>;

### Definição das apps
app (request_file out[]) generate_requests(occurrences_file i) {
	generate_requests @filename(i);
}

app (modeling_results out) do_modeling(request_file r) {
	om_console @filename(r);
}

### Início do script
requests = generate_requests(occurrences);

foreach request,index in requests {
	results[index] = do_modeling(request);
	trace(requests[index]);
}
