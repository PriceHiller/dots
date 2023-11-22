syn match org_table_sep /\(|\|\-\|+\)/  contained
syn match org_table_header /|.*|/ contained contains=org_table_sep
syn match org_table_header_region /|.*|\_s*|\_s*\(-+\|\-\).*|\_s*$/ contained contains=org_table_header
syn match org_table /|.*|\_s*$/ contained contains=org_table_sep,org_table_header_region
syn match org_table_region /^\s*|.*|\_s*$/ contains=org_table
