# Contributing to DevSwitch

We love your input! We want to make contributing to DevSwitch as easy and transparent as possible, whether it's:

- Reporting a bug
- Discussing the current state of the code
- Submitting a fix
- Proposing new features
- Becoming a maintainer

## Development Process

We use GitHub to host code, to track issues and feature requests, as well as accept pull requests.

## Pull Requests

Pull requests are the best way to propose changes to the codebase. We actively welcome your pull requests:

1. Fork the repo and create your branch from `main`.
2. If you've added code that should be tested, add tests.
3. If you've changed APIs, update the documentation.
4. Ensure the test suite passes.
5. Make sure your code lints.
6. Issue that pull request!

## Any contributions you make will be under the MIT Software License

In short, when you submit code changes, your submissions are understood to be under the same [MIT License](LICENSE) that covers the project. Feel free to contact the maintainers if that's a concern.

## Report bugs using GitHub's [issue tracker](https://github.com/yourusername/devswitch/issues)

We use GitHub issues to track public bugs. Report a bug by [opening a new issue](https://github.com/yourusername/devswitch/issues/new).

## Write bug reports with detail, background, and sample code

**Great Bug Reports** tend to have:

- A quick summary and/or background
- Steps to reproduce
  - Be specific!
  - Give sample code if you can
- What you expected would happen
- What actually happens
- Notes (possibly including why you think this might be happening, or stuff you tried that didn't work)

## Use a Consistent Coding Style

* Use `gofmt` to format your Go code
* Follow Go best practices and idioms
* Write meaningful commit messages
* Add comments for complex logic

## Development Setup

1. **Clone the repository:**
   ```bash
   git clone https://github.com/yourusername/devswitch.git
   cd devswitch
   ```

2. **Install dependencies:**
   ```bash
   go mod download
   ```

3. **Build the project:**
   ```bash
   go build -o devswitch .
   ```

4. **Run tests:**
   ```bash
   go test ./...
   ```

5. **Run linters:**
   ```bash
   go vet ./...
   ```

## Adding New Features

When adding new features:

1. **Config File Support**: Add new config files to `detectConfigFiles()` function
2. **Templates**: Add new templates to the `templates` map in `createFromTemplate()`
3. **Commands**: Add new CLI commands to the main command list
4. **Tests**: Add appropriate tests for new functionality

## Code Style Guidelines

- Follow Go naming conventions
- Use meaningful variable and function names
- Keep functions focused and small
- Add appropriate error handling
- Use the existing color and styling patterns for CLI output

## License

By contributing, you agree that your contributions will be licensed under its MIT License.