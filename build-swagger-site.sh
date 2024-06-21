#!/bin/bash
set -Eeuxo pipefail
# This script downloads a ZIP file containing OpenAPI specs, extracts them and generates a site with Swagger UI

echo "Create output directory for GitHub Pages content"
mkdir "$OUTPUT_DIR"

echo "Download the ZIP file containing Swagger UI"
curl -sSLo ui.zip "$UI_ZIP_URL"

echo "Extract Swagger UI"
unzip -j ui.zip "$UI_EXTRACT_FILTER" -d "$OUTPUT_DIR"

echo "Copy the html page containing Swagger UI and add Google tag"
sed "/<head>/a$GOOGLE_TAG" index.html > "$OUTPUT_DIR/index.html"

echo "Download the ZIP files containing the OpenAPI specs"
curl -sSLo 2.3.zip "$SPEC_ZIP_URL_V2_3"
curl -sSLo 2.4.zip "$SPEC_ZIP_URL_V2_4"

echo "Extract OpenAPI specs"
mkdir $OUTPUT_DIR/specs
unzip -j 2.3.zip "$SPEC_EXTRACT_FILTER" -d "$OUTPUT_DIR/specs/2.3"
unzip -j 2.4.zip "$SPEC_EXTRACT_FILTER" -d "$OUTPUT_DIR/specs/2.4"

echo "List OpenAPI spec files in specs directory and Generate Swagger configuration file in YAML containing the relative URLs"
(
    echo 'urls:'
    find "$OUTPUT_DIR/specs" -type f -printf '%P\n' | sed -ne 's|^\(.*\)\.\([^.]*\)$|  - url: "specs/\1.\2"\n    name: "\1"|p'
) > _site/generated-swagger-config.yaml