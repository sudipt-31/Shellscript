

sanitize() {
    sanitized_url=$(echo "$1" | sed 's/[^a-zA-Z0-9/:-]//g')
    sanitized_title=$(echo "$2" | sed 's/[^a-zA-Z0-9[:space:]-]//g')
    echo "$sanitized_url,$sanitized_title"
}

process_csv() {
    input_file="$1"
    output_file="$2"
 # Initialize variables to store data
    declare -A overview campus courses scholarships admission placement results
# Write headers to output file
    echo "URL,Overview,Campus,Courses,Scholarships,Admission,Placement,Results" > "$output_file"

    while IFS=, read -r url title; do
        sanitized=$(sanitize "$url" "$title")
        sanitized_url=$(echo "$sanitized" | cut -d',' -f1)
        sanitized_title=$(echo "$sanitized" | cut -d',' -f2)

 # Extract category from URL
        category=$(echo "$sanitized_url" | awk -F'/' '{print $(NF-1)}')
# Append to respective category
        case "$category" in
            ai|php|python)
                overview["$category"]="$sanitized_title"
                ;;
            *)
                echo "Unknown category found: $category"
                ;;
        esac
    done < "$input_file"

    # Write data to output file
    for key in "${!overview[@]}"; do
        url="https://example.com/data/$key"
        echo "$url,${overview[$key]},${campus[$key]},${courses[$key]},${scholarships[$key]},${admission[$key]},${placement[$key]},${results[$key]}" | tr -d '\r' >> "$output_file"
    done
}

if [ "$#" -ne 2 ]; then
    echo "Usage: $0 input_csv output_csv"
    exit 1
fi

if [ ! -f "$1" ]; then
    echo "Input file not found!"
    exit 1
fi

process_csv "$1" "$2"
echo "CSV data processed successfully."
#$ ./script.sh input.csv output.csv
