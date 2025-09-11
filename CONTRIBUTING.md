# Contributing to SRNE Solarman Home Assistant Integration

Thank you for your interest in contributing! This document provides guidelines and instructions for contributing to this project.

## 🌟 Ways to Contribute

There are many ways you can contribute to this project:

- 🐛 **Report bugs** - Found an issue? Let us know!
- 💡 **Suggest features** - Have an idea? We'd love to hear it!
- 📝 **Improve documentation** - Help make the guides clearer
- 🔧 **Submit code** - Fix bugs or add features
- 🧪 **Test changes** - Try out new features and provide feedback
- 💬 **Help others** - Answer questions in issues and discussions
- 🌍 **Translate** - Help make this accessible to more users

## 📋 Code of Conduct

### Our Pledge

We are committed to providing a welcoming and inclusive environment for everyone, regardless of:
- Experience level
- Gender identity and expression
- Sexual orientation
- Disability
- Personal appearance
- Body size
- Race or ethnicity
- Age
- Religion
- Nationality

### Our Standards

**Positive behaviors include:**
- Using welcoming and inclusive language
- Being respectful of differing viewpoints and experiences
- Gracefully accepting constructive criticism
- Focusing on what is best for the community
- Showing empathy towards other community members

**Unacceptable behaviors include:**
- Harassment, trolling, or insulting comments
- Publishing others' private information
- Using sexualized language or imagery
- Any conduct that would be inappropriate in a professional setting

### Enforcement

Project maintainers have the right to remove, edit, or reject comments, commits, code, issues, and other contributions that don't align with this Code of Conduct.

## 🐛 Reporting Bugs

Before submitting a bug report:

1. **Check existing issues** - Your bug might already be reported
2. **Update to latest version** - The bug might be fixed already
3. **Test with minimal configuration** - Isolate the problem

### How to Submit a Bug Report

Create an issue on GitHub with:

**Title:** Clear, descriptive summary (e.g., "Integration fails to connect on port 8899")

**Description should include:**

1. **Environment Information:**
   ```
   - Hardware: (e.g., Orange Pi Zero 3, Windows 11 PC)
   - OS: (e.g., Armbian Noble 24.x, Windows 11)
   - Home Assistant version: (e.g., 2024.1.0)
   - Docker version: (output of `docker --version`)
   - Integration version: (check custom_components/solarman/manifest.json)
   ```

2. **Steps to Reproduce:**
   ```
   1. Install integration using automated script
   2. Configure with IP 192.168.1.100
   3. Observe error in logs
   ```

3. **Expected Behavior:**
   - What you expected to happen

4. **Actual Behavior:**
   - What actually happened
   - Include exact error messages

5. **Logs:**
   ```bash
   # Home Assistant logs
   docker logs homeassistant --tail 100

   # Enable debug logging in configuration.yaml:
   logger:
     default: info
     logs:
       custom_components.solarman: debug
   ```

6. **Screenshots (if applicable):**
   - Error messages
   - Configuration screens
   - Dashboard issues

## 💡 Suggesting Features

We welcome feature suggestions! Before submitting:

1. **Check existing issues** - Your idea might already be proposed
2. **Consider scope** - Does it fit the project's goals?
3. **Think about use cases** - Who will benefit?

### How to Submit a Feature Request

Create an issue with:

**Title:** Feature request: [Brief description]

**Description should include:**

1. **Problem Statement:**
   - What problem does this solve?
   - Who experiences this problem?

2. **Proposed Solution:**
   - How should it work?
   - What's the user experience?

3. **Alternatives Considered:**
   - What other approaches could work?
   - Why is your proposal better?

4. **Additional Context:**
   - Screenshots, mockups, or examples
   - Links to similar implementations

## 🔧 Contributing Code

### Getting Started

1. **Fork the repository** on GitHub
2. **Clone your fork** locally:
   ```bash
   git clone https://github.com/YOUR-USERNAME/srne-solarman.git
   cd srne-solarman
   ```

3. **Create a branch** for your changes:
   ```bash
   git checkout -b feature/your-feature-name
   # or
   git checkout -b fix/bug-description
   ```

### Development Setup

1. **Set up development environment:**
   ```bash
   # Install Home Assistant in development mode
   pip install homeassistant

   # Install development dependencies
   pip install -r requirements-dev.txt  # If file exists
   ```

2. **Test your changes locally:**
   - Use the manual installation method
   - Test on your actual hardware setup
   - Verify in Home Assistant UI

### Code Guidelines

**General Principles:**
- Write clear, readable code
- Add comments for complex logic
- Follow existing code style
- Keep changes focused and small

**Python Code:**
- Follow PEP 8 style guide
- Use meaningful variable names
- Add docstrings to functions
- Handle errors gracefully

