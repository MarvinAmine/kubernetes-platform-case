# S3 Upload Folder

Recommended S3 subfolder name:

- `payment-exception-review-stage-1`

How to use:

1. Open this folder.
2. Upload its full contents to your existing portfolio bucket under the subfolder:
   - `payment-exception-review-stage-1/`
3. Use `index.html` as the entry page.

Expected structure in S3:

- `payment-exception-review-stage-1/index.html`
- `payment-exception-review-stage-1/assets/...`
- `payment-exception-review-stage-1/stage1/index.html`
- `payment-exception-review-stage-1/stage1/troubleshooting/...`
- `payment-exception-review-stage-1/stage2/index.html`

This folder is self-contained for static website hosting, with shared assets and
separate Stage 1 and Stage 2 presentation entrypoints.
