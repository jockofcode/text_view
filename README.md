# TextView

TextView is a Ruby library that leverages the Curses library to create and manage terminal-based windows with features like color pairings, message dispatching, and debug logging. It supports a modular approach allowing additional feature inclusion.

## Table of Contents

- [Installation](#installation)
- [Usage](#usage)
  - [Basic Usage](#basic-usage)
  - [Advanced Usage](#advanced-usage)
- [Features](#features)
- [Examples](#examples)
- [Testing](#testing)
- [Contributing](#contributing)
- [License](#license)

## Installation

1. Add this line to your application's Gemfile:

    ```ruby
    gem 'text_view'
    ```

2. And then execute:

    ```bash
    $ bundle install
    ```

3. Or install it yourself as:

    ```bash
    $ gem install text_view
    ```

## Usage

### Basic Usage

To create a new window:

```ruby
require 'text_view'

window = TextView::Window.new
```

### Advanced Usage

To include additional features:

```ruby
require 'text_view'

TextView::Window.include_feature(MyFeatureModule)
```

For more information, see the [Examples](#examples) section.

## Features

- **Color Pairings**: Easily manage color pairings for text and background.
- **Message Dispatching**: Register and dispatch messages between parent and child windows.
- **Debug Logging**: Enable debug logging via environment variables to assist in development.
- **Modular Approach**: Include additional features easily using Ruby's module inclusion.

## Examples

You can find example usage in the `examples` directory.

- `basic_usage.rb`: Demonstrates the basic usage of creating a new window.
- `three_windows.rb`: Demonstrates how to create and manage multiple windows.

## Testing

Run the test suite using:

```bash
$ rspec spec
```

## Contributing

1. Fork the repo on GitHub.
2. Clone the project to your own machine.
3. Commit changes to your own branch.
4. Push your work back up to your fork.
5. Submit a Pull Request so that we can review your changes.

## License

This project is licensed under the MIT License. See the LICENSE.md file for details.

