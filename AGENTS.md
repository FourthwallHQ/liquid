# Instructions
- The user will provide a task involving this repository.
- Wait for all terminal commands to finish before responding.
- Follow the repo workflow and conventions described below when making changes.

# Code Style
- Ruby code must follow the RuboCop configuration in `.rubocop.yml` and `.rubocop_todo.yml`.
- Use two spaces for indentation and keep lines under 120 characters.
- Prepend files with `# frozen_string_literal: true` when creating new Ruby files.

# Workflow
- Always use Bundler when running Ruby commands:
  - Install dependencies with `bundle install` if needed.
  - Run the test suite with `bundle exec rake`. This runs unit/integration tests and RuboCop.
  - Run style checks manually with `bundle exec rubocop` if necessary.
- Use Rake tasks defined in the `Rakefile` for common operations:
  - `bundle exec rake`        - default task, runs tests and RuboCop
  - `bundle exec rake test`   - run test suite in strict and lax modes
  - `bundle exec rake example` - run example server
  - See `rake -T` for the full list.

# Commit Guidelines
- Keep commit messages concise; use the imperative mood ("Add feature" not "Added feature").
- Do not amend existing commits or force push.
- Ensure `git status` shows a clean working tree before finishing.

# Additional Notes
- Review `CONTRIBUTING.md` for project guidelines before submitting a PR.
- The GitHub Actions workflow (`.github/workflows/liquid.yml`) mirrors the `bundle exec rake` command; local tests should match it.

- Use `rg` (ripgrep) for searching the codebase:
  - `rg "password" --type-list` lists available file types
  - `rg "password" -t js -C 3` searches JavaScript files with context
  - Add `-i` for case-insensitive search and `-g '!pattern'` to exclude paths
- Generate RubyGems documentation for installed gems:
  `bundle list | grep -E 'devise|pundit' | awk '{print $2}' | xargs gem rdoc --ri`
  Browse the docs with `ri ClassName` or `ri gemname:ClassName`.
- Search RDoc or YARD documentation with ripgrep:
  `rg "def authenticate" ~/rdoc/ -g "*.html" --html -B 2 -A 5`
  Searches generated docs (e.g., `~/rdoc/` or `./doc/`) and shows context around matches.
  - `-g "*.html"` limits results to HTML files
  - `--html` ignores tags and focuses on content
  - `-B 2 -A 5` includes two lines before and five after each match
  More specific than `ri` for locating implementations across gems.


# Citations instructions
- When referencing lines from files, use the format `F:<filepath>†L<start>-L<end>`.
- When referencing terminal output, use the format `<chunk_id>†L<start>-L<end>`.
- Provide citations in the final answer as needed.
