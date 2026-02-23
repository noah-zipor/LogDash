# LogDash
![Platform](https://img.shields.io/badge/platform-macOS-blue)
![Swift](https://img.shields.io/badge/Swift-5.9-orange)
![Version](https://img.shields.io/badge/version-1.0.0-green)
![License](https://img.shields.io/badge/license-MIT-lightgrey)

<p align="center">
  <img src="https://github.com/user-attachments/assets/b0bca756-d753-43fe-8d77-4a5f287a5a90" width="256" height="256" />
</p>

A production-grade, high-performance native desktop application suite for macOS and Windows. This project demonstrates advanced operating system integration, robust security hardening, and high-performance user interface design without the overhead of web-based runtimes or Electron-like frameworks.

## Architecture

The project adheres to a strict MVVM (Model-View-ViewModel) architectural pattern, emphasizing separation of concerns and platform-specific optimization:

- **Core**: Contains shared abstractions, domain models, and service interfaces to define system contracts.
- **Services**: Abstracted platform-specific implementations leveraging low-level system APIs.
- **ViewModels**: Encapsulates rich business logic, state management, complex data transformations, UI coordination, and robust error handling.
- **Views**: 100% native user interfaces constructed using WinUI 3 / WPF (Windows) and SwiftUI (macOS), ensuring optimal rendering performance and tight integration with native compositor APIs.

## System Integration Features

The suite leverages advanced operating system capabilities for both performance and deep integration:

- **High-Performance Rendering Pipeline**:
  - Employs hardware-accelerated rendering utilizing Windows Media infrastructure and CoreAnimation/SwiftUI transitions.
  - Implements dynamic Gaussian blur computations on wallpapers, ensuring smooth continuous compositing.
  - Cinematic staggered animations generated through calculated delayed-entry matrices for application components.
- **macOS Subsystem Integration**:
  - Inter-process communication via `DistributedNotificationCenter` for zero-latency Apple Music & Spotify state synchronization.
  - Process launching and discovery delegated to the `NSWorkspace` APIs.
  - Cryptographic credential management and secure persistence via the Apple `Keychain`.
- **Windows Subsystem Integration**:
  - Direct Registry-based application discovery.
  - Media state polling utilizing the `Windows.Media.Control` API.
  - Secure credential storage delegated to the `PasswordVault` mechanisms.

## Security Hardening

Security is treated as a fundamental requirement, integrated directly into the infrastructure:

- **Account Lockout Policy**: Continuous monitoring of authentication attempts, enforcing strict mathematical backoff or automated 15-minute lockouts upon crossing configured threshold limits.
- **Zero-Plaintext Storage**: Absolute prohibition of plaintext credential storage. Utilizes platform-native, hardware-backed security modules. Memory lifecycle management ensures passwords are aggressively zeroed out post-authentication.
- **Persistence Layer Integrity**: Custom `SettingsService` implementations strictly bind to the Windows Registry and macOS `UserDefaults`, preventing external tampering.

## Installation & Deployment Pipelines

### Automated Installation

An idempotent bootstrap script is provided for immediate compilation, packaging, and startup registration on macOS:

```bash
curl -sSL https://raw.githubusercontent.com/nzc0der/startup-dash/main/install.sh | bash
```

*Note: Requires Swift Command Line Tools (macOS) or .NET SDK (Windows).*

### Manual Compilation Strategy

The project features IDE-independent build pipelines designed for CI/CD integration.

**Windows (.NET 6 SDK)**:
```powershell
./build.ps1
```
Executes targeted MSBuild operations, dependency restoration, native compilation, and subsequent packaging routines.

**macOS (Swift 5.7+ Environment)**:
```bash
./build.sh
```
Triggers the Swift Package Manager (SPM) pipeline, compiling native binaries and structuring the final standard `.app` bundle structure out-of-tree.

## Repository Structure

```text
├── Windows/
│   ├── StartupDashboard/      # Main WPF/WinUI Application Namespace
│   ├── StartupDashboard.Tests/ # Automated NUnit/xUnit Test Suite
│   └── StartupDashboard.sln   # Primary MSBuild Solution File
├── macOS/
│   ├── StartupDashboard/      # Main Swift/SwiftUI Application Target
│   └── Tests/                 # XCTest validation suite
├── Package.swift              # Canonical SPM target/dependency definitions
├── build.sh                   # Unix shell deployment automation script
└── install.sh                 # Initial multi-platform bootstrapping router
```

## System Customization

Configuration points span multiple architectural layers:

- **Dynamic Presentation**: `WelcomeViewModel` string interpolation for user-specific greetings.
- **Security Thresholds**: Rate-limiting and temporal lockout constraints are actively tunable via the `SecurityPolicyService`.
- **Cryptographic Reset**: Requires explicit interaction with the platform's root security layer (Keychain Access on macOS, Credential Manager on Windows) to evict the "StartupDashboard" generic credentials token.

## License

Engineering standards enforced by the Senior Desktop Platform Team. All rights reserved.
