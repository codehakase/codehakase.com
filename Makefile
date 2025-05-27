.PHONY: upload-static upload-path

# Upload all static images to Cloudflare R2
upload-static:
	@echo "Uploading static images to Cloudflare R2..."
	find static/images -type f | xargs -I{} sh -c 'echo "Uploading {}"; wrangler r2 object put blog/{} --file "{}" --remote'
	@echo "Upload complete!"

# Upload a specific path to Cloudflare R2
# Usage: make upload-path PATH=static/images/path/to/file.jpg
upload-path:
	@if [ -z "$(PATH)" ]; then echo "Error: PATH is required. Usage: make upload-path PATH=static/images/path/to/file"; exit 1; fi
	@if [ ! -e "$(PATH)" ]; then echo "Error: $(PATH) does not exist"; exit 1; fi
	@if [[ "$(PATH)" != static/images* ]]; then echo "Error: Path must be within static/images"; exit 1; fi
	@if [ -d "$(PATH)" ]; then \
		echo "Uploading directory $(PATH) to R2...";\
		wrangler r2 object put blog/$(PATH) --path "$(PATH)" --recursive --remote;\
	else \
		echo "Uploading file $(PATH) to R2...";\
		wrangler r2 object put blog/$(PATH) --file "$(PATH)" --remote;\
	fi
	@echo "Upload complete!"