**YAML Files:**
- Use 2 spaces for indentation
- Keep lines under 120 characters
- Add comments explaining complex configurations
- Validate YAML syntax before committing

**Shell Scripts:**
- Use bash for Linux scripts, PowerShell for Windows
- Add comments explaining each major section
- Check for errors after each command
- Print progress messages to users

### Testing Your Changes

Before submitting:

1. **Test the installation:**
   - Test automated script on clean system
   - Test manual installation steps
   - Verify on multiple platforms if possible

2. **Test the functionality:**
   - Connect to real SRNE inverter
   - Verify all sensors update correctly
   - Check dashboard displays properly
   - Test error handling

3. **Check for regressions:**
   - Ensure existing features still work
   - Test common use cases

### Committing Changes

**Commit Message Format:**
```
type: Brief description (50 chars or less)

More detailed explanation if needed (wrap at 72 chars).
Explain the problem and why this solution works.

Fixes #123
```

**Types:**
- `feat:` New feature
- `fix:` Bug fix
- `docs:` Documentation changes
- `style:` Formatting, no code change
- `refactor:` Code restructuring
- `test:` Adding tests
- `chore:` Maintenance tasks

**Examples:**
```
feat: Add support for SRNE MLT series inverters

Implements Modbus register definitions for MLT series.
Tested with MLT-4850 model.

Closes #45

---

fix: Correct battery voltage sensor scaling

Battery voltage was displaying 10x actual value.
Changed scaling factor from 1 to 0.1 in srne_hesp.yaml.

Fixes #78

---

docs: Improve Orange Pi WiFi configuration steps

Added nmtui instructions and troubleshooting steps
for common WiFi connection issues.
```

### Submitting a Pull Request

1. **Push to your fork:**
   ```bash
   git push origin feature/your-feature-name
   ```

2. **Create Pull Request on GitHub:**
   - Go to the original repository
   - Click "New Pull Request"
   - Select your branch

3. **Fill out the PR template:**

   **Title:** Clear, descriptive summary

   **Description:**
   ```markdown
   ## Changes Made
   - List of specific changes
   - What was added/modified/fixed

   ## Motivation
   Why this change is needed

   ## Testing Done
   - Tested on: Orange Pi Zero 3, Armbian Noble
   - Scenarios tested: Fresh install, upgrade from v1.x
   - Results: All sensors working, dashboard displays correctly

   ## Screenshots (if UI changes)
   [Add screenshots here]

   ## Checklist
   - [ ] Tested on actual hardware
   - [ ] Documentation updated
   - [ ] No breaking changes (or documented if necessary)
   - [ ] Follows code style guidelines
   ```

4. **Respond to review feedback:**
   - Be open to suggestions
   - Make requested changes
   - Push updates to same branch

### Pull Request Review Process

1. **Automated checks** will run (if configured)
2. **Maintainer review** - May take a few days
3. **Feedback** - Requested changes or approval
4. **Merge** - Once approved and passing checks

## 📝 Documentation Contributions

Documentation improvements are always welcome!

**What to document:**
- Installation steps for new platforms
- Troubleshooting solutions you discovered
- Configuration examples
- Hardware compatibility notes
- Translation to other languages

**Documentation style:**
- Write for beginners
- Use clear, simple language
- Include code examples
- Add screenshots where helpful
- Test all commands before documenting

**Files to update:**
- `README.md` - Main documentation
- `CONTRIBUTING.md` - This file
- Code comments - Inline documentation

## 🧪 Testing Contributions

Help test new features and bug fixes:

1. **Try pre-release versions**
2. **Test on different hardware** (Orange Pi, Raspberry Pi, PC)
3. **Test different scenarios** (fresh install, upgrade, different inverter models)
4. **Report results** in the relevant GitHub issue or PR

## 🌍 Translation Contributions

Help make this project accessible to more users:

1. **Translate README.md** to your language
2. **Translate UI strings** in Home Assistant integration
3. **Create language-specific guides** for your region

## ❓ Questions?

- **General questions:** Open a Discussion on GitHub
- **Technical questions:** Open an Issue
- **Security concerns:** Email maintainers privately (see README for contact)

## 🎉 Recognition

All contributors will be acknowledged in:
- GitHub Contributors page
- Release notes (for significant contributions)
- README credits section

## 📜 License

By contributing, you agree that your contributions will be licensed under the same license as the project (see LICENSE file).

---

## 🚀 Good First Issues

New to contributing? Look for issues labeled:
- `good first issue` - Perfect for newcomers
- `documentation` - Documentation improvements
- `help wanted` - We need assistance on these

## 📞 Contact

- **GitHub Issues:** For bugs and features
- **GitHub Discussions:** For questions and ideas
- **Project Repository:** https://github.com/davidrapan/ha-solarman

---

Thank you for contributing! 🙏

Every contribution, no matter how small, makes a difference!
