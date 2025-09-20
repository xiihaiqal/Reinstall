# KingKongVPN VPS Reinstaller

A modern, user-friendly bash script for quickly deploying Ubuntu and Debian systems on your VPS with both DHCP and static IP configuration options.

## Features

- 🚀 Fast deployment of Ubuntu and Debian systems
- 🌐 Supports both DHCP and static IP configuration
- 🎨 Modern, colorful terminal interface
- 📱 Responsive layout with Ubuntu and Debian options side-by-side
- 🔧 Custom image support for specialized deployments
- 🌍 Automatic detection for regional mirror optimization

## Supported Systems

### Ubuntu
- Ubuntu 24.04 LTS (Latest)
- Ubuntu 22.04 LTS
- Ubuntu 20.04 LTS
- Ubuntu 18.04 LTS
- Ubuntu 16.04 LTS

### Debian
- Debian 13 (Latest)
- Debian 12
- Debian 11
- Debian 10
- Debian 9
- Debian 8

### Custom Images
- Support for custom image URLs

## Quick Start

Run the following command on your VPS to start the installation:

```bash
bash <(wget -qO- https://raw.githubusercontent.com/xiihaiqal/Reinstall/refs/heads/master/reinstall.sh)
```

Or if you prefer curl:

```bash
bash <(curl -s https://raw.githubusercontent.com/xiihaiqal/Reinstall/refs/heads/master/reinstall.sh)
```

## Manual Installation

1. Download the script:
```bash
wget https://raw.githubusercontent.com/xiihaiqal/Reinstall/refs/heads/master/reinstall.sh
```

2. Make it executable:
```bash
chmod +x reinstall.sh
```

3. Run as root:
```bash
sudo ./reinstall.sh
```

## Usage

1. The script will automatically detect your network configuration
2. Choose between DHCP or manual IP configuration
3. Select your desired operating system from the menu
4. Confirm your selection and the installation will begin

## Network Configuration

The script supports two networking modes:

- **DHCP**: Automatic network configuration (default)
- **Static IP**: Manual configuration of IP address, gateway, and netmask

## Default Credentials

All installed systems use the following default credentials:
- Username: `root`
- Password: `xiihaiqal`

**Important**: Change the default password after installation for security.

## Requirements

- A VPS with KVM virtualization support
- Root access to the server
- Internet connection for downloading installation images
- Minimum 512MB RAM (1GB recommended)
- 10GB+ disk space

## Support

If you encounter any issues:

- **Telegram**: @xiihaiqal

## License

Copyright © KingKongVPN™ 2025. All rights reserved.

## Disclaimer

This script is provided as-is without any warranties. Please ensure you have backups before proceeding with system reinstallation. The authors are not responsible for any data loss or issues arising from the use of this script.

## Contributing

Feel free to submit issues and enhancement requests!

## Star History

If you find this project helpful, please consider giving it a star on GitHub!

[![Star History Chart](https://api.star-history.com/svg?repos=yourusername/yourrepository&type=Date)](https://star-history.com/#yourusername/yourrepository&Date)
