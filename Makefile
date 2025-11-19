.PHONY: upload-static upload-path

# Upload all static images to Cloudflare R2
upload-static:
	@echo "Uploading static images to Cloudflare R2..."
	find static/images -type f | xargs -I{} sh -c 'echo "Uploading {}"; wrangler r2 object put blog/{} --file "{}" --remote'
	@echo "Upload complete!"

# Upload a specific path to Cloudflare R2
# Usage: make upload-path SRCP=static/images/path/to/file.jpg
upload-path:
	@if [ -z "$(SRCP)" ]; then echo "Error: SRCP is required. Usage: make upload-path SRCP=static/images/path/to/file"; exit 1; fi
	@if [ ! -e "$(SRCP)" ]; then echo "Error: $(SRCP) does not exist"; exit 1; fi
	@if [ -d "$(SRCP)" ]; then \
		echo "Uploading directory $(SRCP) to R2...";\
		wrangler r2 object put blog/$(SRCP) --path "$(SRCP)" --recursive --remote;\
	else \
		echo "Uploading file $(SRCP) to R2...";\
		wrangler r2 object put blog/$(SRCP) --file "$(SRCP)" --remote;\
	fi
	@echo "Upload complete!"
