![](https://repository-images.githubusercontent.com/759300397/300440e1-d1ea-46df-92b2-bf99d4c9db05)

# MercuryAlloy

MercuryAlloy is an automation tool designed to streamline the build process for the Mercury web browser, an optimized fork of Mozilla Firefox. Through a series of Linux shell scripts, MercuryAlloy enables automatic checking for source code updates, rebuilding of the web browser upon updates, and custom actions for file management and notifications.

## Features

- **Automatic Updates**: Utilizes `autobuild.sh` to check for source code updates every 3 hours and rebuild the Mercury web browser when updates are detected.
- **Customizable Post-Build Actions**: Includes `move_files.sh` and `alert.sh` scripts for custom file management and notifications after a successful build.
- **MercuryOverrides Directory**: Contains overridden files to customize the Mercury web browser build.
- **Environment Configuration**: Uses a `.env` file for easy setup of necessary paths to Mozilla and Mercury source code directories.

## Getting Started

### Prerequisites

- Linux operating system with shell environment
- Git for cloning repositories
- Necessary build tools for compiling Firefox
  - See the [dependencies requirements](https://github.com/Alex313031/Mercury/blob/main/docs/DEPS.md) for Mercury

### Setup Instructions

1. **Clone the Mercury Repository**: Start by cloning the Mercury repository to your local machine.
   ```bash
   git clone https://github.com/Alex313031/Mercury.git
   ```
2. **Initialize the Mercury Repository**: Run `bootstrap.sh` within the cloned Mercury repository to prepare it for building.
   ```bash
   cd [Mercury Repository Directory]
   ./bootstrap.sh
   ```
3. **Configure MercuryAlloy**:
    - Clone the MercuryAlloy repository to your local machine.
    - Edit the `.env` file within MercuryAlloy to point to your cloned Mercury repository and your Mozilla source code directory.
4. **(Optional) Configure `autobuild.sh` as a Service**:
    - Follow the instructions in the provided example service file, paying special attention to manually exposing environment variables necessary for the service context.

### Customizing Build Process

- **move\_files.sh**: Fill in with your logic to move the compiled executable to a desired location, such as a web host.
- **alert.sh**: Implement your custom logic to send a notification when the build completes successfully.

## Service Configuration Note

When configuring `autobuild.sh` as a service, ensure that all required environment variables are exposed to the service. This may require manual configuration, as the service's execution context differs from the user's shell environment.

## Contributing

Contributions to MercuryAlloy are welcome! This project started as a personal endeavor to learn more about building browsers from source with the goal of relieving some of the pain points of aquiring new browser versions. Please submit pull requests or open issues for any enhancements, bug fixes, or improvements.

## License

MercuryAlloy is open source and available under \[MPL-2.0 license\]. See the LICENSE file for more details.

## Acknowledgments

- Mozilla for the Firefox browser, which serves as the foundation for the Mercury web browser.
- The Mercury team for their optimized fork of Firefox, enabling enhanced web browsing experiences.
