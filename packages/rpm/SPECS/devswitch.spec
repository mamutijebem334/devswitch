Name:           devswitch
Version:        0.1.0
Release:        1%{?dist}
Summary:        Instantly switch developer profiles

License:        MIT
URL:            https://github.com/GustyCube/devswitch
Source0:        devswitch

BuildArch:      x86_64
Requires:       glibc

%description
DevSwitch allows developers to instantly switch between different
configuration profiles (.gitconfig, shell rc, VSCode settings) across
work, school, and personal environments.

Features:
* Beautiful CLI with styled boxes and progress bars
* Profile templates (corporate, personal, minimal)  
* Automatic backup and rollback system
* Profile comparison and selective apply
* Support for 15+ configuration file types
* Cross-platform compatibility

%prep
# No preparation needed for binary release

%build
# No build needed for binary release

%install
rm -rf $RPM_BUILD_ROOT
mkdir -p $RPM_BUILD_ROOT%{_bindir}
cp %{SOURCE0} $RPM_BUILD_ROOT%{_bindir}/devswitch
chmod 755 $RPM_BUILD_ROOT%{_bindir}/devswitch

%files
%{_bindir}/devswitch

%post
echo "DevSwitch v0.1.0 has been installed successfully!"
echo ""
echo "Quick start:"
echo "  devswitch create work --template corporate"
echo "  devswitch create personal --template personal"
echo "  devswitch list"
echo "  devswitch apply work"
echo ""
echo "Documentation: https://github.com/GustyCube/devswitch"

%changelog
* Wed Aug 07 2025 Bennett Schwartz <gc@gustycube.xyz> - 0.1.0-1
- Initial release of DevSwitch CLI
- Instant profile switching for developer configurations
- Beautiful CLI with styled boxes and progress bars
- Automatic backup and rollback system
- Profile comparison and selective apply
- Template system (corporate, personal, minimal)
- Extended configuration support for Git, SSH, Docker, NPM, AWS