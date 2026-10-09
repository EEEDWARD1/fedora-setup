# Fedora Setup
A collection of Bash scripts to automate my Fedora setup, including development tools, applications, repositories, and system services.

## Scripts
|Script|Purpose
|---|---|
|`01-system.sh`|System updates and basic utilities|
|`02-repositories.sh`|RPM Fusion repositories|
|`03-multimediah.sh`|FFmpeg and hardware acceleration|
|`04-development.sh`|.Net, Node.js, Python, VS Code and compilers|
|`05-docker.sh`|Docker Engine and Compose|
|`06-applications.sh`|Flatpak, Chrome, fonts, and Latex|
|`07-Services.sh`|Tailscale and OneDrive|

## Installation
Clone the repository:

```
git clone https://github.com/USERNAME/fedora-setup.git
cd fedora-setup
```
Run the full setup:
```
bash setup.sh
```
Or run an individual script:
```
bash scripts/01-system.sh
```

## Testing
Check syntax:
```
bash -n setup.sh scripts/*.sh
```
Test in a Fedora 44 VM before running on a physical machine, I am not responsible for anything that goes wrong.

## Notes
- Designed for my personal Fedora 44 install
- Some services require manual authentication
- Scripts use `sudo` where necessary.
- Still under testing; use at your own risk.

